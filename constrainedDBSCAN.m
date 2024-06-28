function labels = constrainedDBSCAN(data, metric, ML, CL, eps, min_samples)
    % Function to perform constrained DBScan clustering
    % Inputs:
    %   data - n*d matrix of data points
    %   metric - string representing the distance metric
    %   ML - m*2 matrix of must-link constraints
    %   CL - m*2 matrix of cannot-link constraints
    %   eps - radius for neighborhood
    %   min_samples - minimum number of points required to form a core point
    % Output:
    %   labels - n*1 vector of cluster labels

    % Number of data points
    n = size(data, 1);
    
    % Initialize labels
    labels = -ones(n, 1); % -1 indicates unvisited
    clusterId = 0; % Cluster ID
    
    % Compute pairwise distances
    distanceMatrix = pdist2(data, data, metric);
    
    % Initialize cluster structures
    corePoints = false(n, 1);
    visited = false(n, 1);
    noise = false(n, 1);

    % Identify core points
    for i = 1:n
        neighbors = find(distanceMatrix(i, :) <= eps);
        if numel(neighbors) >= min_samples
            corePoints(i) = true;
        end
    end
    
    % Create adjacency matrices for must-link and cannot-link constraints
    mustLinkMatrix = false(n, n);
    cannotLinkMatrix = false(n, n);
    for i = 1:size(ML, 1)
        mustLinkMatrix(ML(i, 1), ML(i, 2)) = true;
        mustLinkMatrix(ML(i, 2), ML(i, 1)) = true;
    end
    for i = 1:size(CL, 1)
        cannotLinkMatrix(CL(i, 1), CL(i, 2)) = true;
        cannotLinkMatrix(CL(i, 2), CL(i, 1)) = true;
    end
    
    % Expand clusters from core points
    for i = 1:n
        if visited(i) || ~corePoints(i)
            continue;
        end
        
        clusterId = clusterId + 1;
        labels(i) = clusterId;
        searchQueue = [i];
        visited(i) = true;
        
        while ~isempty(searchQueue)
            point = searchQueue(1);
            searchQueue(1) = [];
            neighbors = find(distanceMatrix(point, :) <= eps);
            
            if numel(neighbors) < min_samples
                continue;
            end
            
            for j = 1:numel(neighbors)
                neighbor = neighbors(j);
                
                if visited(neighbor)
                    continue;
                end
                
                % Check cannot-link constraints
                if any(cannotLinkMatrix(neighbor, labels == clusterId))
                    noise(neighbor) = true;
                    continue;
                end
                
                % Add neighbor to the cluster
                labels(neighbor) = clusterId;
                visited(neighbor) = true;
                if corePoints(neighbor)
                    searchQueue(end+1) = neighbor; %#ok<AGROW>
                end
            end
        end
    end
    
    % Handle noise points
    labels(noise) = -1;
    
    % Enforce must-link constraints
    for i = 1:size(ML, 1)
        point1 = ML(i, 1);
        point2 = ML(i, 2);
        if labels(point1) ~= -1 && labels(point2) == -1
            labels(point2) = labels(point1);
        elseif labels(point2) ~= -1 && labels(point1) == -1
            labels(point1) = labels(point2);
        elseif labels(point1) ~= -1 && labels(point2) ~= -1
            cluster1 = labels(point1);
            cluster2 = labels(point2);
            if cluster1 ~= cluster2
                labels(labels == cluster2) = cluster1;
            end
        end
    end
    
    % Handle remaining noise points with must-link constraints
    for i = 1:n
        if labels(i) == -1
            mlConstraints = ML(any(ML == i, 2), :);
            for j = 1:size(mlConstraints, 1)
                point = setdiff(mlConstraints(j, :), i);
                if labels(point) > 0
                    labels(i) = labels(point);
                    break;
                end
            end
        end
    end
    
    % Rename clusters to be consecutive
    uniqueLabels = unique(labels);
    uniqueLabels(uniqueLabels == -1) = [];
    for i = 1:numel(uniqueLabels)
        labels(labels == uniqueLabels(i)) = i - 1;
    end
    
end


