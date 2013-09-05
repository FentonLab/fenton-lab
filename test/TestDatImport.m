% Copyright (c) 2013 Physion Consulting LLC

classdef TestDatImport < MatlabTestCase
    
    methods
        
        function self = TestDatImport(name)
            self = self@MatlabTestCase(name);
        end
        
        % Smoke test for dat import
        function testImportsDatSmoke(self)
            import ovation.*;
            

            project = self.context.insertProject('testConvertsData', 'testConvertsData', datetime());
            source = self.context.insertSource('test-source', 'test-source');
            protocol = self.context.insertProtocol('test-protocol', 'test protocol for dat import');

            experiment = project.insertExperiment('test-experiment', datetime());
            epoch = import_fenton_dat(source,...
                experiment,...
                protocol,...
                'arena',... % arena device name
                'camera',... % image device name
                'America/New_York',... % time zone
                600,... % duration seconds
                'fixtures/bl1/bl1D1Train1_Arena.dat',... %Arena frame dat path
                'fixtures/bl1/bl1D1Train1_Arena.png',... %Arena frame image path
                'fixtures/bl1/bl1D1Train1_Room.dat',... %Room frame dat path
                'fixtures/bl1/bl1D1Train1_Room.png',... %Room frame image path
                'image/png'... % image content type
                );

            assert(~isempty(epoch));

        end
        
        function testBatchImport(self)
            protocols.Hab = 'Hab protocol';
            protocols.Retest = 'Retest protocol';
            protocols.Train1 = 'Train1 protocol';
            protocols.Train2 = 'Train2 protocol';
            protocols.Train3 = 'Train3 protocol';
            
            egroup = ctx.getObjectWithURI('ovation://03d83127-4ac1-4ec0-8272-1e310c527376/');
            
            epochsMap = batch_dat_import(ctx, egroup, protocols, 'America/New_York', designFile, '/Users/barry/development/fenton-lab/test/fixtures/batch/DATfiles');
            
            assert(epochsMap.size() == 20); % 2 per Epoch
        end
    end
end