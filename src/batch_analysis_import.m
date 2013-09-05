function batch_analysis_import(epochsMap,...
        tblFile,...
        psFiles,...
        analysisProtocol,...
        analysisParameters)
   
    import ovation.*;
    import java.io.File;
    
    %% Import tbl file
    tbl = importdata(tblFile);
    
    %% Import analysis artifacts for each entry in tbl
    FIRST_ROW = 5; % 4 header rows
    
    % Text data columns
    FILENAME_COLUMN = 1;
    
    % Numeric data columns
    TOTAL_TIME_COLUMN = 2;
    
    disp(['Importing ' num2str(size(tbl.textdata,1) - FIRST_ROW + 1) ' analysis records:']);
    for i = FIRST_ROW:size(tbl.textdata,1)
        
        fileName = strtrim(tbl.textdata{i, FILENAME_COLUMN});
        if(epochsMap.containsKey(fileName))
            epoch = epochsMap.get(fileName);
            
            inputs = measurement_input_map(epoch.getMeasurements());
            
            timespan = ['[0-' num2str(tbl.data(i-FIRST_ROW+1, TOTAL_TIME_COLUMN)) ']'];
            
            disp(['  ' fileName timespan '...']);
            analysisRecord = epoch.addAnalysisRecord(['Automated analysis ' timespan],... % TODO a better name
                inputs,...
                analysisProtocol,... 
                struct2map(analysisParameters)...
                );
            
            psFile = fullfile(psFiles, [fileName timespan '.ps']);
            if(File(psFile).exists())
                url = File(psFile).toURL();
                analysisRecord.addOutput('figure',...
                    url,...
                    'application/postscript');
            end
            
            % Create a temporary CSV file to hold the analysis results
            csvPath = tempname();
            fid = fopen(csvPath, 'w');
            cleaner2 = onCleanup(@() fclose(fid)); % Always close fid when we leave scope
            
            columns = tbl.textdata(1,:);
            values = tbl.textdata(i,:);
            fprintf(fid, '%s\n', strjoin(columns, ','));
            fprintf(fid, '%s\n', strjoin(values, ','));
            
            analysisRecord.addOutput('results',...
                File(csvPath).toURL(),...
                'text/csv');
            
            disp('    Waiting for all cloud uploads to finish...');
            wait_for_pending_uploads(epoch.getDataContext());
        else
            warning('fentonlab:batch_analysis_import:missing_epoch',...
                ['Epochs map does not contain an entry for ' fileName ]);
        end
    end
end