% Copyright (c) 2013 Physion Consulting LLC

classdef TestReadDesignFile < MatlabTestCase
    
    methods
        
        function self = TestReadDesignFile(name)
            self = self@MatlabTestCase(name);
        end
        
        % Smoke test for dat import
        function testDesignFileTrials(~)
            import ovation.*;
            
            designFile = 'fixtures/OnedayProtocolLogSheet.xlsx';
            
            
            protocols.Hab = 'Hab protocol';
            protocols.Retest = 'Retest protocol';
            protocols.Train1 = 'Train1 protocol';
            protocols.Train2 = 'Train2 protocol';
            protocols.Train3 = 'Train3 protocol';
            
            design = importdata(designFile);
            
            DATE_COLUMN = 1;
            GROUP_COLUMN = 2;
            SUBJECT_COLUMN = 3;
            PROTOCOL_COLUMN = 5; % Condition
            ROOM_FILE_COLUMN = 6;
            ARENA_FILE_COLUMN = 7;
            HEADER_ROWS = 1;
            
            timeZone = 'America/New_York';
            
            protocols.Hab = 'Hab protocol';
            protocols.Retest = 'Retest protocol';
            protocols.Train1 = 'Train1 protocol';
            protocols.Train2 = 'Train2 protocol';
            protocols.Train3 = 'Train3 protocol';
            
            expectedTrials = struct();
            lastDate = [];
            
            for i = (1+HEADER_ROWS):size(design.textdata, 1)
                if(~isempty(design.textdata{i, SUBJECT_COLUMN}))
                    if(~isempty(design.textdata{i, DATE_COLUMN}))
                        dateComps = strsplit('/', design.textdata{i, DATE_COLUMN});
                        date = datetime(str2double(dateComps{3}), ...
                            str2double(dateComps{2}),...
                            str2double(dateComps{1}),...
                            0, 0, 0, 0, timeZone);
                        lastDate = date;
                    else
                        assert(~isempty(lastDate));
                        date = lastDate;
                    end
                    
                    expectedTrials(i-1).date = date; %#ok<*SAGROW>
                    expectedTrials(i-1).group = design.textdata{i, GROUP_COLUMN};
                    expectedTrials(i-1).roomFile = design.textdata{i, ROOM_FILE_COLUMN};
                    expectedTrials(i-1).arenaFile = design.textdata{i, ARENA_FILE_COLUMN};
                    expectedTrials(i-1).source = design.textdata{i, SUBJECT_COLUMN};
                    expectedTrials(i-1).protocol = protocols.(design.textdata{i, PROTOCOL_COLUMN});
                    expectedTrials(i-1).duration = design.data(i-1, 1);
                end
            end
            
            trials = read_design_file(designFile, protocols);
            
            for j = 1:length(trials)
                assert(trials(j).date.equals(expectedTrials(j).date));
                assert(strcmp(expectedTrials(j).group, trials(j).group));
                assert(strcmp(expectedTrials(j).roomFile, trials(j).roomFile));
                assert(strcmp(expectedTrials(j).arenaFile, trials(j).arenaFile));
                assert(strcmp(expectedTrials(j).source, trials(j).source));
                assert(strcmp(expectedTrials(j).protocol, trials(j).protocol));
            end
        end
    end
end