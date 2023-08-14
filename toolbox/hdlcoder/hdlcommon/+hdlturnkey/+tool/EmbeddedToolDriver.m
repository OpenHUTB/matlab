




classdef(Abstract)EmbeddedToolDriver<handle






    properties


        hIP=[];

    end

    properties(Access=protected)

        EmbeddedToolName='';

        ProjectFolder='';

        OperatingSystem='';
        OperatingSystemList={''};

        ProgrammingMethod hdlcoder.ProgrammingMethod
        ProgrammingMethodList hdlcoder.ProgrammingMethod
    end

    methods
        function obj=EmbeddedToolDriver(hIP)

            obj.hIP=hIP;
        end
    end


    methods(Abstract)

        [status,result]=runCreateProject(obj)

        [status,result,validateCell]=runEmbeddedSystemBuild(obj)
    end


    methods

        function ret=getUseIPCache(~)
            ret=false;
        end

        function msg=checkUseIPCache(~,~)
            msg=[];
        end

        function setUseIPCache(obj,val)
            if val
                error(message('hdlcommon:workflow:VivadoToolGtr20154',obj.hIP.hD.getToolName,obj.hIP.hD.getToolVersion));
            end
        end

        function ret=enableUseIPCache(~)
            ret=false;
        end

        function ret=getDefaultUseIPCache(~)
            ret=false;
        end

        function ret=enableObjective(~)
            ret=true;
        end

        function tool=getEmbeddedTool(obj)
            tool=obj.EmbeddedToolName;
        end
        function projectLink=getOpenProjectLink(obj)

            [cmdStr,projectPath]=obj.getTargetToolOpenCmdStr;
            projectLink=sprintf(...
            '<a href="matlab:downstream.tool.openTargetTool(''%s'',''%s'',%d);">%s</a>',...
            cmdStr,projectPath,obj.getDIObject.cmdDisplay,projectPath);
        end
        function folder=getToolProjectFolder(obj)

            updateToolProjectFolder(obj);
            folder=obj.ProjectFolder;
        end


        function os=getOperatingSystem(obj)
            os=obj.OperatingSystem;
        end
        function oslist=getOperatingSystemAll(obj)
            oslist=obj.OperatingSystemList;
        end
        function setOperatingSystem(obj,os)
            obj.OperatingSystem=os;
            obj.loadECoderSPSettings;
        end

        function loadECoderSPSettings(obj)
            defaultOS='';
            osList={''};
            hD=obj.getDIObject;
            hBoard=obj.getBoardObject;
            boardName=hBoard.BoardName;


            if isempty(obj.OperatingSystem)
                if hD.isXilinxIP
                    if hdlturnkey.isECoderZynqSPInstalled
                        [defaultOS,osList]=codertarget.zynq.internal.getSupportedOS(boardName);
                    end
                else
                    if hdlturnkey.isECoderAlteraSoCSPInstalled
                        [defaultOS,osList]=codertarget.alterasoc.internal.getSupportedOS(boardName);
                    end
                end
                if isempty(osList)










                    defaultOS='Linux';
                    osList={'Linux'};
                end
                obj.OperatingSystem=defaultOS;
                obj.OperatingSystemList=osList;
            end

        end


        function validateCell=displayMessagesEmbeddedSystemBuild(obj,runExtShell,status)

            validateCell={};

            if obj.hIP.hD.getEnableDesignCheckpoint
                if strcmp(obj.hIP.hD.getDefaultCheckpointFile,'Default')
                    validateCell{end+1}=hdlvalidatestruct('',message('hdlcommon:workflow:DefaultDCPInfo'));
                end
                if strcmp(obj.hIP.hD.getDefaultCheckpointFile,'Custom')
                    validateCell{end+1}=hdlvalidatestruct('',message('hdlcommon:workflow:CustomDCPInfo'));
                end
            end


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






            if~runExtShell&&timingFailFlag
                msg1=message('hdlcommon:workflow:RunIntTimingFail1').getString;
                msg2=message('hdlcommon:workflow:RunIntTimingFail2',obj.getTimingFailureArticleLink,obj.getTimingReportLink).getString;
                msg3=message('hdlcommon:workflow:RunIntTimingFail3',obj.getTimingFailBitStreamPath).getString;
                if obj.reportTimingFailAsWarning
                    msg=[msg1,msg2];
                else
                    msg=[msg1,msg2,msg3];
                end
                validateCell{end+1}=hdlvalidatestruct('Error',message('hdlcommon:workflow:RunIntTimingFail',msg));
            end








            if runExtShell&&status
                msg1=message('hdlcommon:workflow:RunExtWarning1',obj.getBitStreamPath).getString;
                validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunExtWarning',msg1));
                validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunExtWarning2',obj.getTimingFailBitStreamPath,obj.getTimingFailureArticleLink,obj.getTimingReportLink));
                validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunExtWarning3'));
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


        function validateCell=displayMessagesProgTarget(obj)

            validateCell={};

            if obj.hIP.getEmbeddedExternalBuild
                runExtShell=true;
            else
                runExtShell=false;
            end


            if((~(exist(obj.getBitStreamPath,'file')))&&(~(exist(obj.getTimingFailBitStreamPath,'file')))&&runExtShell)

                msg=message('hdlcommon:workflow:RunExtCheckExtConsole').getString;
                validateCell{end+1}=hdlvalidatestruct('Error',message('hdlcommon:workflow:RunExtBitgenNotAvailable',msg));

            elseif exist(obj.getTimingFailBitStreamPath,'file')



                msg1=message('hdlcommon:workflow:RunIntTimingFail1').getString;
                msg2=message('hdlcommon:workflow:RunIntTimingFail2',obj.getTimingFailureArticleLink,obj.getTimingReportLink).getString;
                msg3=message('hdlcommon:workflow:RunIntTimingFail3',obj.getTimingFailBitStreamPath).getString;
                if obj.reportTimingFailAsWarning
                    msg=[msg1,msg2];
                    validateCell{end+1}=hdlvalidatestruct('Warning',message('hdlcommon:workflow:RunIntTimingFail',msg));
                else
                    msg=[msg1,msg2,msg3];
                    validateCell{end+1}=hdlvalidatestruct('Error',message('hdlcommon:workflow:RunIntTimingFail',msg));
                end
            end
        end


        function articlelink=getTimingFailureArticleLink(~)
            articleName=message('hdlcommon:workflow:TimingFailArticle').getString;
            articlePath=downstream.tool.filterBackSlash(fullfile(docroot,'hdlcoder/ug/resolve-timing-failures-in-ip-core-generation-and-generic-asicfpga-workflows.html'));
            articlelink=sprintf('<a href="matlab:web(''%s'')">%s</a>',articlePath,articleName);
        end







        function timingreportlink=getTimingReportLink(obj)
            timingReport=message('hdlcommon:workflow:TimingFailReport').getString;
            if obj.hIP.hD.isQuartus
                if exist(obj.getTimingReportPath,'file')
                    timingReportPath=downstream.tool.filterBackSlash(obj.getTimingReportPath);
                else
                    timingReportPath=downstream.tool.filterBackSlash(obj.getTimingReportPathCopy);
                end
            else
                timingReportPath=downstream.tool.filterBackSlash(obj.getTimingReportPath);
            end
            timingreportlink=sprintf('<a href="matlab:edit(''%s'')">%s</a>',timingReportPath,timingReport);
        end


        function bitstreampath=getBitStreamPath(obj)
            if obj.hIP.hD.isVivado
                bitstreampath=downstream.tool.filterBackSlash(obj.hVA.getBitstreamPath);
            elseif obj.hIP.hD.isLiberoSoc
                bitstreampath=downstream.tool.filterBackSlash(obj.hLibero.getBitstreamPath);
            else
                bitstreampath=downstream.tool.filterBackSlash(obj.hQuartus.getBitstreamPath);
            end
        end


        function bitstreampathwithtimingfail=getTimingFailBitStreamPath(obj)
            if obj.hIP.hD.isVivado
                timingfailurepostfix=obj.hVA.TimingFailurePostfix;
            elseif obj.hIP.hD.isLiberoSoc
                timingfailurepostfix=obj.hLibero.TimingFailurePostfix;
            else

                timingfailurepostfix=obj.hQuartus.TimingFailurePostfix;
            end
            bitStreamPath=obj.getBitStreamPath;
            bitstreampathwithtimingfail=[bitStreamPath(1:end-4),timingfailurepostfix,bitStreamPath(end-3:end)];
            bitstreampathwithtimingfail=downstream.tool.filterBackSlash(bitstreampathwithtimingfail);
        end


        function warnReportTimingFailure=reportTimingFailAsWarning(obj)

            hRD=obj.getRDPlugin;
            if isempty(hRD)
                warnReportTimingFailure=0;
                return;
            end
            warnReportTimingFailure=((obj.hIP.getReportTimingFailure==hdlcoder.ReportTiming.Warning)||...
            (hRD.ReportTimingFailure==hdlcoder.ReportTiming.Warning));
        end


        function[status,result,validateCell]=runEmbeddedDownloadBitstream(obj)

            validateCell=obj.displayMessagesProgTarget();




            if numel(validateCell)>0&&strcmpi(validateCell{1}.Status,'Error')
                status=false;
                result=validateCell{1}.Message;
                return;
            end



            hRD=obj.getRDPlugin;
            if hRD.BootFromSD
                [status,result]=obj.runBootFromSD;
                return;
            end

            bitstreamPath=obj.getBitstreamPath;
            switch obj.ProgrammingMethod
            case hdlcoder.ProgrammingMethod.JTAG


                if obj.hIP.hD.isProcessingSystemAvailable
                    if obj.getDIObject.cmdDisplay
                        warning(message('hdlcoder:workflow:JTAGDeprication'));
                    end
                end


                [status,result]=obj.programBitstreamJTAGMode(bitstreamPath);
            case hdlcoder.ProgrammingMethod.Download










                [status,result,validateCell2]=obj.compileDeviceTree;
                validateCell=[validateCell,validateCell2];
                if~status

                    return;
                end

                deviceTreePath=char(obj.getDeviceTreeForProgramming);
                systemInitPath=hRD.getSystemInit;
                [status,result2]=obj.programBitstreamDownloadMode(bitstreamPath,deviceTreePath,systemInitPath,hRD.ReferenceDesignName);
                result=sprintf('%s\n\n%s',result,result2);
            case hdlcoder.ProgrammingMethod.Custom

                [status,result]=hdlturnkey.plugin.runCallbackCustomProgrammingMethod(obj.getDIObject);
            end
        end

        function pm=getProgrammingMethod(obj)
            pm=obj.ProgrammingMethod;
        end
        function oslist=getProgrammingMethodAll(obj)
            oslist=obj.ProgrammingMethodList;
        end
        function setProgrammingMethod(obj,pm)
            if(~isa(pm,'hdlcoder.ProgrammingMethod'))
                error(message('hdlcoder:workflow:InvalidProgrammingMethod'));
            else


                pmList=obj.getProgrammingMethodAll;
                if~ismember(pm,pmList)
                    error(message('hdlcoder:workflow:InvalidProgrammingMethodForRD',pm.convertToString(pm)));
                end
            end
            obj.ProgrammingMethod=pm;
        end

        function refreshProgrammingMethod(obj)








            obj.ProgrammingMethodList=hdlcoder.ProgrammingMethod.JTAG;

            hDI=obj.getDIObject;
            if hDI.isProcessingSystemAvailable&&~hDI.isLiberoSoc
                obj.ProgrammingMethodList(end+1)=hdlcoder.ProgrammingMethod.Download;
            end



            hRD=obj.getRDPlugin;
            if~isempty(hRD)

                if~isempty(hRD.SupportedProgrammingMethods)
                    obj.ProgrammingMethodList=hRD.SupportedProgrammingMethods;
                end




                if~isempty(hRD.CallbackCustomProgrammingMethod)
                    obj.ProgrammingMethodList=hdlcoder.ProgrammingMethod.Custom;
                end
            end






            if ismember(hdlcoder.ProgrammingMethod.Custom,obj.ProgrammingMethodList)
                obj.ProgrammingMethod=hdlcoder.ProgrammingMethod.Custom;
            elseif ismember(hdlcoder.ProgrammingMethod.Download,obj.ProgrammingMethodList)
                obj.ProgrammingMethod=hdlcoder.ProgrammingMethod.Download;
            elseif ismember(hdlcoder.ProgrammingMethod.JTAG,obj.ProgrammingMethodList)
                obj.ProgrammingMethod=hdlcoder.ProgrammingMethod.JTAG;
            else
                error('There are no supported methods for programming the FPGA. At least one programming method must be available.')
            end
        end


        function hDI=getDIObject(obj)
            hDI=obj.hIP.hD;
        end
        function hTurnkey=getTurnkeyObject(obj)
            hTurnkey=obj.getDIObject.hTurnkey;
        end
        function hBoard=getBoardObject(obj)
            hBoard=obj.getTurnkeyObject.hBoard;
        end
        function hRD=getRDPlugin(obj)

            hRD=obj.hIP.getReferenceDesignPlugin;
        end
        function hCodeGen=getCodeGenObject(obj)
            hCodeGen=obj.getDIObject.hCodeGen;
        end
    end


    methods(Abstract,Access=protected)

        updateToolProjectFolder(obj)

        checkToolPath(obj)

        [CmdStr,projectPath]=getTargetToolOpenCmdStr(obj)

        [status,result]=programBitstreamJTAGMode(obj,bitstreamPath);

        [status,result]=programBitstreamDownloadMode(obj,bitstreamPath,deviceTreePath,systemInitPath,referenceDesignName);
    end


    methods(Abstract,Access=public)

        name=getToolProjectFileName(obj)

        path=getBitstreamPath(obj)
    end


    methods(Access=protected)

        function result=runCreateProjectProcessResult(obj,status,result,validateCell)

            if status

                [tool,link]=obj.getDIObject.getProjectToolLink;
                msg=message('hdlcoder:workflow:GeneratingProject',tool,link).getString;
                if obj.getDIObject.isMLHDLC

                    result=sprintf('%s%s',result,msg);
                elseif obj.getDIObject.cmdDisplay

                    hdldisp(msg);
                else

                    result=sprintf('%s%s',msg,result);
                end




                if~isempty(validateCell)
                    msgStr=downstream.tool.publishValidateCell(validateCell);
                    result=sprintf('%s\n\n%s',msgStr,result);
                end
            end
        end

        function runBootFromSD(obj)
            error('BootFromSD is not supported in %s.',obj.EmbeddedToolName);
        end


        function[status,result,validateCell]=compileDeviceTree(obj)


























            status=true;
            result='';
            validateCell={};





            if obj.hIP.hD.isMLHDLC
                hTurnkey=obj.getTurnkeyObject;


                if obj.hIP.GenerateDeviceTree


                    hTurnkey.updateSoftwareInterfaceList;

                    [status2,result2]=hTurnkey.generateDeviceTree;

                    status=status&&status2;
                    result=sprintf('%s\n%s\n',result,result2);
                    if~status
                        return;
                    end
                end
            end


            try

                hDTCompiler=hdlturnkey.tool.DeviceTreeCompiler;


                hB=obj.getBoardObject;
                [boardDevTree,isBoardDTCompiled]=hB.getDeviceTree;
                hasBoardDevTree=~isempty(boardDevTree);
                hasCompiledBoardDevTree=(hasBoardDevTree&&isBoardDTCompiled);

                hRD=obj.getRDPlugin;
                [refDesignDevTree,isRefDesignDTCompiled]=hRD.getDeviceTree;
                hasRefDesignDevTree=~isempty(refDesignDevTree);
                hasCompiledRefDesignDevTree=(hasRefDesignDevTree&&isRefDesignDTCompiled);

                if(hasCompiledBoardDevTree||hasCompiledRefDesignDevTree)



                    return;
                end

                cmdDisplay=obj.getDIObject.cmdDisplay;


                if hasBoardDevTree
                    [includeDirs,validateCell2]=hB.getDeviceTreeIncludeDirs(cmdDisplay);
                    validateCell=[validateCell,validateCell2];
                    comments="Device tree nodes from board plugin";
                    hDTCompiler.addDeviceTree(boardDevTree,includeDirs,comments);
                end


                if hasRefDesignDevTree
                    [includeDirs,validateCell2]=hRD.getDeviceTreeIncludeDirs(cmdDisplay);
                    validateCell=[validateCell,validateCell2];
                    comments="Device tree nodes from reference design plugin";
                    hDTCompiler.addDeviceTree(refDesignDevTree,includeDirs,comments);
                end


                hTurnkey=obj.getTurnkeyObject;
                [ipCoreDevTree,includeDirs]=hTurnkey.getGeneratedIPCoreDeviceTree;
                if~isempty(ipCoreDevTree)




                    ipCoreDevTreePath=fullfile(includeDirs,ipCoreDevTree);
                    if~isfile(ipCoreDevTreePath)
                        taskName=message('hdlcommon:workflow:HDLWAEmbeddedModelGen').getString;
                        error(message('hdlcommon:workflow:MissingIPCoreDeviceTree',ipCoreDevTree,ipCoreDevTreePath,taskName))
                    end

                    ipCoreName=hTurnkey.hD.hIP.getIPCoreName;
                    comments="Device tree nodes from generated IP core "+ipCoreName;
                    hDTCompiler.addDeviceTree(ipCoreDevTree,includeDirs,comments);
                end


                outputFilePathDTB=obj.getCompiledDeviceTreePath;


                [status2,result2]=hDTCompiler.compileDeviceTree(outputFilePathDTB);

                status=status&&status2;
                result=sprintf('%s\n%s\n',result,result2);
            catch ME
                status=false;
                result=message('hdlcommon:workflow:DeviceTreeCompilationFail',ME.message).getString;
            end
        end

        function[deviceTreePath,overlayPaths]=getDeviceTreeForProgramming(obj)




            overlayPaths=string.empty;


            hB=obj.getBoardObject;
            [devTree,isCompiled]=hB.getDeviceTree;
            if~isempty(devTree)&&isCompiled
                deviceTreePath=devTree;
                return;
            end



            hRD=obj.getRDPlugin;
            [devTree,isCompiled]=hRD.getDeviceTree;
            if~isempty(devTree)&&isCompiled
                deviceTreePath=devTree;
                return;
            end


            deviceTreePath=obj.getCompiledDeviceTreePath;
            if isfile(deviceTreePath)
                return;
            end




            deviceTreePath='';
        end

        function deviceTreePath=getCompiledDeviceTreePath(obj)


            hTurnkey=obj.getTurnkeyObject;
            dtFolder=hTurnkey.getDeviceTreeFolder;



            userFileName=hTurnkey.hD.hCodeGen.ModelName;

            dtFileName="devicetree_"+userFileName+".dtb";
            deviceTreePath=fullfile(dtFolder,dtFileName);
        end
    end

end




