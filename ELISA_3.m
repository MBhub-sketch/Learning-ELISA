%% ELISA 4PL Analysis 
%% Source Data from: MyAssaysLtd, 2021
%% Cardillo G. (2012) Four parameters logistic regression - There and back again
%% https://it.mathworks.com/matlabcentral/fileexchange/38122

%% Step 1: Importing data saved as data_analysis_2
filename = 'data_analysis_2.xlsx'; 
dataTable = readtable(filename);

% Columns:
% A: Concentration 
% B: Absorbance

%% Step 2: Separate standards and unknowns
stdIdx = ~isnan(dataTable.Concentration);   
sampleIdx = isnan(dataTable.Concentration); 
X_std = dataTable.Concentration(stdIdx);
Y_std = dataTable.Absorbance(stdIdx);

Y_samples = dataTable.Absorbance(sampleIdx);


Y_samples = Y_samples(:)';

%% Step 3: Fitting a 4PL curve using L4P command as seen in Cardillo G. (2012)
[cf, G] = L4P(X_std, Y_std);   % cf is a cfit object, G is goodness-of-fit

%% Step 4: Interpolating a sample concentrations using fit object as seen in Cardillo G. (2012)
sampleConc = L4Pinv(cf, Y_samples);  % pass cf directly

%% Step 5: Ploting a standard curve and the samples 
xFit = linspace(min(X_std), max(X_std), 100);
yFit = cf(xFit);  

figure;
plot(X_std, Y_std, 'ro','MarkerSize',8,'LineWidth',1.5); hold on;
plot(xFit, yFit,'b-','LineWidth',2);
scatter(repmat(0,length(Y_samples),1), Y_samples, 50,'g','filled'); % optional: samples at X=0
xlabel('Concentration'); ylabel('Absorbance');
title('4PL ELISA Standard Curve and Samples');
legend('Standards','4PL Fit','Samples','Location','Best');
grid on;

%% Step 6: Creating a results table and saving it as an excel file
sampleIDs = (1:length(sampleConc))'; 
resultsTable = table(sampleIDs, Y_samples', sampleConc', ...
    'VariableNames', {'Sample_ID','Absorbance','Concentration'});

writetable(resultsTable,'ELISA_analysis_all_samples.xlsx');

disp('4PL curve fitting complete. All sample concentrations saved to ELISA_analysis_all_samples.xlsx');
disp(resultsTable);
