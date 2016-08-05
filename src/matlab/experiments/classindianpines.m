% Classification Experiment - I
% 
%
% Data
% ----
% * Indian Pines HyperSpectral Image
% * Pavia Hyperspectral Image
%
% Algorithms
% ----------
% * Laplacian Eigenmaps
% * Locality Preserving Projections
% * Schroedinger Eigenmaps
% * Schroedinger Eigenmap Projections
%
% Output
% ------
% * OA      - Overall Accuracy
% * AA      - Average Accuracy
% * k       - Kappa Coefficient
% * AP      - Average Precision
% * Recall  - Recall
% * Dim     - Dimension
% * F1      - F1 Statistic
% * Time    - Time For Complete Algorithm (secs)
%
% Figures 
% -------
% * Classification Maps (all Algorithms)
% * k-NN Parameter Estimations
% * Potential Trade off Parameter Alpha
% * Potential Trade off Parameter Beta
% * % Samples vs. Dimensions
% * k-NN vs. Dimensions vs. % Samples
% * 
%
% Tables
% ------
% * Best Parameters Chosen
% * Statistical Significance
%
% Information
% -----------
% Author: Juan Emmanuel Johnson
% Email: jej2744@rit.edu
% Date: 27th July, 2016
%

% Clear Environment
clear all; close all; clc;

%============================%
% Gather Data for experiment %
%============================%

% add specific directory to matlab space
addpath('H:\Data\Images\RS\IndianPines\');      % specific to PC

img = importdata('Indian_pines_corrected.mat');
imgGT = importdata('Indian_pines_gt.mat');

% remove path from matlab space
rmpath('H:\Data\Images\RS\IndianPines\');  

%=========================================%
% Reorder and Rescale data into 2-D Array %
%=========================================%

[numRows, numCols, numSpectra] = size(img);
scfact = mean(reshape(sqrt(sum(img.^2,3)), numRows*numCols,1));
img = img./scfact;
imgVec = reshape(img, [numRows*numCols numSpectra]);
gtVec = reshape(imgGT, [numRows*numCols 1]);

%==================================%
% Spectral K-NN Graph Construction %
%==================================%

options = [];
options.type = 'standard';
options.saved = 1;
options.k = 20;

% save spectral knn options 
lpp_options.knn = options;                      % LPP Algorithm
sep_options.spectral_nn = options;              % SEP Algorithm
le_options.knn = options;                       % LE Algorithm
se_options.spectral_nn = options;               % SE Algorithm

%=================================%
% Spatial K-NN Graph Construction %
%=================================%

options = [];
options.k = 4;
options.saved = 0;

% save spatial knn options
sep_options.spatial_nn = options;               % SEP Algorithm
se_options.spatial_nn = options;                % SE Algorithm

%=================================%
% Eigenvalue Decompsition Options %
%=================================%

options = [];
options.n_components = 150;
options.constraint = 'degree';

% save eigenvalue decomposition options
lpp_options.embedding = options;                % LPP Algorithm
sep_options.embedding = options;                % SEP Algorithm
le_options.embedding = options;                 % LE Algorithm
sep_options.embedding = options;                % SE Algorithm


%==========================%
% Spatial Spectral Options %
%==========================%

options = [];
options.image = img;

% save partial labels options
sep_options.ss = options;                       % SEP Algorithm
se_options.ss = options;                        % SE Algorithm

% schroedinger eigenmaps type
sep_options.type = 'spaspec';                   % SEP Algorithm
se_options.type = 'spaspec';                    % SE Algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform Kernel Eigenmap Method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
embedding = [];
%=====================%
%% Laplacian Eigenmaps %
%=====================%

tic;
embedding.le = LaplacianEigenmaps(imgVec, le_options);
time.le = toc;

%========================%
%% Schroedinger Eigenmaps %
%========================%

tic;
embedding.se = SchroedingerEigenmaps(imgVec, se_options);
time.se = toc;

%=================================%
%% Locality Preserving Projections %
%=================================%

tic;
projections = LocalityPreservingProjections(imgVec, lpp_options);
embedding = imgVec * projections;             % project data
time.lpp = toc;

classOptions = [];
classOptions.trainPrct = .10;
classOptions.experiment = 'statsdims';
classOptions.method = 'svm';
classOptions.gtVec = gtVec;
[statslpp] = classexperiments(embedding, classOptions);

%% save the statistics for later
save_path = 'H:\Data\saved_data\class_results\indian_pines\lpp_';
save_str = char([ save_path sprintf('k%d', 20)]);
save(save_str, 'embedding', 'statslpp')

%===================================%
%% Schroedinger Eigenmap Projections %
%===================================%

tic;
projections = SchroedingerEigenmapProjections(imgVec, sep_options);
embedding = imgVec * projections;             % project data
time.sep = toc;

classOptions = [];
classOptions.trainPrct = .10;
classOptions.experiment = 'statsdims';
classOptions.method = 'svm';
classOptions.gtVec = gtVec;
[statssep] = classexperiments(embedding, classOptions);

%% save the statistics for later
save_path = 'H:\Data\saved_data\class_results\indian_pines\sep_';
save_str = char([ save_path sprintf('k%d', 20)]);
save(save_str, 'embedding', 'statssep')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








