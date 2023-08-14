


classdef FileKeeper



    properties(Constant=true)

        HMI_PARENT_ID='blockDiagram';
        HMI_PARENT_IN_SLX='/simulink/blockdiagram.xml';
        SIMULINK_HARNESS_ROOT='/simulink/';
        HMI_PATH='/hmi/';
        TEST_HARNESS_PARENT_PART='/simulink/blockdiagram.xml';


        WEBHMI_FILENAME='webhmi';
        WEBHMI_FILEEXT='mat';
        WEBHMI_REL='http://schemas.mathworks.com/simulinkModel/2014/relationships/WebHMI';
        WEBHMI_ID='WebHMI';
        WEBHMI_CONTENT_TYPE=...
        'application/vnd.mathworks.matlab.mat+binary';
    end


    methods(Static)

        function filename=getWebHMIRelTarget()

            import Simulink.HMI.Utils.FileKeeper;
            filename=[FileKeeper.HMI_PATH...
            ,FileKeeper.WEBHMI_FILENAME,'.'...
            ,FileKeeper.WEBHMI_FILEEXT];
        end

        function fileName=getWebHMIHarnessRelTarget(harnessId)
            import Simulink.HMI.Utils.FileKeeper;
            fileName=[FileKeeper.SIMULINK_HARNESS_ROOT...
            ,harnessId...
            ,FileKeeper.HMI_PATH...
            ,FileKeeper.WEBHMI_FILENAME,'.'...
            ,FileKeeper.WEBHMI_FILEEXT];
        end

        function harnessRelId=getWebHMIHarnessRelId(harnessId)
            import Simulink.HMI.Utils.FileKeeper;
            harnessRelId=[FileKeeper.WEBHMI_REL,'/',harnessId];
        end


        function filename=getWebHMITarget(modelHandle)

            import Simulink.HMI.Utils.FileKeeper;
            filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,FileKeeper.getWebHMIRelTarget());
        end


        function filename=getWebHMIHarnessTarget(modelHandle,harnessId)

            import Simulink.HMI.Utils.FileKeeper;
            filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,...
            FileKeeper.getWebHMIHarnessRelTarget(harnessId));
        end
    end
end


