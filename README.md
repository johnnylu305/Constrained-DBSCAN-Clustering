

# Constrained DBSCAN Clustering


## 1. Introduction

This document describes the implementation of the Constrained DBSCAN clustering algorithm. Constrained DBSCAN extends the traditional DBSCAN algorithm by incorporating must-link and cannot-link constraints, enabling more refined clustering based on prior knowledge about data relationships.

## 2. Function Overview

### 2.1. Function Signature



*function labels = constrainedDBSCAN(data, metric, ML, CL, eps, min_samples)*
<br>


### 2.2. Parameters

- **data**: An $n \times d$ matrix of data points, where $n$ is the number of data points and $d$ is the dimensionality of the data.
- **metric**: A string representing the distance metric to use for calculating pairwise distances between data points.
- **ML**: An $m \times 2$ matrix of must-link constraints, where each row represents a pair of points that must be in the same cluster.
- **CL**: An $m \times 2$ matrix of cannot-link constraints, where each row represents a pair of points that must not be in the same cluster.
- **eps**: The radius for the neighborhood of a point.
- **min_samples**: The minimum number of points required to form a core point.

### 2.3. Returns

- **labels**: An $n \times 1$ vector of cluster labels. A label of -1 indicates a noise point, while other values indicate cluster membership.

## 3. Description

The Constrained DBSCAN algorithm follows these steps:

1. **Initialization**:
    - Compute the pairwise distance matrix using the specified metric.
    - Identify core points based on the `eps` radius and `min_samples` criteria.
    - Create adjacency matrices for must-link and cannot-link constraints.
2. **Clustering**:
    - Expand clusters starting from each core point, respecting cannot-link constraints to avoid adding points that violate these constraints.
    - Assign noise points that violate constraints or cannot be assigned to any cluster.
3. **Post-processing**:
    - Enforce must-link constraints to ensure points that must be linked are in the same cluster.
    - Handle remaining noise points by attempting to assign them to clusters based on must-link constraints.
    - Renumber clusters to ensure labels are consecutive integers starting from 0.

## 4. Usage

### 4.1. Input Data Preparation

Prepare your data as an $n \times d$ matrix. Define must-link (ML) and cannot-link (CL) constraints as $m \times 2$ matrices.

### 4.2. Call the Function


*labels = constrainedDBSCAN(data, 'euclidean', ML, CL, 0.5, 5);*
<br>

Replace `'euclidean'` with your desired metric, `0.5` with your `eps` value, and `5` with your `min_samples` value.

### 4.3. Example


% Sample data
data = [randn(50, 2); randn(50, 2) + 5];

% Must-link constraints
ML = [1, 2; 3, 4];

% Cannot-link constraints
CL = [1, 3; 2, 4];

% Parameters
eps = 0.5;
min_samples = 5;

% Perform constrained DBSCAN
labels = constrainedDBSCAN(data, 'euclidean', ML, CL, eps, min_samples);

% Plot results
gscatter(data(:,1), data(:,2), labels);
title('Constrained DBSCAN Clustering');


## 5. Notes

- Ensure that must-link and cannot-link constraints do not conflict, as this can lead to undefined behavior.
- Adjust `eps` and `min_samples` based on your specific dataset and desired clustering granularity.

## 6. License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 7. Acknowledgments

This implementation is based on the traditional DBSCAN algorithm with extensions for handling constraints, inspired by various research works in the field of constrained clustering.

## 8. References

Ruiz, Carlos, Myra Spiliopoulou, and Ernestina Menasalvas. ``C-dbscan: Density-based clustering with constraints.'' Rough Sets, Fuzzy Sets, Data Mining and Granular Computing: 11th International Conference, RSFDGrC 2007, Toronto, Canada, May 14-16, 2007. Proceedings 11. Springer Berlin Heidelberg, 2007.



