



classdef EmbeddedToolDriverQsys<hdlturnkey.tool.EmbeddedToolDriver


    properties


        hQuartus=[];
        hQsys=[];
    end

    methods

        function obj=EmbeddedToolDriverQsys(hIP)


            obj=obj@hdlturnkey.tool.EmbeddedToolDriver(hIP);

            obj.hQuartus=hdlturnkey.tool.QuartusEmbeddedTool(obj);
            obj.hQsys=hdlturnkey.tool.QsysEmbeddedTool(obj);


            initParameter(obj);

        end

        function[status,result]=runCreateProject(obj)



            validateCell=obj.hIP.validateRDPlugin;

            result='';

            [status,result_run]=obj.hQuartus.runCreateProject;
            result=sprintf('%s%s',result,result_run);
            if~status

                result=obj.runCreateProjectProcessResult(...
                status,result,validateCell);
                return;
            end


            [status,result_run]=obj.hQsys.runCreateProject;
            result=sprintf('%s%s',result,result_run);

            if~status

                result=obj.runCreateProjectProcessResult(...
                status,result,validateCell);
                return;
            end


            [status,result_run]=obj.hQsys.runBuild;
            result=sprintf('%s%s',result,result_run);


            result=obj.runCreateProjectProcessResult(...
            status,result,validateCell);
        end

        function[status,result,validateCell]=runEmbeddedSystemBuild(obj)


            if obj.hIP.getEmbeddedExternalBuild
                runExtShell=true;
            else
                runExtShell=false;
            end

            result='';


            [status,result_run]=obj.hQuartus.runBuild(runExtShell);


            validateCell=obj.displayMessagesEmbeddedSystemBuild(runExtShell,status);

            result=sprintf('%s%s',result,result_run);
            if~status

                return;
            end
            bitstreamPath=obj.hQuartus.getBitstreamPath;
            binPath=obj.hQuartus.getBinPath;
            if exist(binPath,'file')
                result=sprintf('%s\nThe generated bitstream files are located at:\n%s\n%s\n',...
                result,bitstreamPath,binPath);
            else
                result=sprintf('%s\nThe generated bitstream file is located at:\n%s\n',...
                result,bitstreamPath);
            end

        end

        function path=getBitstreamPath(obj)
            path=obj.hQuartus.getBitstreamPath;
        end

        function name=getToolProjectFileName(obj)

            name=obj.hQuartus.getProjectFileName;
        end

        function name=getBitstreamNameWithtimingfail(obj)
            name=[obj.hQuartus.ProjectName,obj.hQuartus.TimingFailurePostfix,'.',obj.hQuartus.BitStreamFileExt];
        end

        function name=getTimingReportPath(obj)
            name=[obj.hQuartus.getProjectFolder,'/',obj.hQuartus.ProjectName,'.sta.rpt'];
            name=downstream.tool.filterBackSlash(name);
        end

        function name=getTimingReportPathCopy(obj)
            name=[obj.hQuartus.getProjectFolder,'/',obj.hQuartus.ProjectName,'.timingerror.rpt'];
            name=downstream.tool.filterBackSlash(name);
        end

        function name=getTimingReportNameCopy(obj)
            name=[obj.hQuartus.ProjectName,'.timingerror.rpt'];
        end
    end


    methods(Access=protected)

        function updateToolProjectFolder(obj)

            obj.ProjectFolder=obj.hQuartus.getProjectFolder;
            obj.hQsys.setProjectFolder(obj.hQuartus.getRelProjectFolder)
        end

        function checkToolPath(obj)

            obj.hQuartus.checkToolPath;
            obj.hQsys.checkToolPath;
        end

        function[CmdStr,projectPath]=getTargetToolOpenCmdStr(obj)

            [CmdStr,projectPath]=obj.getToolOpenCmdStr(obj.hQuartus);
        end

        function[status,result]=programBitstreamJTAGMode(obj,bitstreamPath)%#ok<INUSD>
            [status,result]=obj.hQuartus.downloadBitstream;
        end

        function[status,result]=programBitstreamDownloadMode(obj,bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName)%#ok<INUSL>
            hRD=obj.getRDPlugin;
            generateSplitBitstream=hRD.GenerateSplitBitstream;

            rbfBitstream=obj.hQuartus.getBinPath;
            if generateSplitBitstream
                [bitstreamDir,bitstreamName,~]=fileparts(bitstreamPath);
                core_rbf=[bitstreamName,'.core.rbf'];
                periph_rbf=[bitstreamName,'.periph.rbf'];
                corePath=fullfile(bitstreamDir,core_rbf);
                periphPath=fullfile(bitstreamDir,periph_rbf);

                if~isfile(corePath)||~isfile(periphPath)
                    error(message('hdlcommon:workflow:SplitBitstreamFailure',corePath,periphPath));
                end
            elseif~exist(rbfBitstream,'file')
                error(message('hdlcoder:workflow:RBFFileDoesNotExist',rbfBitstream));
            end

            [status,result]=hdlturnkey.tool.downloadAlteraSoCBitstreamToSD(rbfBitstream,deviceTreePath,systemInitPath,referenceDesignName,generateSplitBitstream);








        end

    end


    methods(Access=protected)

        function initParameter(obj)

            obj.EmbeddedToolName=obj.hQuartus.DisplayName;


            obj.updateToolProjectFolder;


            obj.checkToolPath;
        end

        function[CmdStr,projectPath]=getToolOpenCmdStr(obj,hTool)



            projectPath=fullfile(hTool.getProjectFolder,hTool.getProjectFileName);


            toolCmdStr=fullfile(hTool.ToolPath,hTool.GUICmdStr);


            ipRepositoryPath=obj.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                ipRepositoryFolder=obj.hQsys.getQsysIPRepositoryFolder(ipRepositoryPath);
                CmdStr=sprintf('%s %s --search-path=%s,$ &',...
                toolCmdStr,hTool.getProjectFileName,ipRepositoryFolder);
            else
                CmdStr=sprintf('%s %s &',toolCmdStr,hTool.getProjectFileName);
            end
        end

        function projectLink=getOpenToolLink(obj,hTool)

            [cmdStr,projectPath]=obj.getToolOpenCmdStr(hTool);
            projectLink=sprintf(...
            '<a href="matlab:downstream.tool.openTargetTool(''%s'',''%s'',%d);">%s</a>',...
            cmdStr,projectPath,obj.getDIObject.cmdDisplay,projectPath);
        end

        function result=runCreateProjectProcessResult(obj,status,result,validateCell)

            if status

                linkStrQsys=sprintf('Generated %s project:\n%s\n',obj.hQsys.DisplayName,obj.getOpenToolLink(obj.hQsys));
                linkStrQuartus=sprintf('Generated %s project:\n%s\n\n',obj.hQuartus.DisplayName,obj.getOpenToolLink(obj.hQuartus));
                if obj.getDIObject.isMLHDLC

                    result=sprintf('%s%s%s',result,linkStrQsys,linkStrQuartus);
                else

                    result=sprintf('%s%s%s',linkStrQsys,linkStrQuartus,result);
                end




                if~isempty(validateCell)
                    msgStr=downstream.tool.publishValidateCell(validateCell);
                    result=sprintf('%s\n\n%s',msgStr,result);
                end
            end
        end

    end

end


