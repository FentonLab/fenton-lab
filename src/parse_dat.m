% Parses a Fenton lab .dat header
%
% Parameters
%   dataPath : string
%     Path to .dat file
%   prefix : string
%     Parameter prefix


% Copyright (c) 2013 Physion Consulting LLC

function [csvPath, epochInfo, protocolParameters] = parse_dat(datPath, prefix)
    
    fid = fopen(datPath, 'r');
    cleaner = onCleanup(@() fclose(fid)); % Always close fid when we leave scope
    
    epochInfo = java.util.HashMap();
    protocolParameters = java.util.HashMap();
    columns = {}; %#ok<NASGU>
    
    inHeader = false;
    inDatabaseInformation = false;
    inSetupInformation = false;
    inRecordFormat = false;
    
    csvPath = tempname();
    fid2 = fopen(csvPath, 'w');
    cleaner2 = onCleanup(@() fclose(fid2)); % Always close fid when we leave scope
    
    disp(['Parsing ' prefix ' header...']);
    line = fgetl(fid);
    while ischar(line)
        
        % Determine which section tline is from;
        if strcmp(line, '%%BEGIN_HEADER')
            inHeader = true;
            disp(['Writing ' prefix ' records to CSV...']);
        end
        
        if strcmp(line, '%%END_HEADER')
            inHeader = false;
        end
        
        s = char(java.lang.String(line).trim());
        if inHeader && strcmp(s, '%%BEGIN DATABASE_INFORMATION')
            inDatabaseInformation = true;
        end
        
        if inHeader && strcmp(s, '%%END DATABASE_INFORMATION')
            inDatabaseInformation = false;
        end
        
        if inHeader && strcmp(s, '%%BEGIN SETUP_INFORMATION')
            inSetupInformation = true;
        end
        
        if inHeader && strcmp(s, '%%END SETUP_INFORMATION')
            inSetupInformation = false;
        end
        
        if inHeader && strcmp(s, '%%BEGIN RECORD_FORMAT')
            inRecordFormat = true;
        end
        
        if inHeader && strcmp(s, '%%END RECORD_FORMAT')
            inRecordFormat = false;
        end
        
        if inDatabaseInformation || inSetupInformation || inRecordFormat
            %Parse key-value pair from line
            m = regexp(s, '%([\w\.]*) \(\s+(.*)\s+\)', 'tokens');
            
            if(~isempty(m))
                c=m{1};
                
                if inDatabaseInformation
                    epochInfo.put(c{1}, c{2});
                elseif inSetupInformation
                    protocolParameters.put(java.lang.String([prefix '.' c{1}]), c{2});
                elseif inRecordFormat
                    columns = strsplit(c{2});
                    fprintf(fid2, '%s\n', strjoin(columns,','));
                end
            end
        end
        
        % Write records as CSV to temporary file
        if ~inHeader && ~strcmp(line, '%%END_HEADER')
            csv = strjoin(strsplit(line), ',');
            fprintf(fid2, '%s\n', csv);
        end
        
        line = fgetl(fid);
    end
    
end