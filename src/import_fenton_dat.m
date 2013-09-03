% Imports Fenton-lab .dat file pari as a two-measurement Epoch.
%
% This function assumes that there are two simultaneous measurements and
% matching images:
%     Room coordinate frame
%     Arena coordinate frame
%
% Given paths to these paired .dat and image (e.g. PNG) files, this function
% imports each .dat file as a separate measurement ("ArenaFrame" and "DateFrame"),
% merging the relevant protocol parameters with the same prefix (e.g.
% "ArenaFrame.parameter" and "RoomFrame.parameter").
%
% The parse_fenton_dat parses the .dat header and converts measurements
% to CSV.
%
% Parameters
%     source : us.physion.ovation.domain.Source
%         Data source (i.e. subject)
%
%     container : us.physion.ovation.domain.EpochContainer
%
%     protocol : us.physion.ovation.domain.Protocol
%         Epoch Protocol
%
%     arenaDeviceName : string
%         Arena "device" name. Should match device in Experiment's EquipmentSetup.
%
%     arenaImageDeviceName : string
%         Arena imaging "device" name. Should match device in Experiment's EquipmentSetup.
%
%     timeZone : string
%         Timezone name
%
%     duration : float
%         Epoch duration (seconds)
%
%     arenaFrameDatPath : string
%         Path to arena-frame .dat file
%
%     arenaFrameImagePath : string
%         Absolute path to arena-frame image file
%
%     roomFrameDatPath : string
%         Path to room-frame .dat file
%
%     roomFrameImagePath : string
%         Absolute path to room-frame image file.
%
%     imageContentType : string
%         Image content type (e.g. image/png, image/bmp, etc.)
%
%
% Returns:
%     Newly inserted Epoch instance

function epoch = import_fenton_dat(source, container, protocol,...
        arenaDeviceName,...
        arenaImageDeviceName,...
        timeZone,...
        duration,...
        arenaFrameDatPath, arenaFrameImagePath,...
        roomFrameDatPath, roomFrameImagePath,...
        imageContentType)
    
    import ovation.*;
    
    [arenaCsvPath, arenaEpochInfo, arenaProtocolParameters] = parse_dat(arenaFrameDatPath, 'ArenaFrame');
    [roomCsvPath, roomEpochInfo, roomProtocolParameters ] = parse_dat(roomFrameDatPath, 'RoomFrame');
    
    protocolParameters = arenaProtocolParameters;
    protocolParameters.putAll(roomProtocolParameters);
    
    assert(arenaEpochInfo.equals(roomEpochInfo),...
        'Room and Arena DATABASE_INFORMATION do not match. Perhaps these files were not acquired simultaneously?');
    
    epochInfo = arenaEpochInfo;
    
    % Parse Epoch start time from Date.0 and Time.0
    dateComps = strsplit(epochInfo.get('Date.0'),'.');
    timeSplit = strsplit(epochInfo.get('Time.0'));
    timeComps = strsplit(timeSplit{1},':');
    ampm = timeSplit{2};
    hour = str2double(timeComps{1});
    minute = str2double(timeComps{2});
    if(strcmp(ampm, 'PM'))
        hour = hour + 12;
    end
    
    % Add an Epoch for the measurement
    inputSources = java.util.HashMap();
    inputSources.put('subject', source);
    
    start = datetime(str2double(dateComps{3}),... % year
        str2double(dateComps{2}),... % month
        str2double(dateComps{1}),... % day?
        hour,... % hour
        minute,... % minute
        0,... % second
        0,...  %millisecond
        timeZone);
    
    disp('Inserting Epoch...');
    epoch = container.insertEpoch(inputSources,...
        [],...
        start,...
        start.plusSeconds(duration),...
        protocol,...
        protocolParameters,...
        java.util.HashMap()... % No additional device parameters
        );
    
    
    % Add a CSV measurement for the ArenaFrame
    disp('Inserting ArenaFrame CSV measurement...');
    epoch.insertMeasurement(protocolParameters.get('ArenaFrame.Frame.0'),...
        array2set({'subject'}),...
        array2set({arenaDeviceName}),...
        java.io.File(arenaCsvPath).toURI().toURL(),...
        'application/csv');
    
    % Add measurements for room and arena-frame images
    disp('Inserting ArenaFrame image measurement...');
    epoch.insertMeasurement([char(protocolParameters.get('ArenaFrame.Frame.0')) ' Image'],...
        array2set({'subject'}),...
        array2set({arenaImageDeviceName}),...
        java.io.File(arenaFrameImagePath).toURI().toURL(),...
        imageContentType);
    
    % Add a CSV measurement for the RoomFrame
    disp('Inserting RoomFrame CSV measurement...');
    epoch.insertMeasurement(protocolParameters.get('RoomFrame.Frame.0'),...
        array2set({'subject'}),...
        array2set({arenaDeviceName}),...
        java.io.File(roomCsvPath).toURI().toURL(),...
        'application/csv');
    
    
    disp('Inserting RoomFrame image measurement...');
    epoch.insertMeasurement([char(protocolParameters.get('RoomFrame.Frame.0')) ' Image'],...
        array2set({'subject'}),...
        array2set({arenaImageDeviceName}),...
        java.io.File(roomFrameImagePath).toURI().toURL(),...
        imageContentType);
    
    delete(arenaCsvPath);
    delete(roomCsvPath);
    
    disp('Waiting for all cloud uploads to finish...');
    epoch.getDataContext().getFileService().waitForPendingUploads(60, java.util.concurrent.TimeUnit.MINUTES);
    
