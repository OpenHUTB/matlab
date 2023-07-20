



classdef EmbeddedToolDriverEDK<hdlturnkey.tool.EmbeddedToolDriver


    properties


        hEDK=[];
        hPA=[];
        hBootGen=[];

    end

    methods

        function obj=EmbeddedToolDriverEDK(hIP)


            obj=obj@hdlturnkey.tool.EmbeddedToolDriver(hIP);

            obj.hEDK=hdlturnkey.tool.EDKTool(obj);
            obj.hPA=hdlturnkey.tool.PlanAheadTool(obj);
            obj.hBootGen=hdlturnkey.tool.BootGenTool(obj);


            initParameter(obj);

        end

        function[status,result]=runCreateProject(obj)



            validateCell=obj.hIP.validateRDPlugin;


            [status1,result1]=obj.hEDK.runCreateProject;
            if~status1
                status=status1;
                result=result1;
                return;
            end


            [status2,result2]=obj.hPA.runCreateProject;
            status=status1&&status2;
            result=sprintf('%s%s',result1,result2);


            result=obj.runCreateProjectProcessResult(...
            status,result,validateCell);
        end

        function[status,result,validateCell]=runEmbeddedSystemBuild(obj)


            if obj.hIP.getEmbeddedExternalBuild
                runExtShell=true;
            else
                runExtShell=false;
            end
            validateCell={};

            [status,result]=obj.hPA.runBuild(runExtShell);
            bitstreamPath=obj.hPA.getBitstreamPath;
            result=sprintf('%s\nThe generated bitstream file is located at: %s.\n',...
            result,bitstreamPath);

        end

        function path=getBitstreamPath(obj)
            path=obj.hPA.getBitstreamPath;
        end
        function name=getToolProjectFileName(obj)

            name=obj.hPA.getProjectFileName;
        end
    end


    methods(Access=protected)

        function updateToolProjectFolder(obj)

            obj.ProjectFolder=obj.hPA.getProjectFolder;
        end

        function checkToolPath(obj)

            obj.hEDK.checkToolPath;
            obj.hPA.checkToolPath;
            obj.hBootGen.checkToolPath;
        end

        function[CmdStr,projectPath]=getTargetToolOpenCmdStr(obj)



            projectPath=fullfile(obj.getToolProjectFolder,obj.getToolProjectFileName);


            toolCmdStr=fullfile(obj.hPA.ToolPath,obj.hPA.GUICmdStr);
            CmdStr=sprintf('%s %s &',toolCmdStr,obj.getToolProjectFileName);
        end

        function[status,result]=programBitstreamJTAGMode(obj,bitstreamPath)

            edkToolPath=obj.hEDK.ToolPath;

            chainPosition=obj.hIP.hD.hTurnkey.hBoard.JTAGChainPosition;
            [status,result]=hdlturnkey.tool.EDKTool.downloadBit(bitstreamPath,edkToolPath,chainPosition);
        end

        function[status,result]=programBitstreamDownloadMode(obj,bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName)%#ok<INUSL>

            [status,result]=hdlturnkey.tool.downloadZynqBitstreamToSD(bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName);
        end

    end


    methods(Access=protected)

        function initParameter(obj)

            obj.EmbeddedToolName=obj.hPA.DisplayName;


            obj.updateToolProjectFolder;


            obj.checkToolPath;
        end

        function[status,result]=runBootFromSD(obj)
            bitstreamPath=obj.hPA.getBitstreamPath;
            [status,result]=obj.hBootGen.runBootGen(bitstreamPath);
            bootFilePath=obj.hBootGen.getBootFilePath;
            result=sprintf('%s\nThe generated Zynq Boot Image file (%s) is located at: %s. \nPlease copy it to the SD card and reboot the Zynq board.\n',...
            result,obj.hBootGen.BootFileName,bootFilePath);














        end

    end

end



