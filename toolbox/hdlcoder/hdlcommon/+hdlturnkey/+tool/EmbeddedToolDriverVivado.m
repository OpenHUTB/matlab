


classdef EmbeddedToolDriverVivado<hdlturnkey.tool.EmbeddedToolDriver


    properties


        hVA=[];

    end


    methods

        function obj=EmbeddedToolDriverVivado(hIP)


            obj=obj@hdlturnkey.tool.EmbeddedToolDriver(hIP);

            obj.hVA=hdlturnkey.tool.VivadoTool(obj);


            initParameter(obj);

        end

        function[status,result]=runCreateProject(obj)



            validateCell=obj.hIP.validateRDPlugin;


            [status,result]=obj.hVA.runCreateProject;


            result=obj.runCreateProjectProcessResult(...
            status,result,validateCell);
        end

        function[status,result,validateCell]=runEmbeddedSystemBuild(obj)


            if obj.hIP.getEmbeddedExternalBuild
                runExtShell=true;
            else
                runExtShell=false;
            end


            [status,result]=obj.hVA.runBuild(runExtShell);


            validateCell=obj.displayMessagesEmbeddedSystemBuild(runExtShell,status);

        end

        function path=getBitstreamPath(obj)
            path=obj.hVA.getBitstreamPath;
        end

        function name=getToolProjectFileName(obj)

            name=obj.hVA.getProjectFileName;
        end

        function name=getBitstreamNameWithtimingfail(obj)

            name=[obj.hVA.getbitstreamFileName,obj.hVA.TimingFailurePostfix,'.',obj.hVA.BitStreamFileExt];
        end

        function name=getTimingReportPath(obj)

            name=[obj.hVA.getProjectFolder,'/',obj.hVA.getBitstreamFolderPath,'/',obj.hVA.getbitstreamFileName,'_timing_summary_routed.rpt'];
        end

        function val=getUseIPCache(obj)
            val=obj.hVA.getUseIPCache;
        end

        function msg=checkUseIPCache(obj,val)




            msg=[];
            hRD=obj.hIP.getReferenceDesignPlugin;


            if val&&str2double(obj.hIP.hD.getToolVersion)<2015.4
                error(message('hdlcommon:workflow:VivadoToolGtr20154',obj.hIP.hD.getToolName,obj.hIP.hD.getToolVersion));
            end

            if~val&&~isempty(hRD)&&~isempty(hRD.IPCacheZipFile)
                msg=message('hdlcommon:workflow:UseIPCacheMustBeTrue',hRD.ReferenceDesignName);
                if obj.getDIObject.cmdDisplay
                    warning(msg);
                end
            end

            if val&&~isempty(hRD)&&hRD.DisableIPCache
                error(message('hdlcommon:workflow:UseIPCacheMustBeFalse',hRD.ReferenceDesignName));
            end

            if val&&~isempty(hRD)&&~isempty(hRD.IPCacheZipFile)
                filePath=hRD.getFilePathFromRD(hRD.IPCacheZipFile);
                if~exist(filePath,'file')
                    msg=message('hdlcommon:plugin:IPCacheZipFileNotExist',hRD.IPCacheZipFile);
                    if obj.getDIObject.cmdDisplay
                        warning(msg);
                    end
                end
            end
        end
        function setUseIPCache(obj,val)
            obj.checkUseIPCache(val);
            obj.hVA.setUseIPCache(val);
        end

        function ret=enableUseIPCache(obj)
            hRD=obj.hIP.getReferenceDesignPlugin;

            if~isempty(hRD)&&hRD.DisableIPCache
                ret=false;
            else
                ret=true;
            end
        end
        function ret=getDefaultUseIPCache(obj)
            hRD=obj.hIP.getReferenceDesignPlugin;


            if~isempty(hRD)&&~isempty(hRD.IPCacheZipFile)
                ret=true;
            else
                ret=false;
            end
        end
    end


    methods(Access=protected)

        function updateToolProjectFolder(obj)

            obj.ProjectFolder=obj.hVA.getProjectFolder;
        end

        function checkToolPath(obj)

            obj.hVA.checkToolPath;
        end

        function[CmdStr,projectPath]=getTargetToolOpenCmdStr(obj)



            projectPath=fullfile(obj.getToolProjectFolder,obj.getToolProjectFileName);


            toolCmdStr=fullfile(obj.hVA.ToolPath,obj.hVA.GUICmdStr);
            CmdStr=sprintf('%s %s &',toolCmdStr,obj.getToolProjectFileName);
        end

        function[status,result]=programBitstreamJTAGMode(obj,bitstreamPath)%#ok<INUSD>
            [status,result]=obj.hVA.downloadBitstreamJTAG;
        end

        function[status,result]=programBitstreamDownloadMode(obj,bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName)%#ok<INUSL>

            [status,result]=hdlturnkey.tool.downloadZynqBitstreamToSD(bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName);
        end

    end


    methods(Access=protected)

        function initParameter(obj)

            obj.EmbeddedToolName=obj.hVA.DisplayName;


            obj.updateToolProjectFolder;


            obj.checkToolPath;
        end

    end

end




