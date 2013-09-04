function trials = read_design_file(xlsx_path, protocols)
    
    design = importdata(xlsx_path);
    
    import ovation.*;
    
    DATE_COLUMN = 1;
    GROUP_COLUMN = 2;
    SUBJECT_COLUMN = 3;
    DAY_OF_EXPERIMENT_COLUMN = 4;
    PROTOCOL_COLUMN = 5; % Condition
    ROOM_FILE_COLUMN = 6;
    ARENA_FILE_COLUMN = 7;
    
    HEADER_ROWS = 1;
    
    DURATION_SECONDS_COLUMN = 1; % in design.data
    
    timeZone = 'America/New_York';
    
    trials = struct();
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
            
            trials(i-1).date = date; %#ok<*SAGROW>
            trials(i-1).group = design.textdata{i, GROUP_COLUMN};
            trials(i-1).roomFile = design.textdata{i, ROOM_FILE_COLUMN};
            trials(i-1).arenaFile = design.textdata{i, ARENA_FILE_COLUMN};
            trials(i-1).source = design.textdata{i, SUBJECT_COLUMN};
            trials(i-1).protocol = protocols.(design.textdata{i, PROTOCOL_COLUMN});
            trials(i-1).duration = design.data(i-1, DURATION_SECONDS_COLUMN);
        end
    end
end