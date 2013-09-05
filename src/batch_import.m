
%% Files
designFile = '/Users/barry/development/fenton-lab/test/fixtures/OnedayProtocolLogSheet.xlsx';

%% Read design file

design = importdata(designFile);

%% For each row in design, print out the relevant files


protocols.Hab = 'Hab protocol';
protocols.Retest = 'Retest protocol';
protocols.Train1 = 'Train1 protocol';
protocols.Train2 = 'Train2 protocol';
protocols.Train3 = 'Train3 protocol';

trials = read_design_file(designFile, protocols);

for j = 1:length(trials)
    disp(['Date: ' char(trials(j).date.toString())]);
    disp(['Group: ' trials(j).group]);
    disp(['Room frame dat: ' trials(j).roomFile]);
    disp(['Arena frame dat: ' trials(j).arenaFile]);
    disp(['Source: ' trials(j).source]);
    disp(['Protocol: ' trials(j).protocol]);
    disp(' ');
    disp(' ');
end

%% Import Trials

datFilesFolder = 'fixtures/batch/DATfiles';

import java.util.HashMap;

container = ctx.getObjectWithURI('ovation://aeb7ad18-e491-4438-96a3-2b8a5ff60399/');
groups = HashMap();
protocols = HashMap();

for i = 1:length(trials)
    trial = trials(j);
    if(~groups.hasKey(trial.group))
        groups.put(trial.group, container.insertEpochGroup(trial.group,...
            experiment.getStart(),...
            [],...
            HashMap(),...
            HashMap()));
    end
    
    group = groups.get(trial.group);
    
    sources = asarray(ctx.getSourcesWithIdentifier(trial.source));
    assert(length(sources) <= 1);
    if(isempty(sources))
        source = ctx.insertSource(['Mouse ' trial.source], trial.source);
    else
        source = sources(1);
    end
    
    protocol = ctx.getProtocol(trial.protocol);
    if(isempty(protocol))
        protocol = ctx.insertProtocol(trial.protocol, '??');
    end
    
    
    epoch = import_fenton_dat(source,...
        container,...
        protocol,...
        'Arena',...
        'Camera',...
        timeZone,...
        trial.duration,...
        fullfile(datFilesFolder, [trial.arenaFile '.dat']),...
        fullfile(datFilesFolder, [trial.arenaFile '.png']),...
        fullfile(datFilesFolder, [trial.roomFile '.dat']),...
        fullfile(datFilesFolder, [trial.roomFile '.png']),...
        'image/png');
end
       

%% Try a batch import

protocols.Hab = 'Hab protocol';
protocols.Retest = 'Retest protocol';
protocols.Train1 = 'Train1 protocol';
protocols.Train2 = 'Train2 protocol';
protocols.Train3 = 'Train3 protocol';

egroup = ctx.getObjectWithURI('ovation://03d83127-4ac1-4ec0-8272-1e310c527376/');

epochsMap = batch_dat_import(ctx, egroup, protocols, 'America/New_York', designFile, '/Users/barry/development/fenton-lab/test/fixtures/batch/DATfiles');

tblFile = '/Users/barry/development/fenton-lab/test/fixtures/batch/fmr1.xlsx';
psFiles = '/Users/barry/development/fenton-lab/test/fixtures/batch/PSfiles';
analysisProtocol = ctx.getProtocol('fenton-analysis-protocol-demo');
if(isempty(analysisProtocol))
    analysisProtocol = ctx.insertProtocol('fenton-analysis-protocol-demo',...
        'Automated analysis',...
        'analysis_entry_function',... %TODO which function?
        'https://github.com/FentonLab/analysis-code',... %TODO which repository?
        'TBD');
end% TODO what version?

batch_analysis_import(epochsMap, tblFile, psFiles, analysisProtocol, analysisParameters);

