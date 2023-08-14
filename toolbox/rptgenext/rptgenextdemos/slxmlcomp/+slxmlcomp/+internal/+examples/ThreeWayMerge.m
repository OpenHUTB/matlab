

classdef ThreeWayMerge<handle

    properties(Access=private,Constant)
        ConflictedFileName='slproject_f14';
    end

    methods(Access=public,Static)

        function doBaseProjectEdit(projectRoot)

            modelPath=slxmlcomp.internal.examples.ThreeWayMerge.getConflictedFile(projectRoot);

            mdlHandle=load_system(modelPath);
            modelCleanup=onCleanup(@()close_system(mdlHandle));

            save_system(mdlHandle);
        end

        function doMineProjectEdit(projectRoot)

            modelPath=slxmlcomp.internal.examples.ThreeWayMerge.getConflictedFile(projectRoot);

            mdlHandle=load_system(modelPath);
            modelCleanup=onCleanup(@()close_system(mdlHandle));

            set_param(mdlHandle,'StopTime','5');
            save_system(mdlHandle);

        end

        function doTheirsProjectEdit(projectRoot)

            import slxmlcomp.internal.examples.ThreeWayMerge;
            modelPath=ThreeWayMerge.getConflictedFile(projectRoot);

            mdlHandle=load_system(modelPath);
            modelCleanup=onCleanup(@()close_system(mdlHandle));

            set_param(mdlHandle,'StopTime','15');
            pilotSubsystem=[ThreeWayMerge.ConflictedFileName,'/Pilot'];
            pilotBlock='Pilot';
            newGain='PilotGain';
            busCreator=sprintf('Bus\nCreator');

            fullNewGainPath=[pilotSubsystem,'/',newGain];
            add_block('built-in/Gain',fullNewGainPath);
            set_param(fullNewGainPath,'Position','[160 90 210 140]');
            set_param(fullNewGainPath,'Gain','2');

            delete_line(pilotSubsystem,[pilotBlock,'/1'],[busCreator,'/1']);
            add_line(pilotSubsystem,[pilotBlock,'/1'],[newGain,'/1']);
            add_line(pilotSubsystem,[newGain,'/1'],[busCreator,'/1']);


            gainPortHandles=get_param(fullNewGainPath,'PortHandles');
            set_param(gainPortHandles.Outport,'Name','StickCommand_rad');

            pilotBlockPortHandles=get_param([pilotSubsystem,'/Pilot'],'PortHandles');
            set_param(pilotBlockPortHandles.Outport,'Name','Pilot Output');


            save_system(mdlHandle);

        end

        function filePath=getConflictedFile(projectRoot)
            import slxmlcomp.internal.examples.ThreeWayMerge;

            filePath=fullfile(...
            projectRoot,...
            'models',...
            [ThreeWayMerge.ConflictedFileName,'.slx']...
            );
        end

    end

end