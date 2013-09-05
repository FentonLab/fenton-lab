
%% Files
% Import dat files from a design file (in xlsx format)
designFile = fullfile(pwd(), 'test/fixtures/OnedayProtocolLogSheet.xlsx');
datFiles = fullfile(pwd(), 'test/fixtures/batch/DATfiles');

% Import an analysis from the fmr1 tbl file (in xlsx format)
tblFile = fullfile(pwd(), '/test/fixtures/batch/fmr1.xlsx');
psFiles = fullfile(pwd(), 'test/fixtures/batch/PSfiles');


%% Protocol parameters
protocols.Hab = 'Hab protocol';
protocols.Retest = 'Retest protocol';
protocols.Train1 = 'Train1 protocol';
protocols.Train2 = 'Train2 protocol';
protocols.Train3 = 'Train3 protocol';


%% Example import

% The URI in the line below would be replaced with the URI of the EpochGroup or Experiment
% into which you would like to import the data
egroup = ctx.getObjectWithURI('ovation://03d83127-4ac1-4ec0-8272-1e310c527376/');

% Import the .dat files
epochsMap = batch_dat_import(ctx, egroup, protocols, 'America/New_York', designFile, datFiles);

% The protocol name in the line below would be replaced with the name of the *analysis*
% protocol used. 
analysisProtocol = ctx.getProtocol('fenton-analysis-protocol-demo');

% If you don't have an analysis protocol defined, you can create one, referencing the
% appropriate entry function, repository and code version
if(isempty(analysisProtocol))
    analysisProtocol = ctx.insertProtocol('fenton-analysis-protocol-demo',...
        'Automated analysis',...
        'analysis_entry_function',... %TODO which function?
        'https://github.com/FentonLab/analysis-code',... %TODO which repository?
        '2f6a01b49fdab0c55ae50516fc9f257d1cf405e2'); % TODO what version?
end

% Import an analysis as AnalysisRecords attached to the associated Epochs
batch_analysis_import(epochsMap, tblFile, psFiles, analysisProtocol, analysisParameters);

