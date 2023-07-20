




classdef ReferenceDesignList<hdlturnkey.plugin.PluginListBase


    properties(Access=protected)








        CustomizationFileName='hdlcoder_ref_design_customization';


        PluginPathList=[];


        hIP=[];


        DispRDName='';
        DispRDChoice={};
        hRDNameList=[];

        RDToolVersion='';
        IgnoreVersionMismatch=false;

    end

    methods

        function obj=ReferenceDesignList(hIP)

            obj.hIP=hIP;
        end

        function buildRDList(obj)






            obj.initList;


            hBoard=obj.hIP.getBoardObject;
            boardName=obj.hIP.getBoardName;
            plugins=obj.searchRDCustomizationFile(hBoard,boardName);
            if isempty(plugins)

                error(message('hdlcommon:workflow:NoReferenceDesignsForBoard',boardName));
            end


            for ii=1:length(plugins)
                plugin=plugins{ii};


                try

                    hRD=obj.loadRDPlugin(plugin,hBoard);


                    if~hRD.isSupported
                        continue;
                    end


                    hDI=obj.hIP.hD;

                    currentToolVersion=obj.hIP.hD.getToolVersion;
                    SupportedToolVersions=hRD.SupportedToolVersion;



                    rdToolVersion=hdlturnkey.plugin.ReferenceDesignVersionList.getDefaultRDToolVersionStatic(SupportedToolVersions,currentToolVersion);


                    hRD.customizeReferenceDesign(hDI,rdToolVersion);



                    obj.validateLoadedRDPlugin(hRD);


                    obj.insertPluginObject(hRD);

                catch ME

                    obj.reportInvalidPlugin(plugin,ME.message);
                    continue;
                end


            end


            toolName=obj.hIP.hD.get('Tool');

            currentToolVersion=obj.hIP.hD.getToolVersion;

            obj.updateRDChoiceTool(toolName,currentToolVersion,boardName);
        end


        function hRD=loadRDPlugin(obj,plugin,hBoard)
            hRD=eval(plugin);



            hRD.addAXIManagerParameter(hBoard);



            hRD.addFPGADatacaptureInterfaceParameter(hBoard);


            hRD.StaticParameterFinished=true;






            [packName,packFullPath]=obj.getPackageName(plugin);


            hRD.PluginFileName=plugin;
            hRD.PluginPath=packFullPath;
            hRD.PluginPackage=packName;
        end



        function validateCell=reloadRDPlugin(obj)

            hRD=obj.getRDPlugin;
            ParamCellFormat=hRD.getParameterCellFormat;


            ClockOutputMHz=hRD.hClockModule.ClockOutputMHz;


            PluginFileName=hRD.PluginFileName;
            hBoard=obj.hIP.getBoardObject;
            if~isempty(PluginFileName)
                hRD=obj.loadRDPlugin(PluginFileName,hBoard);

                if~isempty(ParamCellFormat)
                    hRD.setParameterCellFormat(ParamCellFormat);
                end
            end



            hDI=obj.hIP.hD;
            RefDesignToolVersion=obj.getRDToolVersion;
            validateCell=hRD.customizeReferenceDesign(hDI,RefDesignToolVersion);





            if~isempty(PluginFileName)
                hRD.hClockModule.setClockModuleOutputFreq(ClockOutputMHz);
            end



            obj.validateLoadedRDPlugin(hRD);


            obj.setRDPlugin(hRD);

            hDI.hIP.setHostTargetInterfaceOptions(hRD.getJTAGAXIParameterValue,hRD.getEthernetAXIParameterValue,hRD.HasProcessingSystem);

        end



        function rd=getReferenceDesign(obj)
            rd=obj.DispRDName;
        end
        function setDefaultReferenceDesign(obj)

            rd=obj.getReferenceDesign;

            obj.setReferenceDesign(rd);
        end
        function setReferenceDesign(obj,rd)

            choice=getReferenceDesignAll(obj);
            optionID='ReferenceDesign';


            downstream.tool.validateOptionChoice(rd,choice,optionID);

            obj.DispRDName=rd;



            obj.updateRDToolVersionChoice;

            if isa(obj.hIP,'hdlturnkey.ip.HDLTargetDriver')


                return;
            end


            hDI=obj.hIP.hD;
            if hDI.isSLRTWorkflow
                hDI.hTurnkey.hModelGen=hdlslrt.backend.ModelGenerationxPC(hDI.hTurnkey);





                obj.hIP.GenerateDeviceTree=false;
                obj.hIP.GenerateSoftwareInterfaceModel=true;
                obj.hIP.setGenerateSoftwareInterfaceModelEnable(true);
                obj.hIP.GenerateHostInterfaceScript=false;
                obj.hIP.GenerateHostInterfaceModel=false;
            else



















                hRD=obj.getRDPlugin;
                obj.hIP.GenerateDeviceTree=hRD.isDeviceTreeGenerationEnabled;


                if hDI.isShowCustomSWModelGenerationTask




                    enableModelGenOption=true;
                else




                    enableModelGenOption=hDI.isProcessingSystemAvailable&&hDI.isEmbeddedCoderSPInstalled&&~hDI.isLiberoSoc;
                end
                obj.hIP.setGenerateSoftwareInterfaceModelEnable(enableModelGenOption);




                if hDI.isShowCustomSWModelGenerationTask||hDI.isLiberoSoc



                    enableJTAGOption=false;
                    enableEthernetAXIModelOption=false;
                    enableEthernetOption=false;
                else
                    enableJTAGOption=hRD.getJTAGAXIParameterValue;
                    enableEthernetAXIModelOption=hRD.getEthernetAXIParameterValue;
                    enableEthernetOption=hDI.isProcessingSystemAvailable;
                end
                obj.hIP.setHostTargetInterfaceOptions(enableJTAGOption,enableEthernetAXIModelOption,enableEthernetOption);

                if enableEthernetAXIModelOption
                    obj.hIP.setHostTargetEthernetIPAddress(hRD.getEthernetIPAddressValue);
                end














            end

        end
        function rds=getReferenceDesignAll(obj)
            rds=obj.DispRDChoice;
        end
        function refreshReferenceDesign(obj)



            hTurnkey=obj.hIP.getTurnkeyObject;
            hTurnkey.updateInterfaceList;


            hTurnkey.hExecMode.updateExecutionMode;


            obj.hIP.refreshProgrammingMethod;


            obj.hIP.refreshDefaultUseIPCache;
        end


        function ver=getRDToolVersion(obj)
            ver=obj.RDToolVersion;
        end
        function setRDToolVersion(obj,ver)



            if strcmp(obj.getRDToolVersion,ver)
                return;
            end

            choice=getRDToolVersionAll(obj);
            optionID='ReferenceDesignToolVersion';
            downstream.tool.validateOptionChoice(ver,choice,optionID);


            obj.setRDToolVersionAndRefresh(ver);
        end
        function verList=getRDToolVersionAll(obj)
            if obj.isRDToolVersionMatch
                verList={obj.getRDToolVersion};
            else
                rd=obj.getReferenceDesign;
                verList=obj.getAllSupportedVersion(rd);
            end
        end
        function isMatch=isRDToolVersionMatch(obj)
            currentToolVersion=obj.hIP.hD.getToolVersion;
            if isempty(currentToolVersion)
                isMatch=false;
            else
                rdToolVersion=obj.getRDToolVersion;
                isMatch=downstream.tool.isToolVersionMatch(currentToolVersion,rdToolVersion);
            end
        end


        function ignore=getIgnoreRDToolVersionMismatch(obj)
            ignore=obj.IgnoreVersionMismatch;
        end
        function setIgnoreRDToolVersionMismatch(obj,ignore)
            obj.IgnoreVersionMismatch=ignore;
        end


        function rdPath=getReferenceDesignPath(obj)
            rdPath='';
            hRD=obj.getRDPlugin;
            if~isempty(hRD)
                rdPath=hRD.PluginPath;
            end
        end


        function hRD=getRDPlugin(obj)
            rdName=obj.getReferenceDesign;
            rdVer=obj.getRDToolVersion;
            hRD=obj.getRDObject(rdName,rdVer);
        end


        function setRDPlugin(obj,hRDNew)
            rdName=obj.getReferenceDesign;
            rdVer=obj.getRDToolVersion;
            obj.setRDObject(rdName,rdVer,hRDNew);
        end


        function validateCell=validateRDPlugin(obj)









            validateCell={};


            rdName=obj.getReferenceDesign;
            hRD=obj.getRDPlugin;
            if isempty(hRD)
                error(message('hdlcommon:hdlturnkey:InvalidRDPlugin'));
            end




            toolName=obj.hIP.hD.get('Tool');
            toolVersion=obj.hIP.hD.getToolVersion;
            rdSupportedVersions=hRD.SupportedToolVersion;
            cmdDisplay=obj.hIP.hD.cmdDisplay;
            isMatch=downstream.tool.detectToolVersionMatch(toolVersion,rdSupportedVersions);
            if~isMatch
                allSupportedVersions=obj.getAllSupportedVersion(rdName);
                allSupportedVersionsStr=downstream.tool.getStrFromCell(allSupportedVersions);
                hMRefVersion=message('hdlcommon:hdlturnkey:ToolVersionCurrentRD',...
                sprintf(' %s',allSupportedVersionsStr));
                ignoreMismatch=obj.getIgnoreRDToolVersionMismatch;
                if ignoreMismatch

                    hM=message('hdlcommon:hdlturnkey:ToolVersionIncompatible',...
                    rdName,toolVersion,toolName);
                    hMAttempt=message('hdlcommon:hdlturnkey:ToolVersionAttempt');
                    hMAll=message('hdlcommon:hdlturnkey:ToolVersionAll',...
                    hM.getString,hMRefVersion.getString,hMAttempt.getString);
                    if cmdDisplay
                        warning(hMAll);
                    else
                        validateCell{end+1}=hdlvalidatestruct('Warning',hMAll);
                    end
                else

                    hMSure=message('hdlcommon:hdlturnkey:ToolVersionIncompatibleSure',...
                    rdName,toolVersion,toolName);
                    hIgnoreOption=message('HDLShared:hdldialog:HDLWARDToolVersionIgnore');
                    hMChange=message('hdlcommon:hdlturnkey:ToolVersionChange',hIgnoreOption.getString);
                    hMAll=message('hdlcommon:hdlturnkey:ToolVersionAll',...
                    hMSure.getString,hMRefVersion.getString,hMChange.getString);
                    if cmdDisplay
                        error(hMAll);
                    else
                        validateCell{end+1}=hdlvalidatestruct('Error',hMAll);
                    end
                end
            end



            hBoard=obj.hIP.getBoardObject;
            validateCell=hRD.validateReferenceDesignSelected(hBoard,validateCell,cmdDisplay);

        end

    end

    methods(Access=protected)


        function updateRDChoiceTool(obj,toolName,currentToolVersion,boardName)



            [isIn,hNameList]=obj.isInList(toolName);
            if~isIn||hNameList.isListEmpty

                obj.DispRDName='';
                obj.DispRDChoice={};
                obj.hRDNameList=[];

                error(message('hdlcommon:workflow:NoReferenceDesignsForTool',boardName,toolName));
            end


            obj.DispRDChoice=hNameList.getNameList;
            obj.hRDNameList=hNameList;
            obj.DispRDName=hNameList.getDefaultRDName(currentToolVersion);

        end

        function updateRDToolVersionChoice(obj)


            if isempty(obj.hRDNameList)||obj.hRDNameList.isListEmpty
                return;
            end


            rdName=obj.getReferenceDesign;
            [~,hVerList]=obj.hRDNameList.isInList(rdName);
            if isempty(hVerList)||hVerList.isListEmpty
                obj.RDToolVersion='';
                return;
            end


            currentToolVersion=obj.hIP.hD.getToolVersion;


            defaultVer=hVerList.getDefaultRDToolVersion(currentToolVersion);


            obj.setRDToolVersionAndRefresh(defaultVer);
        end

        function setRDToolVersionAndRefresh(obj,ver)

            obj.RDToolVersion=ver;


            obj.refreshReferenceDesign;
        end

        function validateLoadedRDPlugin(obj,hRD)





            hRD.validateReferenceDesign;




            hRD.validateReferenceDesignForBoard(obj.hIP.getBoardObject);

        end

        function plugins=searchRDCustomizationFile(obj,hBoard,boardName)

            plugins={};
            obj.PluginPathList=containers.Map();


            pluginFilePath=fullfile(hBoard.PluginPath,obj.CustomizationFileName);
            if exist(pluginFilePath,'file')
                registrationFile=sprintf('%s.%s',hBoard.PluginPackage,obj.CustomizationFileName);
                [refDesignList,registrationFileBoardName]=eval(registrationFile);


                cellListMsg=message('hdlcommon:plugin:CellListRefDRegistrationFile',registrationFile);
                hdlturnkey.plugin.validateCellList(refDesignList,cellListMsg);

                if strcmp(registrationFileBoardName,boardName)

                    for jj=1:length(refDesignList)
                        a_plugin=refDesignList{jj};
                        if~obj.PluginPathList.isKey(a_plugin)
                            obj.PluginPathList(a_plugin)=pluginFilePath;
                            plugins{end+1}=a_plugin;%#ok<AGROW>
                        else
                            error(message('hdlcommon:workflow:DuplicatePluginPath',a_plugin,obj.PluginPathList(a_plugin),pluginFilePath));
                        end
                    end
                else
                    error(message('hdlcommon:hdlturnkey:RegFileBoardMismatch',...
                    registrationFileBoardName,pluginFilePath,boardName));
                end
            end


            customFiles=obj.searchCustomizationFileOnPath;

            currentFolder=pwd;
            for ii=1:length(customFiles)
                customFile=customFiles{ii};
                [customfolder,customname,~]=fileparts(customFile);


                cd(customfolder);
                [refDesignList,registrationFileBoardName]=eval(customname);
                cd(currentFolder);


                if isempty(registrationFileBoardName)||...
                    ~strcmp(registrationFileBoardName,boardName)
                    continue;
                end


                cellListMsg=message('hdlcommon:plugin:CellListRefDRegistrationFile',customFile);
                hdlturnkey.plugin.validateCellList(refDesignList,cellListMsg);


                for jj=1:length(refDesignList)
                    a_plugin=refDesignList{jj};
                    if~obj.PluginPathList.isKey(a_plugin)
                        obj.PluginPathList(a_plugin)=customFile;
                        plugins{end+1}=a_plugin;%#ok<AGROW>
                    else
                        error(message('hdlcommon:workflow:DuplicatePluginPath',a_plugin,obj.PluginPathList(a_plugin),customFile));
                    end
                end
            end
        end

        function insertPluginObject(obj,hRD)











            toolName=hRD.SupportedTool;


            if obj.PluginObjList.isKey(toolName)
                hNameList=obj.PluginObjList(toolName);
            else
                hNameList=hdlturnkey.plugin.ReferenceDesignNameList;
                obj.PluginObjList(toolName)=hNameList;
            end


            hNameList.insertPluginObject(hRD);
        end

        function hRD=getRDObject(obj,rdName,rdVer)


            if nargin<3

                rdVer='';
            end

            hRD=[];
            if isempty(obj.hRDNameList)||obj.hRDNameList.isListEmpty
                return;
            end

            [~,hVerList]=obj.hRDNameList.isInList(rdName);
            if isempty(hVerList)||hVerList.isListEmpty
                return;
            end

            if~isempty(rdVer)
                [~,hRD]=hVerList.isInList(rdVer);
            else


                supportedVerList=hVerList.getNameList;
                supportedVerListSorted=sort(supportedVerList);
                [~,hRD]=hVerList.isInList(supportedVerListSorted{end});
            end
        end

        function setRDObject(obj,rdName,rdVer,hRDNew)

            if isempty(obj.hRDNameList)||obj.hRDNameList.isListEmpty
                return;
            end

            [~,hVerList]=obj.hRDNameList.isInList(rdName);
            if isempty(hVerList)||hVerList.isListEmpty
                return;
            end

            hVerList.setPluginObject(rdVer,hRDNew);
        end

        function verList=getAllSupportedVersion(obj,rdName)

            verList={};
            if isempty(obj.hRDNameList)
                return;
            end
            verList=obj.hRDNameList.getAllSupportedVersion(rdName);
        end

    end
end





