% Batch imports a collection of Fenton Lab .dat files
%
%
%     Parameters
%     ----------
%         context : us.physion.ovation.DataContext
%             Ovation DataContext
%         container : us.physion.ovation.domain.EpochGroupContainer
%             Ovation EpochContainer to receive inserted EpochGroups
%         protocols : struct
%             Struct of Design file condition => Protocol name
%         designFile : string
%             Full path to design file in Excel XML format (.xlsx)
%         datFilesFolder : string
%             Full path to folder containin .dat and .png files
% 
%     Return
%     ------
%         Map datFile => Epoch of imported Epochs
% 
%
%     Example
%     -------
%     
%         designFile = 'OnedayProtocolLogSheet.xlsx';
% 
%         protocols.Hab = 'Hab protocol';
%         protocols.Retest = 'Retest protocol';
%         protocols.Train1 = 'Train1 protocol';
%         protocols.Train2 = 'Train2 protocol';
%         protocols.Train3 = 'Train3 protocol';
% 
%         egroup = context.getObjectWithURI('ovation://03d83127-4ac1-4ec0-8272-1e310c527376/');
% 
%         epochsMap = batch_dat_import(context,...
%                                     container,...
%                                     protocols,...
%                                     'America/New_York',...
%                                     designFile,...
%                                     datFilesFoler);



function epochsMap = batch_dat_import(context,...
        container,...
        protocols,...
        timeZone,...
        designFile,...
        datFilesFolder)
    
    import ovation.*;
    import java.util.HashMap;
    
    disp(['Reading design file ' designFile '...']);
    trials = read_design_file(designFile, protocols);
    
    groups = HashMap();
    itr = container.getEpochGroups().iterator();
    while(itr.hasNext())
        g = itr.next();
        groups.put(g.getLabel(), g);
    end
    
    epochsMap = HashMap();
    disp(['Importing ' num2str(length(trials)) ' trials:']);
    for i = 1:length(trials)
        trial = trials(i);
        
        sources = asarray(context.getSourcesWithIdentifier(trial.source));
        assert(length(sources) <= 1);
        if(isempty(sources))
            source = context.insertSource(['Mouse ' trial.source], trial.source);
        else
            source = sources(1);
        end
        
        protocol = context.getProtocol(trial.protocol);
        if(isempty(protocol))
            protocol = context.insertProtocol(trial.protocol, '??');
        end
        
        if(~groups.containsKey(trial.group))
            groups.put(trial.group, container.insertEpochGroup(trial.group,...
                container.getStart(),...
                [],...
                HashMap(),...
                HashMap()));
        end
        
        group = groups.get(trial.group);
        
        disp(['  Trial ' num2str(i) ' ' trial.roomFile '/' trial.arenaFile '...']);
        epoch = import_fenton_dat(source,...
            group,...
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
        
        
        epochsMap.put(trial.arenaFile, epoch);
        epochsMap.put(trial.roomFile, epoch);
    end
end