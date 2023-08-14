


classdef ToolDriver<hgsetget


    properties


        hTool=[];
        hDevice=[];
        hEmitter=[];
        hEngine=[];

        OptionList={};
        WorkflowList={};
        OptionIDList={};
        WorkflowIDList={};

    end

    properties(Hidden=true)

        hD=0;
    end


    methods(Access=public)

        function obj=ToolDriver(hDIDriver)

            obj.hD=hDIDriver;


            obj.hTool=downstream.SynthesisTool(obj);
            obj.hDevice=downstream.device.Device(obj);
            obj.hEmitter=downstream.TclEmitter(obj);
            obj.hEngine=downstream.Engine(obj);

            obj.OptionList={};
            obj.WorkflowList={};
            obj.OptionIDList={};
            obj.WorkflowIDList={};
        end

        function loadTool(obj,toolName)



            [~,hA]=obj.hD.hAvailableToolList.isInToolList(toolName);


            hP=hA.AvailablePlugin;


            hP.parsePluginFile(obj);


            hP=downstream.plugin.PluginBase.loadPluginFile(obj.hTool.PluginPackage,'plugin_precodegen');
            hP.parsePluginFile(obj);


            obj.hDevice.loadDeviceData(toolName);



            obj.hEngine.initialize(obj.WorkflowIDList);




            if obj.hD.queryFlowOnly~=downstream.queryflowmodesenum.MATLAB
                obj.attachCodeGenInfo;
            end

        end

        function attachCodeGenInfo(obj)


            if obj.hD.hCodeGen.hCHandle.CodeGenSuccessful||obj.hD.queryFlowOnly==downstream.queryflowmodesenum.VIVADOSYSGEN
                obj.hD.hCodeGen.getCodeGenInfo;


                hP=downstream.plugin.PluginPostCodeGen.loadPluginFile(obj.hTool.PluginPackage,obj);
                hP.parsePluginFile(obj);
            end
        end

    end


    methods(Access=public)


        function value=getProjectPath(obj)
            value=obj.hTool.ProjectDir;
        end
        function setProjectPath(obj,value)
            if~strcmp(obj.hTool.ProjectDir,value)
                obj.hTool.parseProjectDirStr(value);
                obj.hEngine.CurrentStage=obj.hEngine.sidx.Start;
            end
        end


        function value=getCustomHDLFile(obj)
            value=obj.hTool.CustomHDLFileStr;
        end
        function setCustomHDLFile(obj,value)
            if~strcmp(obj.hTool.CustomHDLFileStr,value)
                [customFile,customTclFile]=obj.hTool.parseCustomFileStrWithTcl(value);
                obj.hTool.CustomHDLFile=customFile;
                obj.hTool.CustomTclFile=customTclFile;
                obj.hTool.createCustomSourceTclHDLFileStrings;
                obj.hEngine.CurrentStage=obj.hEngine.sidx.Start;
            end
        end

        function value=getCustomSourceFile(obj)
            value=obj.hTool.CustomSourceFileStr;
        end
        function setCustomSourceFile(obj,value)
            if~strcmp(obj.hTool.CustomSourceFileStr,value)
                [customFile,~]=obj.hTool.parseCustomFileStrWithTcl(value);
                obj.hTool.CustomHDLFile=customFile;
                obj.hTool.createCustomSourceTclHDLFileStrings;
                obj.hEngine.CurrentStage=obj.hEngine.sidx.Start;
            end
        end
        function value=getCustomTclFile(obj)
            value=obj.hTool.CustomTclFileStr;
        end
        function setCustomTclFile(obj,value)
            if~strcmp(obj.hTool.CustomTclFileStr,value)
                [~,customTclFile]=obj.hTool.parseCustomFileStrWithTcl(value);
                obj.hTool.CustomTclFile=customTclFile;
                obj.hTool.createCustomSourceTclHDLFileStrings;
                obj.hEngine.CurrentStage=obj.hEngine.sidx.Start;
            end
        end



        function openTargetTool(obj)
            obj.hTool.openTargetTool;
        end


        function toolPath=getToolPath(obj)
            toolPath=obj.hTool.ToolPath;
        end
        function version=getToolVersion(obj)
            version=obj.hTool.ToolVersion;
        end
        function toolName=getToolName(obj)
            toolName=obj.hTool.ToolName;
        end


        function cmd=getCmdOpenTargetTool(obj)
            cmd=obj.hTool.cmd_openTargetTool;
        end
        function cmd=getCmdRunTclScript(obj)
            cmd=obj.hTool.cmd_runTclScript;
        end


        function addOption(obj,hOption)
            obj.OptionList{end+1}=hOption;
            obj.OptionIDList{end+1}=hOption.OptionID;
        end

        function finalSrcFileList=getFinalSrcFileList(obj)

            codegenSrcFileList=obj.hD.hCodeGen.getSrcFilePathList;


            if obj.hD.isGenericWorkflow&&~isempty(obj.hD.hGeneric)
                finalSrcFileList=downstream.CodeGenInfo.combineFileList(...
                codegenSrcFileList,obj.hD.hGeneric.GenericFileList);
            else
                finalSrcFileList=codegenSrcFileList;
            end


            customHDLFileList=obj.hTool.CustomHDLFile;


            finalSrcFileList=downstream.CodeGenInfo.combineFileList(...
            finalSrcFileList,customHDLFileList);



            smd=obj.hD.hCodeGen.SubModelData;
            numSubModels=numel(smd);
            for ii=numSubModels:-1:1
                subModelFiles=fullfile(smd(ii).DirName,smd(ii).FileNames);
                finalSrcFileList=downstream.CodeGenInfo.combineFileList(...
                subModelFiles,finalSrcFileList);
            end
        end
    end


    methods(Access=public)

        function checkProjectFileExtension(obj)









            currentProjectFileName=obj.hTool.ProjectFileName;
            [~,fileName,fileExt]=fileparts(currentProjectFileName);


            if strcmpi(fileExt,'.xise')
                checkFileExt='.ise';
            elseif strcmpi(fileExt,'.ise')
                checkFileExt='.xise';
            else
                return;
            end
            checkProjectFileName=[fileName,checkFileExt];

            projectPath=obj.getProjectPath;
            checkProjectFilePath=fullfile(projectPath,checkProjectFileName);
            currentProjectFilePath=fullfile(projectPath,currentProjectFileName);


            if exist(checkProjectFilePath,'file')&&...
                ~exist(currentProjectFilePath,'file')
                error(message('hdlcommon:workflow:DifferentISEVersion',checkProjectFilePath,checkProjectFilePath));
            end

        end

        function adjustAdvancedTimingOption(obj)




            allSrcFileList=obj.getFinalSrcFileList;


            isTimingConstrained=false;
            for ii=1:length(allSrcFileList)
                fileNameStr=allSrcFileList{ii};
                [~,~,fileExt]=fileparts(fileNameStr);



                if strcmpi(fileExt,'.ucf')
                    ucfStr=fileread(fileNameStr);
                    detectTimeSpec=regexpi(ucfStr,'TimeSpec','once');
                    if~isempty(detectTimeSpec)
                        isTimingConstrained=true;
                        break;
                    end
                end
            end



            if isTimingConstrained
                obj.hD.set('MapTimeAdvAnalysis','False');
                obj.hD.set('PARTimeAdvAnalysis','False');
            else
                obj.hD.set('MapTimeAdvAnalysis','True');
                obj.hD.set('PARTimeAdvAnalysis','True');
            end
        end

        function addNetlistPathToISEMacroPath(obj)




            customHDLFileList=obj.hTool.CustomHDLFile;


            macroSearchPaths={};
            for ii=1:length(customHDLFileList)
                fileNameStr=customHDLFileList{ii};
                [filePath,~,fileExt]=fileparts(fileNameStr);


                if(strcmpi(fileExt,'.ngc')||strcmpi(fileExt,'.edf'))...
                    &&~isempty(filePath)
                    macroSearchPaths{end+1}=filePath;%#ok<AGROW>
                end
            end

            if~isempty(macroSearchPaths)

                macroSearchPaths=unique(macroSearchPaths);

                obj.hEmitter.createProjectDir;

                for ii=1:length(macroSearchPaths)
                    projectDir=obj.getProjectPath;
                    netlistDir=macroSearchPaths{ii};
                    relativeDir=obj.hEmitter.getRelativeFolderPath(projectDir,netlistDir);
                    relativeDirPath=strrep(relativeDir,'\','/');
                    macroSearchPaths{ii}=relativeDirPath;
                end


                macroPathStr=sprintf('%s',macroSearchPaths{1});
                for ii=2:length(macroSearchPaths)
                    macroPathStr=sprintf('%s|%s',macroPathStr,macroSearchPaths{ii});
                end


                if isempty(obj.hD.getOption('MacroSearchPath'))
                    obj.addOption(downstream.Option('Map','MacroSearchPath',macroPathStr));
                    hWorkflow=obj.hD.getWorkflow('Map');
                    hWorkflow.TclTemplate=[...
                    {'project set "Macro Search Path" "$MacroSearchPath" -process "Translate"'},...
                    hWorkflow.TclTemplate];
                else
                    obj.hD.set('MacroSearchPath',macroPathStr);
                end
            else
                if~isempty(obj.hD.getOption('MacroSearchPath'))
                    obj.hD.set('MacroSearchPath','');
                end
            end
        end


    end



end


