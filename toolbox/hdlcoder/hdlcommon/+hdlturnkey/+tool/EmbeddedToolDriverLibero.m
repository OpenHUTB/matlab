



classdef EmbeddedToolDriverLibero<hdlturnkey.tool.EmbeddedToolDriver


    properties


        hLibero=[];
    end

    methods

        function obj=EmbeddedToolDriverLibero(hIP)


            obj=obj@hdlturnkey.tool.EmbeddedToolDriver(hIP);

            obj.hLibero=hdlturnkey.tool.LiberoEmbeddedTool(obj);
        end

        function[status,result]=runCreateProject(obj)



            validateCell=obj.hIP.validateRDPlugin;


            [status,result]=obj.hLibero.runCreateProject;

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


            [status,result_run]=obj.hLibero.runBuild(runExtShell);

            validateCell=obj.displayMessagesEmbeddedSystemBuild(runExtShell,status);

            result=sprintf('%s%s',result,result_run);
            if~status

                return;
            end
        end

        function path=getBitstreamPath(obj)
            path=obj.hLibero.getBitstreamPath;
        end

        function name=getToolProjectFileName(obj)

            name=obj.hLibero.getProjectFileName;
        end

        function name=getBitstreamNameWithtimingfail(obj)
            name=[obj.hLibero.ProjectName,obj.hLibero.TimingFailurePostfix,'.',obj.hLibero.BitStreamFileExt];
        end

        function name=getTimingReportPath(obj)
            name=[obj.hLibero.getProjectFolder,'/',obj.hLibero.ProjectName,'.sta.rpt'];
            name=downstream.tool.filterBackSlash(name);
        end

        function name=getTimingReportPathCopy(obj)
            name=[obj.hLibero.getProjectFolder,'/',obj.hLibero.ProjectName,'.timingerror.rpt'];
            name=downstream.tool.filterBackSlash(name);
        end

        function name=getTimingReportNameCopy(obj)
            name=[obj.hLibero.ProjectName,'.timingerror.rpt'];
        end

        function ret=enableObjective(~)

            ret=false;
        end
    end


    methods(Access=protected)

        function updateToolProjectFolder(obj)

            obj.ProjectFolder=obj.hLibero.getProjectFolder;
        end

        function checkToolPath(obj)

            obj.hLibero.checkToolPath;
        end

        function[CmdStr,projectPath]=getTargetToolOpenCmdStr(obj)

            [CmdStr,projectPath]=obj.getToolOpenCmdStr(obj.hLibero);
        end

        function[status,result]=programBitstreamJTAGMode(obj,bitstreamPath)%#ok<INUSD>
            [status,result]=obj.hLibero.downloadBitstream;
        end

        function[status,result]=programBitstreamDownloadMode(obj,bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName)

        end
    end


    methods(Access=protected)

        function initParameter(obj)

            obj.EmbeddedToolName=obj.hLibero.DisplayName;


            obj.updateToolProjectFolder;


            obj.checkToolPath;
        end

        function[CmdStr,projectPath]=getToolOpenCmdStr(obj,hTool)



            projectPath=fullfile(hTool.getProjectFolder,hTool.ProjectName,hTool.getProjectFileName);


            toolCmdStr=obj.hLibero.getToolPath;


            ipRepositoryPath=obj.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                ipRepositoryFolder=obj.hLibero.getLiberoIPRepositoryFolder(ipRepositoryPath);
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

                linkStrLibero=sprintf('\nGenerated %s project:\n%s\n',obj.hLibero.DisplayName,obj.getOpenToolLink(obj.hLibero));

                result=sprintf('%s%s',linkStrLibero,result);




                if~isempty(validateCell)
                    msgStr=downstream.tool.publishValidateCell(validateCell);
                    result=sprintf('%s\n\n%s',msgStr,result);
                end
            end
        end

    end


    methods
        function validateCell=displayMessagesEmbeddedSystemBuild(obj,runExtShell,status)

            validateCell={};
            hDI=obj.hIP.hD;
            projectDir=fullfile(pwd,hDI.getProjectPath);
            if exist(obj.getTimingFailBitStreamPath,'file')
                timingFailFlag=1;
                bitgenDone=1;
            elseif exist(obj.getBitStreamPath,'file')
                timingFailFlag=0;
                bitgenDone=1;
            else
                timingFailFlag=0;
                bitgenDone=0;
            end








            if runExtShell&&status
                msg1=message('hdlcommon:workflow:RunExtWarningLibero',projectDir,obj.getBitStreamPath).getString;
                validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunExtWarning',msg1));
                validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunExtWarning2',obj.getTimingFailBitStreamPath,obj.getTimingFailureArticleLink,obj.getTimingReportLink));
            end




            if~runExtShell&&~timingFailFlag
                msg1=message('hdlcommon:workflow:RunIntTimingPass1',obj.getTimingReportLink).getString;
                msg2=message('hdlcommon:workflow:RunIntTimingPass2',obj.getBitStreamPath).getString;
                msg=[msg1,msg2];
                validateCell{end+1}=hdlvalidatestruct('',message('hdlcommon:workflow:RunIntTimingPass',msg));
            end



            if~runExtShell&&~bitgenDone
                validateCell={};
            end


            if timingFailFlag


                if obj.reportTimingFailAsWarning


                    delete(obj.getTimingFailBitStreamPath);
                    for ii=1:length(validateCell)
                        validateCell{ii}.Status='Warning';
                    end
                else


                    delete(obj.getBitStreamPath);
                end
            end
        end
    end

end