end



% %%BEGIN_HEADER
% 	%%BEGIN DATABASE_INFORMATION <== Epoch
% 		%Date.0 ( 6.6.2013 )
% 		%Time.0 ( 4:20 PM )
% 	%%END DATABASE_INFORMATION
% 	%%BEGIN SETUP_INFORMATION <== Protocol Parameters
% 		%TrackerVersion.0 ( Tracker version 2.36 release 4.6.2013 )
% 		%ElapsedTime_ms.0 ( 900033 )
% 		%Paradigm.0 ( PlaceAvoidance )
% 		%ShockParameters.0 ( 500 500 1500 1500 )
% 			// %ShockParameters.0 ( EntranceLatency ShockDuration InterShockLatency OutsideRefractory )
% 		%ElapsedPath_m.0 ( 82.52 )
% 		%ArenaDiameter_m.0 ( 0.82 )
% 		%TrackerResolution_PixPerCM.0 ( 3.1220 )
% 		%ArenaCenterXY.0 ( 127.5 127.5 )
% 		%Frame.0 ( RoomFrame )
% 		%ReinforcedSector.0 ( 90 60 0.0000 127.5000  )
% 			//%ReinforcedSector.0 ( CenterAngle Width InnerRadius OuterRadius )
% 		%RoomTrackReinforcedSector.0 ( 90 60 0.0000 127.5000  )
% 			//%ReinforcedSector.0 ( CenterAngle Width InnerRadius OuterRadius )
% 	%%END SETUP_INFORMATION
% 	%%BEGIN RECORD_FORMAT <== CSV relabeling
% 		%Sample.0 ( FrameCount 1msTimeStamp RoomX RoomY Sectors State CurrentLevel MotorState Flags FrameInfo )
% 			//Sectors indicate if the object is in a sector. Number is binary coded. Sectors = 0: no sector, Sectors = 1: room sector, Sectors: = 2 arena sector, Sectors: = 3 room and arena sector
% 			//State indicates the Avoidance state: OutsideSector = 0, EntranceLatency = 1, Shock = 2, InterShockLatency = 3, OutsideRefractory = 4, BadSpot = 5
% 			//MotorState indicates: NoMove = 0, MoveCW = positive, MoveCCW = negative
% 			//ShockLevel indicates the level of shock current: NoShock = 0, CurrentLevel = other_values
% 			//FrameInfo indicates succesfuly tracked spots: ReferencePoint * 2^0 + Spot0 * 2^(1+0) + Spot1 * 2^(1+1) + Spot2 * 2^(1+2) ....
% 	%%END RECORD_FORMAT
% %%END_HEADER