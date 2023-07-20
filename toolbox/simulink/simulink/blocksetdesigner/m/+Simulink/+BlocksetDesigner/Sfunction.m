classdef Sfunction<Simulink.BlocksetDesigner.Block




    properties
    end

    methods(Access=public,Hidden=true)

        function obj=Sfunction()
            obj=obj@Simulink.BlocksetDesigner.Block();
        end

        function sfunInfo=create(obj,sfunName,type,parent)
            blockName=sfunName;
            sfunInfo='';
            if isempty(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockEmptyInput'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            if~isvarname(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                blockName=obj.processName(blockName);
            end
            if exist(blockName)~=0||obj.checkExistingFile(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            create@Simulink.BlocksetDesigner.Block(obj,blockName,'S-Function');

            projectRoot=obj.ProjectRoot;
            blockFolder=blockName;
            proj=obj.Project;

            binFolder=[blockFolder,filesep,'mex'];
            if~exist(fullfile(projectRoot,binFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,binFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(binFolder);

            end

            sourceFolder=[blockFolder,filesep,'src'];
            if~exist(fullfile(projectRoot,sourceFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,sourceFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(sourceFolder);
            end

            buildFolder=[blockFolder,filesep,'build'];
            buildderived=fullfile(buildFolder,'derived');
            if~exist(fullfile(projectRoot,buildFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,buildFolder));
                [~,~,~]=mkdir(fullfile(projectRoot,buildderived));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(buildFolder);
            end

            sfunInfo=obj.createSfunction(blockName,type,parent);
        end

        function sfunInfo=createFromExample(obj,sfunName,example,parent)
            blockName=sfunName;
            sfunInfo='';
            if isempty(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockEmptyInput'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            if~isvarname(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                blockName=obj.processName(blockName);
            end
            if exist(blockName)~=0||obj.checkExistingFile(blockName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            originalBlockPath=Simulink.BlocksetDesigner.internal.getSfunctionExamples(example);

            obj.createBlockFolders(blockName,'S-Function');
            projectRoot=obj.ProjectRoot;
            blockFolder=blockName;
            proj=obj.Project;

            binFolder=[blockFolder,filesep,'mex'];
            if~exist(fullfile(projectRoot,binFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,binFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(binFolder);

            end

            sourceFolder=[blockFolder,filesep,'src'];
            if~exist(fullfile(projectRoot,sourceFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,sourceFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(sourceFolder);
            end

            buildFolder=[blockFolder,filesep,'build'];
            buildderived=fullfile(buildFolder,'derived');
            if~exist(fullfile(projectRoot,buildFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,buildFolder));
                [~,~,~]=mkdir(fullfile(projectRoot,buildderived));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(buildFolder);
            end
            sfunInfo=obj.copyExampleFilesToBlock(blockName,originalBlockPath,parent);
        end


        function sfunInfo=import(obj,sfunInfo)
            sfunInfo=import@Simulink.BlocksetDesigner.Block(obj,sfunInfo);
            blockName=sfunInfo.BlockName;
            blockName=obj.processName(blockName);
            functionName=sfunInfo.S_FUN_FUNCTION_NAME;
            if isempty(functionName)
                functionName=blockName;
                sfunInfo.S_FUN_FUNCTION_NAME=blockName;
            end
            preSfcnFile=sfunInfo.S_FUN_FILE;
            if~exist(preSfcnFile,'file')
                sfcnFile=obj.findSfunctionFileInProject(blockName,functionName,'src');
                sfunInfo.S_FUN_FILE=sfcnFile;
            end

            mexFile=obj.findSfunctionFileInProject(blockName,functionName,'mex');
            sfunInfo.S_FUN_MEX_FILE=mexFile;
            if isempty(mexFile)
                sfunInfo.BUILD=obj.NOTRUN;
                sfunInfo.BUILD_TIMESTAMP='';
            end

            preBuildScript=sfunInfo.S_FUN_BUILD;
            if~exist(preBuildScript,'file')
                buildScript=obj.findSfunctionFileInProject(blockName,functionName,obj.S_FUN_BUILD);
                if~isempty(buildScript)
                    sfunInfo.S_FUN_BUILD=buildScript;
                    sfunInfo.BUILD=obj.NOTRUN;
                    sfunInfo.BUILD_TIMESTAMP='';
                    sfunInfo.BUILD_CHECKBOX_ENABLE='true';
                end
            end

            obj.updateBlockList(sfunInfo.Id);
            obj.writeToDataModel(sfunInfo);
        end

        function editBlockSource(obj,blockId)
            file=obj.getBlockFilesByType(blockId,obj.S_FUN_FILE);
            if(~isempty(file))
                edit(file);
            end
        end

        function editBuildRule(obj,sfunName)
            buildFile=obj.getBlockFilesByType(sfunName,obj.S_FUN_BUILD);
            if(~isempty(buildFile))
                edit(buildFile);
            end
        end

        function result=build(obj,blockId,flag)

            result.BUILD=obj.WARNING;
            result.BUILD_TIMESTAMP='';
            result.S_FUN_MEX_FILE='';

            buildScript=obj.getBlockFilesByType(blockId,obj.S_FUN_BUILD);
            details={};
            errorOccurred=false;
            compilerInfo=mex.getCompilerConfigurations('C','Selected');
            if isempty(compilerInfo)
                msgbox(DAStudio.message('Simulink:SFunctions:ComplianceCheckMEXCompilerSetupIncorrect','C/CPP'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                status=obj.NOTRUN;
                obj.setBlockOpStatus(blockId,obj.BUILD,status);
                return;
            end
            compiler=compilerInfo.ShortName;
            ex='';
            sfunName=obj.getBlockMetaData(blockId,obj.S_FUN_FUNCTION_NAME);
            if~isempty(buildScript)
                status=obj.PASS;
                isBuilder=obj.getBlockMetaData(blockId,obj.ISBUILDER);
                blockName=obj.getBlockMetaData(blockId,'BlockName');
                if~exist(blockName,'dir')
                    msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoBlockFolder',blockName,blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    status=obj.NOTRUN;
                    obj.setBlockOpStatus(blockId,obj.BUILD,status);
                    result.BUILD=status;
                    return;
                end
                reportPath=fullfile(obj.ProjectRoot,blockName,'build','derived');
                if~exist(reportPath,'dir')
                    mkdir(reportPath);
                end
                if isequal(isBuilder,'true')
                    run(fullfile(obj.ProjectRoot,buildScript));
                    logfile=fullfile(reportPath,'build.log');
                    if exist(logfile,'file')
                        errorOccurred=true;
                        output=obj.readAndDeleteBuildLog(logfile);
                        [~,details]=Simulink.sfunction.analyzer.internal.parseCompileResult(output,compiler,1);
                        status=obj.FAIL;
                    else
                        details={'Build completed successfully.'};
                    end

                else
                    try
                        if strcmp(obj.getBlockMetaData(blockId,obj.ISPACKAGED),'true')
                            invokeSFcnBuildscript('BSDAuthor',buildScript);
                        else
                            run(fullfile(obj.ProjectRoot,buildScript));
                        end

                        details={'Build completed successfully.'};
                    catch ex
                        output=ex.message;
                        errorOccurred=true;
                        [~,details]=Simulink.sfunction.analyzer.internal.parseCompileResult(output,compiler,1);
                        status=obj.FAIL;
                    end
                end
                if~isequal(status,obj.FAIL)&&...
                    strcmp(obj.getBlockMetaData(blockId,obj.ISPACKAGED),'true')

                    sfunName=obj.getBlockMetaData(blockId,'BlockName');
                    Simulink.SFcnPackage.addFileDependencyForSFcn(sfunName,obj.ProjectRoot,fullfile(obj.ProjectRoot,sfunName),...
                    fullfile(obj.ProjectRoot,sfunName,'mex',[sfunName,'.',mexext]));
                end

                obj.setBlockOpStatus(blockId,{obj.BUILD,obj.BUILD_TIMESTAMP},{status,datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'))});
                result.BUILD=status;
                result.BUILD_TIMESTAMP=datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'));
                rpt=Simulink.BlocksetDesigner.internal.BuildReport(reportPath,blockName,status,details,compiler);
                rpt.RetainChildren=true;
                reportPath=obj.normPath(rpt.OutputPath);
                obj.Project.addFile(reportPath);
                obj.setBlockMetaData(blockId,obj.S_FUN_BUILD_REPORT,reportPath);
                obj.setFileType(reportPath,obj.S_FUN_BUILD_REPORT,blockId);
                if flag==1
                    rptgen.rptview(rpt);
                end
                close(rpt);
                if~errorOccurred
                    sfunBinPath=obj.findSfunctionFileInProject(blockName,sfunName,'mex');
                    if exist(sfunBinPath,'file')
                        obj.addBlockFile(blockId,obj.S_FUN_MEX_FILE,sfunBinPath);
                        obj.setBlockOpStatus(blockId,{obj.S_FUN_MEX_FILE},{sfunBinPath});
                        result.S_FUN_MEX_FILE=sfunBinPath;
                    end
                end
            end
        end

        function openBuildReport(obj,blockId)
            filepath=obj.getBlockFilesByType(blockId,obj.S_FUN_BUILD_REPORT);
            filepath=obj.restoreFilePath(filepath);
            if exist(obj.abPath(filepath),'file')
                Simulink.sfunction.analyzer.openReport(obj.abPath(filepath));
            else
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',filepath),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
            end
        end

        function result=runSfunctionCheck(obj,blockId)
            sfunTestHarnessPath=obj.getBlockFilesByType(blockId,obj.TEST_HARNESS);
            [~,sfunTestModel,~]=fileparts(sfunTestHarnessPath);
            sfunName=obj.getBlockMetaData(blockId,'BlockName');
            result.CHECK_REPORT='';
            if~isempty(sfunTestModel)
                sfcnFile=obj.getBlockFilesByType(blockId,obj.S_FUN_FILE);
                bdInfo=Simulink.sfunction.analyzer.BuildInfo(fullfile(obj.ProjectRoot,sfcnFile));
                opts=Simulink.sfunction.analyzer.Options();
                opts.ReportPath=fullfile(sfunName,'unittest');
                opts.EnableRobustness=true;
                cpChecker=Simulink.sfunction.Analyzer(sfunTestModel,'BuildInfo',{bdInfo},'Options',opts);
                cpChecker.run();
                cpChecker.generateReport();
                checkReport=fullfile(opts.ReportPath,['unittest_',sfunName,'_report.htmx']);
                obj.addBlockFile(blockId,obj.CHECK_REPORT,checkReport);
                obj.setBlockOpStatus(blockId,obj.CHECK_REPORT,checkReport);
                result.CHECK_REPORT=checkReport;
            end
        end




        function importSfbuilder(obj,sfunFile,errorOccurred,mexVerboseText)
            [~,sfunName,y]=fileparts(sfunFile);
            abfolder=sfunName;

            result.command='importSfbuilder';
            result.data='';
            result.header='';

            if exist(fullfile(obj.ProjectRoot,abfolder),'dir')
                sfunWrapperFile=fullfile(abfolder,'src',[sfunName,'_wrapper',y]);

                obj.Project.addFolderIncludingChildFiles(sfunName);

                blockIds=strsplit(obj.getBlocksInProject(),';');
                myId='';
                for i=1:numel(blockIds)
                    blockName=obj.getBlockMetaData(blockIds{i},'BlockName');
                    if isequal(blockName,sfunName)
                        myId=blockIds{i};
                        break;
                    end
                end
                sfunFile=fullfile(abfolder,'src',sfunFile);
                if exist(sfunFile,'file')
                    obj.addBlockFile(myId,obj.S_FUN_FILE,sfunFile);
                    if exist(sfunWrapperFile,'file')
                        obj.Project.addFile(fullfile(obj.ProjectRoot,sfunWrapperFile));
                    end
                else
                    sfunFile='';
                end

                mexFile=fullfile(abfolder,'mex',[sfunName,'.',mexext]);
                if exist(mexFile,'file')
                    obj.addBlockFile(myId,obj.S_FUN_MEX_FILE,mexFile);
                else
                    mexFile='';
                end

                sfuntlc=fullfile(abfolder,'mex',[sfunName,'.','tlc']);
                if exist(sfuntlc,'file')
                    obj.setFileType(sfuntlc,obj.S_FUN_TLC,myId);
                else
                    sfuntlc='';
                end
                obj.setBlockOpStatus(myId,{obj.S_FUN_FILE,obj.S_FUN_MEX_FILE,obj.S_FUN_TLC},{sfunFile,mexFile,sfuntlc});
                result.data.Id=myId;
                result.data.S_FUN_FILE=sfunFile;
                result.data.S_FUN_MEX_FILE=mexFile;
                result.data.S_FUN_TLC_FILE=sfuntlc;

                buildScript=obj.getBlockFilesByType(myId,obj.S_FUN_BUILD);
                if(isempty(buildScript))
                    temp=obj.setupSfBuilderScript(sfunName,myId);
                    result.data.BUILD=temp.BUILD;
                    result.data.S_FUN_BUILD=temp.S_FUN_BUILD;
                    result.data.BUILD_CHECKBOX_ENABLE=temp.BUILD_CHECKBOX_ENABLE;
                end

                if errorOccurred
                    logPath=fullfile(obj.ProjectRoot,sfunName,'build','derived','build.log');
                    fid=fopen(logPath,'wt');
                    fprintf(fid,'%s',mexVerboseText);
                    fclose(fid);
                end
            end
            obj.notifyUI(result);
        end




        function importSfunctionFromBuilder(obj,sfunFile,errorOccurred,mexVerboseText)

            [~,sfunName,y]=fileparts(sfunFile);
            abfolder=sfunName;
            result.command='importSfunctionFromBuilder';
            result.data='';
            result.header='';
            libFolder=fullfile(abfolder,'library');

            packageFile=fullfile(obj.ProjectRoot,sfunName,'package',[sfunName,getSFcnPackageExtension]);
            packageExists=isfile(packageFile);
            if exist(fullfile(obj.ProjectRoot,abfolder),'dir')


                tempLibraryFile=fullfile(obj.ProjectRoot,'resources',sfunName,['tempSFB__library_',sfunName,'.slx']);
                tempLibraryFile=obj.normPath(tempLibraryFile);
                [~,tempLibraryName,~]=fileparts(tempLibraryFile);
                if~bdIsLoaded(tempLibraryName)

                    return;
                end



                if errorOccurred
                    return;
                end

                blockInTempLibrary=[tempLibraryName,'/',sfunName];
                blkHandle=getSimulinkBlockHandle(blockInTempLibrary);

                wizData=get_param(blkHandle,'WizardData');
                sfunInfo='';
                blockId='';
                if isfield(wizData,'BSDMetaModel')
                    sfunInfo=wizData.BSDMetaModel;
                    blockId=sfunInfo.Id;
                end

                if isempty(sfunInfo)

                    return;
                end


                if isfield(wizData,'IgnoreMdlWizardData')
                    wizData.IgnoreMdlWizardData=0;
                    set_param(blkHandle,'WizardData',wizData);
                end

                save_system(tempLibraryName);
                close_system(tempLibraryName,0);







                params='';
                if packageExists
                    params=Simulink.SFcnPackage.getSFcnBlockParams(sfunName,...
                    obj.ProjectRoot,fullfile(obj.ProjectRoot,sfunName));
                end

                parameters='';
                modules='';
                if~isempty(params)&&isstruct(params)
                    paramNames='';
                    paramValues='';
                    if isfield(params,'paramNames')
                        paramNames=params.paramNames;
                    end
                    if isfield(params,'paramValues')
                        paramValues=params.paramValues;
                    end


                    idxParameters=strcmp(paramNames,'Parameters');
                    idxModules=strcmp(paramNames,'SFunctionModules');
                    parameters=paramValues{idxParameters};
                    modules=paramValues{idxModules};
                end
                applyMask=~isempty(parameters);
                [libraryModelPath,library]=obj.createSfunLibrary(sfunName,'',parameters,modules,applyMask,obj.abPath(libFolder));
                blockPath=[library,'/',sfunName];

                parentLibrary=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
                [~,parentLibrary,~]=fileparts(parentLibrary);
                obj.addBlockToParentLibrary(sfunName,blockPath,parentLibrary);
                libraryModelPath=obj.normPath(libraryModelPath);


                sfunFile=fullfile(abfolder,'src',[sfunName,y]);
                sfunWrapperFile=fullfile(abfolder,'src',[sfunName,'_wrapper',y]);
                mexFile=fullfile(abfolder,'mex',[sfunName,'.',mexext]);
                sfuntlc=fullfile(abfolder,'mex',[sfunName,'.','tlc']);
                buildScriptFile=fullfile(abfolder,'build',['mex_',sfunName,'.m']);


                obj.Project.addFolderIncludingChildFiles(sfunName);

                sfunInfo.BLOCK_LIBRARY=libraryModelPath;
                sfunInfo.S_FUN_FILE=sfunFile;
                sfunInfo.S_FUN_BUILD=buildScriptFile;
                if isfile(buildScriptFile)
                    sfunInfo.BUILD=obj.NOTRUN;
                    sfunInfo.BUILD_CHECKBOX_ENABLE='true';
                end
                sfunInfo.S_FUN_MEX_FILE=mexFile;
                obj.updateBlockList(blockId);
                obj.writeToDataModel(sfunInfo);

                obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
                if bdIsLoaded(library)

                    save_system(library);
                end
                iconfile=obj.generateBlockIcon(blockId);
                obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
                obj.Project.addFile(obj.abPath(iconfile));
                sfunInfo.BLOCK_ICON=iconfile;
                obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);

                if isfile(buildScriptFile)
                    obj.Project.addFile(buildScriptFile);
                    obj.setFileType(buildScriptFile,obj.S_FUN_BUILD,blockId);
                    result.data.BUILD=obj.NOTRUN;
                    result.data.S_FUN_BUILD=buildScriptFile;
                    result.data.BUILD_CHECKBOX_ENABLE='true';
                end

                if exist(sfunFile,'file')
                    obj.setFileType(sfunFile,obj.S_FUN_FILE,blockId);
                    obj.addBlockFile(blockId,obj.S_FUN_FILE,sfunFile);
                    if exist(sfunWrapperFile,'file')
                        obj.Project.addFile(fullfile(obj.ProjectRoot,sfunWrapperFile));
                    end
                else
                    sfunFile='';
                end

                if exist(mexFile,'file')
                    obj.addBlockFile(blockId,obj.S_FUN_MEX_FILE,mexFile);
                else
                    mexFile='';
                end

                if packageExists&&isfile(mexFile)
                    Simulink.SFcnPackage.addFileDependencyForSFcn(sfunName,...
                    obj.ProjectRoot,fullfile(obj.ProjectRoot,sfunName),...
                    mexFile);
                end

                if exist(sfuntlc,'file')
                    obj.setFileType(sfuntlc,obj.S_FUN_TLC,blockId);
                else
                    sfuntlc='';
                end


                result.data.Id=blockId;
                result.data.S_FUN_FILE=sfunFile;
                result.data.S_FUN_MEX_FILE=mexFile;
                result.data.S_FUN_TLC_FILE=sfuntlc;

                if errorOccurred
                    logPath=fullfile(obj.ProjectRoot,sfunName,'build','derived','build.log');
                    fid=fopen(logPath,'wt');
                    fprintf(fid,'%s',mexVerboseText);
                    fclose(fid);
                    c=onCleanup(@()close_system(libraryModelPath));
                end
            end
            obj.notifyUI(result);
        end


        function sfunInfo=createSfunction(obj,sfunName,type,parent)
            parentLibrary=obj.getBlockMetaData(parent,obj.OpenFunction);
            parentLibrary=obj.processName(parentLibrary);
            libFolder=fullfile(sfunName,'library');
            sourceFolder=fullfile(sfunName,'src');
            scriptFolder=fullfile(sfunName,'build');
            switch(type)
            case 0
                template=fullfile(matlabroot,'simulink','src','sfuntmpl_basic.c');
                replaceLine='#define S_FUNCTION_NAME  sfuntmpl_basic';
                params='';
            case 1
                template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+BlockAuthoringTemplate','src','sfunmem.c');
                replaceLine='#define S_FUNCTION_NAME sfunmem';
                params='';
            case 2
                template=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+BlockAuthoringTemplate','src','sfun_zc_cstate_sat.c');
                replaceLine='#define S_FUNCTION_NAME  sfun_zc_cstate_sat';
                params='2,1';
            case 3
                libraryModelPath=obj.createSfBuilderLibrary(sfunName,libFolder,0);
                obj.Project.addFolderIncludingChildFiles(sfunName);

                [~,library,~]=fileparts(libraryModelPath);
                blockpath=[library,'/',sfunName];
                sfunInfo=Simulink.BlocksetDesigner.SfunInfo(sfunName,blockpath,parent);

                sfunInfo.BLOCK_LIBRARY=libraryModelPath;
                sfunInfo.ISBUILDER='true';

                sfunInfo.BUILD=obj.WARNING;
                blockId=sfunInfo.Id;

                obj.setBlockMetaData(blockId,{'BlockType','BlockName','BlockPath',obj.BLOCK_LIBRARY,'ISBUILDER',obj.S_FUN_FUNCTION_NAME},{'S-Function',sfunName,blockpath,libraryModelPath,'true',sfunName});

                obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
                iconfile=obj.generateBlockIcon(blockId);
                obj.Project.addFile(obj.abPath(iconfile));
                sfunInfo.BLOCK_ICON=iconfile;
                obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
                obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);
                if isempty(parentLibrary)
                    blockSetFile=obj.getBlockSetMetaData(obj.BLOCKSET_LIBRARY);
                    [~,parentLibrary,~]=fileparts(blockSetFile);
                end
                obj.updateBlockList(blockId);
                obj.addBlockToParentLibrary(sfunName,blockpath,parentLibrary);
                blockhandle=getSimulinkBlockHandle(blockpath);
                sfunctionwizard(blockhandle);
                return;

            case{4,5,6}







                library=['library_',sfunName];
                blockPath=[library,'/',sfunName];

                sfunInfo=Simulink.BlocksetDesigner.SfunInfo(sfunName,blockPath,parent);
                sfunInfo.ISBUILDER='false';
                sfunInfo.ISPACKAGED='true';
                sfunInfo.S_FUN_FUNCTION_NAME=sfunName;




                sfunInfo.BUILD=obj.WARNING;
                sfunInfo.TEST=obj.WARNING;
                sfunInfo.DOCUMENT=obj.WARNING;


                packageFolder=fullfile(obj.ProjectRoot,sfunName,'package');
                if~isfolder(packageFolder)
                    mkdir(packageFolder);
                end


                tempLibraryModelPath=obj.createSfBuilderLibrary(sfunName,libFolder,1);
                load_system(tempLibraryModelPath);
                [~,tempLibraryName,~]=fileparts(tempLibraryModelPath);
                if bdIsLoaded(tempLibraryName)
                    set_param(tempLibraryName,'Lock','off');
                    blockPathInTempModel=[tempLibraryName,'/',sfunName];
                    blkHandle=getSimulinkBlockHandle(blockPathInTempModel);
                    wizData=get_param(blkHandle,'WizardData');
                    if isempty(wizData)


                        wizData.IgnoreMdlWizardData=1;
                    end
                    wizData.BSDMetaModel=sfunInfo;
                    wizData.SfunName=sfunName;



                    if isequal(type,5)

                        wizData.NumberOfDiscreteStates='1';
                    elseif isequal(type,6)

                        wizData.NumberOfContinuousStates='1';
                    end
                    set_param(blkHandle,'WizardData',wizData);
                    save_system(tempLibraryName);
                end


                sfunctionwizard(blkHandle);
                return;
            end

            sourceFile=obj.abPath(fullfile(sourceFolder,[sfunName,'.c']));
            copyfile(template,sourceFile);
            fileattrib(sourceFile,'+w');
            replaceSfunName(obj,sourceFile,sfunName,replaceLine);

            modules='';
            applyNonDefaultMask=0;
            [libraryModelPath,library]=obj.createSfunLibrary(sfunName,'',params,modules,applyNonDefaultMask,obj.abPath(libFolder));
            blockPath=[library,'/',sfunName];
            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
            obj.addBlockToParentLibrary(sfunName,blockPath,parentLibrary);
            libraryModelPath=obj.normPath(libraryModelPath);

            sfcnFile=fullfile(sourceFolder,[sfunName,'.c']);
            buildScriptPath=obj.createBuildScript(sfunName,sfcnFile,'',obj.abPath(scriptFolder));
            buildScriptPath=obj.normPath(buildScriptPath);

            obj.Project.addFolderIncludingChildFiles(sfunName);

            sfunInfo=Simulink.BlocksetDesigner.SfunInfo(sfunName,blockPath,parent);

            sfunInfo.BLOCK_LIBRARY=libraryModelPath;
            sfunInfo.S_FUN_FILE=sfcnFile;
            sfunInfo.S_FUN_BUILD=buildScriptPath;
            sfunInfo.BUILD_CHECKBOX_ENABLE='true';
            sfunInfo.BUILD=obj.NOTRUN;
            sfunInfo.ISBUILDER='false';
            sfunInfo.S_FUN_FUNCTION_NAME=sfunName;

            blockId=sfunInfo.Id;
            obj.updateBlockList(blockId);
            obj.writeToDataModel(sfunInfo);


            obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
            iconfile=obj.generateBlockIcon(blockId);
            obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);
            obj.Project.addFile(obj.abPath(iconfile));
            sfunInfo.BLOCK_ICON=iconfile;

            obj.setFileType(sfcnFile,obj.S_FUN_FILE,blockId);
            obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);
            obj.setFileType(buildScriptPath,obj.S_FUN_BUILD,blockId);

        end

        function replaceSfunName(~,sourceFile,sfunName,replaceLine)

            newText=['#define S_FUNCTION_NAME  ',sfunName];
            A=regexp(fileread(sourceFile),'\n','split');
            for i=1:numel(A)
                if isequal(A{i},replaceLine)
                    A{i}=newText;
                    break;
                end
            end

            fileID=fopen(sourceFile,'w');
            fprintf(fileID,'%s\n',A{:});
            fclose(fileID);
        end

        function[libraryFilePath,mdlName]=createSfunLibrary(obj,sfunName,srcBlock,params,modules,maskImpl,targetDir)
            mdlName=['library_',sfunName];
            if isempty(which(mdlName))
                mdlH=new_system(mdlName,'Library');

                blkName=[mdlName,'/',sfunName];
                if isempty(srcBlock)
                    add_block('built-in/S-Function',blkName);
                else
                    add_block(srcBlock,blkName);
                end
                if~isempty(params)
                    set_param(blkName,'Parameters',params);
                end
                set_param(blkName,'FunctionName',sfunName);
                if~isempty(modules)
                    set_param(blkName,'SFunctionModules',modules);
                end
                if~maskImpl
                    maskObj=Simulink.Mask.create(blkName);
                    maskObj.Description='Default Mask';
                else
                    Simulink.SFcnPackage.applyMask(sfunName,...
                    obj.ProjectRoot,fullfile(obj.ProjectRoot,sfunName),getSimulinkBlockHandle(blkName));
                end
                set_param(mdlName,'EnableLBRepository','on');
                save_system(mdlH,fullfile(targetDir,mdlName));
                libraryFilePath=fullfile(targetDir,[mdlName,'.slx']);
            else
                disp('Library is not created since one exists.');
                libraryFilePath=fullfile(targetDir,[mdlName,'.slx']);
            end
        end

        function applyParamsAndMaskOnPackagedSfun(obj,sfunName,params,blkName,removeExistingMask)


            if~isempty(params)&&...
                isstruct(params)

                paramNames='';
                paramValues='';
                if isfield(params,'paramNames')
                    paramNames=params.paramNames;
                end
                if isfield(params,'paramValues')
                    paramValues=params.paramValues;
                end


                idx=strcmp(paramNames,'Parameters');
                if any(idx)
                    set_param(blkName,paramNames{idx},paramValues{idx});
                end
                for i=1:numel(paramNames)
                    if isequal(i,idx)
                        continue
                    end
                    set_param(blkName,paramNames{i},paramValues{i});
                end
            end


            if removeExistingMask
                maskObj=Simulink.Mask.get(blkName);
                if~isempty(maskObj)
                    maskObj.delete();
                end
            end
            Simulink.SFcnPackage.applyMask(sfunName,...
            obj.ProjectRoot,fullfile(obj.ProjectRoot,sfunName),getSimulinkBlockHandle(blkName));

        end

        function libraryFilePath=createSfBuilderLibrary(obj,sfunName,targetDir,temp)

            if isequal(temp,1)
                targetDir=fullfile('resources',sfunName);
                if~isfolder(targetDir)
                    [~,~,~]=mkdir(targetDir);
                end
                mdlName=['tempSFB__library_',sfunName];
            else
                mdlName=['library_',sfunName];
            end
            mdlH=new_system(mdlName,'Library');
            load_system(mdlH);
            srcBlk=sprintf('simulink/User-Defined\nFunctions/S-Function Builder');
            blkName=[mdlName,'/',sfunName];
            add_block(srcBlk,blkName);
            set_param(blkName,'FunctionName',sfunName);
            if isequal(temp,1)
                set_param(mdlH,'Lock','off');
                save_system(mdlH);
            else
                set_param(blkName,'WizardData','IsBlockSDKSfBuilder');
                set_param(blkName,'CopyFcn','');
            end
            save_system(mdlH,[mdlName,'.slx']);
            close_system(mdlH,0);
            libraryFile=fullfile(pwd,[mdlName,'.slx']);
            movefile(libraryFile,fullfile(obj.ProjectRoot,targetDir));
            libraryFilePath=fullfile(targetDir,[mdlName,'.slx']);
        end

        function[libraryFilePath,mdlName,srcFile]=createSfunLibraryFromExample(obj,sfunName,exampleName,targetDir,sourceFolder)
            mdlName=['library_',sfunName];
            srcFile='';
            if isempty(which(mdlName))
                mdlH=new_system(mdlName,'Library');
                load_system(mdlH);

                blkName=[mdlName,'/',sfunName];


                srcBlocks=find_system(exampleName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','S-Function');
                if isequal(exampleName,'sfcndemo_runtime')
                    add_block(srcBlocks{4},blkName);
                else
                    add_block(srcBlocks{1},blkName);
                end
                set_param(blkName,'FunctionName',sfunName);
                maskObj=Simulink.Mask.get(blkName);
                if isempty(maskObj)
                    maskObj=Simulink.Mask.create(blkName);
                    maskObj.Description='Default Mask';
                else
                    temp=get_param(blkName,'MaskType');
                    if isequal(temp,'S-Function Builder')
                        set_param(blkName,'WizardData','IsBlockSDKSfBuilder');
                        set_param(blkName,'CopyFcn','');
                    end
                end
                if~isempty(sourceFolder)
                    oldSfunName=get_param(srcBlocks{1},'FunctionName');
                    oldfile=fullfile(matlabroot,'toolbox','simulink','simdemos','simfeatures','src',[oldSfunName,'.c']);
                    if exist(oldfile,'file')
                        filetext=fileread(oldfile);
                        newtext=regexprep(filetext,['#define\s*S_FUNCTION_NAME\s*',oldSfunName],['#define S_FUNCTION_NAME  ',sfunName]);
                        sourceFile=fullfile(obj.ProjectRoot,sourceFolder,[sfunName,'.c']);
                        srcFile=fullfile(sourceFolder,[sfunName,'.c']);
                        fid=fopen(sourceFile,'w');
                        fwrite(fid,newtext);
                        fclose(fid);
                    end
                end
                libraryFilePath=fullfile(targetDir,[mdlName,'.slx']);
                save_system(mdlH,obj.abPath(libraryFilePath),'BreakAllLinks',true);
            else
                disp('Library is not created since one exists.');
                libraryFilePath=fullfile(targetDir,[mdlName,'.slx']);
            end

        end

        function sfunInfo=copyExampleFilesToBlock(obj,sfunName,originalBlock,parent)
            finishup='';
            model='sfundemos';
            parentLibrary=obj.getBlockMetaData(parent,obj.OpenFunction);
            parentLibrary=obj.processName(parentLibrary);
            if(~bdIsLoaded(model))
                load_system(model);
                finishup=onCleanup(@()close_system(model,0));
            end
            exampleName=extractBetween(get_param(originalBlock,'openFcn'),'''','''');
            exampleName=exampleName{1};
            projectRootFolder=obj.Project.RootFolder;
            libFolder=fullfile(sfunName,'library');
            sourceFolder=fullfile(sfunName,'src');
            scriptFolder=fullfile(sfunName,'build');
            srcFile='';
            extraFlag='';
            headerFile='';
            sourceFile='';
            tlcFile='';
            cleanup='';
            if(~bdIsLoaded(exampleName))
                load_system(exampleName);
                cleanup=onCleanup(@()close_system(exampleName));
            end


            fileBoxes=find_system(exampleName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem','OpenFcn','sfundemo_openfcn');
            for i=1:numel(fileBoxes)
                midpath='';
                shortFileName=get_param(fileBoxes{i},'filename');
                if contains(shortFileName,'wrapper')
                    continue;
                end
                [~,name,ext]=fileparts(shortFileName);
                switch ext
                case '.tlc'
                    midpath=fullfile('toolbox','simulink','simdemos','simfeatures','tlc_c','');
                    tlcfile=fullfile(matlabroot,midpath,shortFileName);
                    destfolder=fullfile(projectRootFolder,sfunName,'mex');
                    filetext=fileread(tlcfile);
                    newtext=regexprep(filetext,['%implements\s*',name],['%implements ',sfunName]);
                    tlcFile=fullfile(destfolder,[sfunName,'.tlc']);
                    fid=fopen(tlcFile,'w');
                    fwrite(fid,newtext);
                    fclose(fid);
                case{'.c','.cpp'}
                    switch name
                    case 'sfun_atmos'
                        midpath=fullfile('toolbox','simulink','simdemos','simfeatures','srcFortran','');
                    otherwise
                        midpath=fullfile('toolbox','simulink','simdemos','simfeatures','src','');
                    end
                    destfolder=fullfile(projectRootFolder,sfunName,'src');
                    srcfile=fullfile(matlabroot,midpath,shortFileName);
                    filetext=fileread(srcfile);
                    newtext=regexprep(filetext,['#define\s*S_FUNCTION_NAME\s*',name],['#define S_FUNCTION_NAME  ',sfunName]);
                    sourceFile=fullfile(destfolder,[sfunName,ext]);
                    srcFile=fullfile(sourceFolder,[sfunName,ext]);
                    fid=fopen(sourceFile,'w');
                    fwrite(fid,newtext);
                    fclose(fid);
                    if find(strcmp({'sfun_matadd.c','sfun_cplx.c'},shortFileName))
                        extraSrcFile='sfun_slutils.c';
                        extraFlag='''-R2017b''';
                        extraFile=fullfile(matlabroot,midpath,extraSrcFile);
                        copyfile(extraFile,destfolder);
                        extraSrcDest=fullfile(destfolder,extraSrcFile);
                        fileattrib(extraSrcDest,'+w');
                        extraHeader='sfun_slutils.h';
                        midpath=fullfile('toolbox','simulink','simdemos','simfeatures','include');
                        extraHeaderFile=fullfile(matlabroot,midpath,extraHeader);
                        copyfile(extraHeaderFile,destfolder);
                        extraSrcDest=fullfile(destfolder,extraHeader);
                        fileattrib(extraSrcDest,'+w');
                    end

                    if contains(shortFileName,'sfbuilder')
                        extraSrcFile=[name,'_wrapper',ext];
                        extraFile=fullfile(matlabroot,midpath,extraSrcFile);
                        copyfile(extraFile,destfolder);
                        extraSrcDest=fullfile(destfolder,extraSrcFile);
                        fileattrib(extraSrcDest,'+w');
                        movefile(extraSrcDest,fullfile(destfolder,[sfunName,'_wrapper',ext]));
                        extraFlag=fullfile(sfunName,'src',[sfunName,'_wrapper',ext]);
                    end
                case{'.h','.hpp'}
                    midpath=fullfile('toolbox','simulink','simdemos','simfeatures','include');
                    file=fullfile(matlabroot,midpath,shortFileName);
                    destFolder=fullfile(projectRootFolder,sfunName,'src');
                    copyfile(file,destFolder);
                    headerFile=fullfile(destFolder,shortFileName);
                    fileattrib(headerFile,'+w');
                end
            end
            if isempty(srcFile)
                [libraryModelPath,library,srcFile]=obj.createSfunLibraryFromExample(sfunName,exampleName,libFolder,sourceFolder);
            else
                [libraryModelPath,library,~]=obj.createSfunLibraryFromExample(sfunName,exampleName,libFolder,'');
            end
            blockpath=[library,'/',sfunName];
            obj.addBlockToParentLibrary(sfunName,blockpath,parentLibrary);


            buildScriptPath=obj.createBuildScript(sfunName,srcFile,extraFlag,fullfile(obj.ProjectRoot,scriptFolder));
            buildScriptPath=obj.normPath(buildScriptPath);
            obj.Project.addFolderIncludingChildFiles(sfunName);

            sfunInfo=Simulink.BlocksetDesigner.SfunInfo(sfunName,blockpath,parent);

            sfunInfo.BLOCK_LIBRARY=libraryModelPath;
            sfunInfo.S_FUN_FILE=srcFile;
            sfunInfo.S_FUN_BUILD=buildScriptPath;
            sfunInfo.BUILD_CHECKBOX_ENABLE='true';
            sfunInfo.BUILD=obj.NOTRUN;
            sfunInfo.ISBUILDER='false';
            sfunInfo.S_FUN_FUNCTION_NAME=sfunName;

            blockId=sfunInfo.Id;
            obj.updateBlockList(blockId);
            obj.writeToDataModel(sfunInfo);

            obj.openLibraryAndRegisterIconListener(blockId,libraryModelPath,false);
            iconfile=obj.generateBlockIcon(blockId);
            obj.Project.addFile(obj.abPath(iconfile));
            sfunInfo.BLOCK_ICON=iconfile;
            obj.setBlockMetaData(blockId,obj.BLOCK_ICON,iconfile);

            obj.setFileType(obj.normPath(headerFile),obj.S_FUN_HEADER,blockId);
            obj.setFileType(obj.normPath(sourceFile),obj.S_FUN_FILE,blockId);
            obj.setFileType(obj.normPath(tlcFile),obj.S_FUN_TLC,blockId);
            obj.setFileType(buildScriptPath,obj.S_FUN_BUILD,blockId);
            obj.setFileType(libraryModelPath,obj.BLOCK_LIBRARY,blockId);
        end

        function buildScript=createBuildScript(obj,sfunName,sfcnFile,extraFlag,targetDir)
            buildScript='';
            if exist('blocksetroot.m','file')~=2
                obj.createRootScript(obj.ProjectRoot);
            end
            if exist(sfcnFile,'file')
                sfunctionFile=sfcnFile;
                sfunctionFile=obj.createWrapperString(sfunctionFile);

                addIncPaths='';
                addIncPaths=[addIncPaths,{obj.createWrapperString(fullfile(sfunName,'src'))}];
                isDebug='yes';
                mexDir=obj.createWrapperString(fullfile(sfunName,'mex'));

                buildScript=fullfile(targetDir,['mex_',sfunName,'.m']);
                if~isequal(extraFlag,'''-R2017b''')&&~isempty(extraFlag)
                    extraFlag=obj.createWrapperString(extraFlag);
                end
                customSrcAndLibAndObj=extraFlag;

                [~,~,mexCommandText]=Simulink.sfunction.analyzer.internal.sfuncSourceCompile(false,sfunctionFile,customSrcAndLibAndObj,...
                addIncPaths,{},mexDir,false,isDebug);
                fileID=fopen(buildScript,'w');
                fprintf(fileID,'%s\n',mexCommandText);
                fclose(fileID);
            end
        end

        function result=setupSfBuilderScript(obj,sfunName,blockId)
            sfbuilderScriptPath=fullfile(sfunName,'build',['mex_',sfunName,'.m']);
            libfile=obj.getBlockFilesByType(blockId,obj.BLOCK_LIBRARY);
            [~,library,~]=fileparts(libfile);
            mexCommandText=['finishup='''';',newline];
            mexCommandText=[mexCommandText,'if(~bdIsLoaded(''',library,'''))',newline];
            mexCommandText=[mexCommandText,'  load_system(''',library,''');',newline];
            mexCommandText=[mexCommandText,'  finishup=onCleanup(@()close_system(''',library,''',0));',newline];
            mexCommandText=[mexCommandText,'end',newline];
            mexCommandText=[mexCommandText,'blkHandle=get_param(''',library,'/',sfunName,''',''Handle'');',newline];
            mexCommandText=[mexCommandText,'appdata=sfunctionwizard(blkHandle,''GetApplicationData'');',newline];
            mexCommandText=[mexCommandText,'appdata=sfunctionwizard(blkHandle,''Build'',appdata);',newline];


            fileID=fopen(fullfile(obj.ProjectRoot,sfbuilderScriptPath),'w');
            fprintf(fileID,'%s\n',mexCommandText);
            fclose(fileID);
            obj.Project.addFile(sfbuilderScriptPath);
            obj.setFileType(sfbuilderScriptPath,obj.S_FUN_BUILD,blockId);
            result.BUILD=obj.NOTRUN;
            result.S_FUN_BUILD=sfbuilderScriptPath;
            result.BUILD_CHECKBOX_ENABLE='true';
            obj.setBlockOpStatus(blockId,{obj.BUILD,obj.S_FUN_BUILD,obj.BUILD_CHECKBOX_ENABLE},{obj.NOTRUN,sfbuilderScriptPath,'true'});
        end

        function output=readAndDeleteBuildLog(obj,logfile)
            output=fileread(logfile);
            delete(logfile);
        end

        function blockInfo=updateBlockOpStatus(obj,blockInfo)


            blockInfo=updateBlockOpStatus@Simulink.BlocksetDesigner.Block(obj,blockInfo);
            status=obj.buildStatus(blockInfo.Id);
            sfcnName=obj.getBlockMetaData(blockInfo.Id,'BlockName');

            if isfile(fullfile(obj.ProjectRoot,sfcnName,'package',[sfcnName,getSFcnPackageExtension]))
                if~isequal(status,'NOTRUN')



                    [mexStatus,~]=Simulink.SFcnPackage.getSFcnStatus(sfcnName,...
                    obj.ProjectRoot,fullfile(obj.ProjectRoot,sfcnName));
                    mexes=mexStatus.mex;
                    statuses=mexStatus.status;
                    idx=contains(mexes,mexext);
                    status=statuses{idx};
                    if strcmp(status,'OUTOFDATE')
                        status=obj.NOTRUN;
                    end
                else
                    [~,~]=Simulink.SFcnPackage.getSFcnStatus(sfcnName,...
                    obj.ProjectRoot,fullfile(obj.ProjectRoot,sfcnName));
                end
            end
            blockInfo.BUILD=status;

            if isequal(status,obj.WARNING)
                blockInfo.BUILD_CHECKBOX_ENABLE='false';
            else
                blockInfo.BUILD_CHECKBOX_ENABLE='true';
            end
            obj.setBlockOpStatus(blockInfo.Id,{obj.BUILD,obj.BUILD_CHECKBOX_ENABLE},{status,blockInfo.BUILD_CHECKBOX_ENABLE});
        end

        function status=buildStatus(obj,blockName)
            buildfile=obj.getBlockFilesByType(blockName,obj.S_FUN_BUILD);
            if(~isempty(buildfile))
                status=obj.getBlockMetaData(blockName,obj.BUILD);
                if(isequal(status,obj.WARNING))
                    status=obj.NOTRUN;
                end
            else
                status=obj.WARNING;
            end
        end

    end
end

