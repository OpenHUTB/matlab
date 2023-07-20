classdef VisionDetectionGeneratorCallbacks
    methods(Access=public,Static)
        function setSeedVisibility(block)
            seedHandle=...
            Simulink.Mask.get(block).getParameter("InitialSeed");

            seedHandle.Visible="off";
            if strcmp(get_param(block,'InitialSeedSource'),"Specify seed")
                seedHandle.Visible="on";
            end
        end

        function setLaneAndObjectFieldVisibility(block)
            sim3d.utils.internal.VisionDetectionGeneratorCallbacks.setDependentFieldVisibility(block,"object",["MaxNumDetections","ObjectDetectorSettingsContainer","BusNameSource","BusName"]);
            sim3d.utils.internal.VisionDetectionGeneratorCallbacks.setDependentFieldVisibility(block,"lane",["MaxNumLanes","laneSampleDistances","LaneDetectorSettingsContainer","BusName2Source","BusName2"]);
        end

        function setDependentFieldVisibility(block,outputType,dependentFields)
            outputVisibile=sim3d.utils.internal.VisionDetectionGeneratorCallbacks.fieldVisibility(block,outputType);

            maskHandle=Simulink.Mask.get(block);
            for field=dependentFields
                if contains(field,"Container")
                    fieldHandle=maskHandle.getDialogControl(field);
                else
                    fieldHandle=maskHandle.getParameter(field);
                end
                fieldHandle.Visible=outputVisibile;
            end
        end

        function setBusNameFieldVisibility(block,busName)
            maskHandle=Simulink.Mask.get(block);

            busNameHandle=maskHandle.getParameter(busName);
            busNameSourceHandle=maskHandle.getParameter(busName+"Source");

            busNameHandle.Visible="off";
            if strcmp(busNameSourceHandle.Visible,"on")&&~strcmp(busNameSourceHandle.Value,"Auto")
                busNameHandle.Visible="on";
            end
        end

        function visibility=fieldVisibility(block,outputType)
            detectorOutput=get_param(block,"DetectorOutput");
            visibility="off";
            if contains(lower(detectorOutput),outputType)
                visibility="on";
            end
        end
    end
end