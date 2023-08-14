classdef Block<Simulink.BlocksetDesigner.BlockAuthoring




    properties

        supportedBlockTypes={'S-Function','SubSystem','MATLABSystem'};
    end

    methods(Access=public)
        function obj=Block()
            obj=obj@Simulink.BlocksetDesigner.BlockAuthoring();
        end

        function folders=getBlockFolders(obj,blockType)
            if isequal(blockType,'S-Function')
                folders={'doc','library','src','unittest','mex','build'};
            elseif isequal(blockType,'SubSystem')
                folders={'doc','library','unittest'};
            elseif isequal(blockType,'MATLABSystem')
                folders={'library','unittest','sysobj'};
            end
        end

        function result=isFileBasedProperty(obj,property)
            result=Simulink.BlocksetDesigner.BlockInfo.isFileBasedProperties(property)||...
            Simulink.BlocksetDesigner.SfunInfo.isFileBasedProperties(property)||...
            Simulink.BlocksetDesigner.MATLABSysInfo.isFileBasedProperties(property);
        end


        function create(obj,blockName,blockType)
            obj.createBlockFolders(blockName,blockType);
        end

        function blockInfo=import(obj,blockInfo)
            c=strsplit(blockInfo.BlockPath,'/');
            model=c{1};
            modelfile=which(model);
            LibraryFileText=extractAfter(modelfile,[obj.ProjectRoot,filesep]);
            if isempty(LibraryFileText)


                blockInfo.IsSupported=0;
                return;
            end
            LibraryFileText=obj.normalizeFilePath(LibraryFileText);
            blockName=blockInfo.BlockName;
            blockName=obj.processName(blockName);
            blockType=blockInfo.BlockType;

            if any(strcmp(obj.supportedBlockTypes,blockType))

                blockInfo.BLOCK_LIBRARY=LibraryFileText;

                obj.createBlockFolders(blockName,blockType);
                obj.Project.addFolderIncludingChildFiles(blockName);
                preTestHarness=blockInfo.TEST_HARNESS;
                if~exist(preTestHarness,'file')
                    testHarness=obj.findBlockFile(blockName,obj.TEST_HARNESS);
                    blockInfo.TEST_HARNESS=testHarness;
                end

                preTestScript=blockInfo.TEST_SCRIPT;
                if~exist(preTestScript,'file')
                    testScript=obj.findBlockFile(blockName,obj.TEST_SCRIPT);
                    if~isempty(testScript)
                        blockInfo.TEST_SCRIPT=testScript;
                        blockInfo.TEST=obj.NOTRUN;
                        blockInfo.TEST_CHECKBOX_ENABLE='true';
                    end
                end

                preDocFile=blockInfo.DOC_FILE;
                if~exist(preDocFile,'file')
                    docfile=obj.findBlockFile(blockName,obj.DOC_FILE);
                    if~isempty(docfile)
                        blockInfo.DOC_FILE=docfile;
                        blockInfo.DOCUMENT=obj.PASS;
                    end
                end

                preDocScript=blockInfo.DOC_SCRIPT;
                if~exist(preDocScript,'file')
                    docscript=obj.findBlockFile(blockName,obj.DOC_SCRIPT);
                    if~isempty(docscript)
                        blockInfo.DOC_SCRIPT=docscript;
                        blockInfo.DOCUMENT=obj.NOTRUN;
                        blockInfo.DOCUMENT_CHECKBOX_ENABLE='true';
                    end
                end

                blockId=blockInfo.Id;
                obj.updateBlockList(blockId);
                obj.writeToDataModel(blockInfo);
            end
        end


        function blockData=editBlockLibrary(obj,blockId)
            libFile=obj.getBlockFilesByType(blockId,obj.BLOCK_LIBRARY);
            blockData='';
            if~isempty(libFile)&&exist(libFile,'file')
                blockData=obj.openLibraryAndRegisterIconListener(blockId,libFile,true);
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',libFile),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end
        end

        function editBlockMask(obj,blockId)
            obj.editBlockLibrary(blockId);
            blockpath=obj.getBlockMetaData(blockId,'BlockPath');
            handle=getSimulinkBlockHandle(blockpath);
            if handle==-1
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockNotFound',blockpath),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            obj.openMaskEditor(blockpath);

        end

        function editBlockIcon(obj,blockId)
            obj.editBlockLibrary(blockId);
            blockpath=obj.getBlockMetaData(blockId,'BlockPath');
            handle=getSimulinkBlockHandle(blockpath);
            if handle==-1
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKBlockNotFound',blockpath),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                return;
            end
            obj.openIconEditor(blockpath);
        end


        function result=createTestHarness(obj,blockId)
            result.TEST=obj.WARNING;
            result.TEST_HARNESS='';
            result.TEST_SCRIPT='';
            result.TEST_CHECKBOX_ENABLE='false';
            result.TEST_CHECKBOX='false';

            libFile=obj.getBlockFilesByType(blockId,obj.BLOCK_LIBRARY);
            if~isempty(libFile)
                blockName=obj.getBlockMetaData(blockId,'BlockName');
                blockName=obj.processName(blockName);
                if~exist(obj.abPath(blockName),'dir')
                    msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoBlockFolder',blockName,blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    obj.setBlockOpStatus(blockId,obj.TEST,obj.WARNING);
                    return;
                end
                [~,model,~]=fileparts(libFile);
                isLoaded=bdIsLoaded(model);
                finishup='';
                if(~isLoaded)
                    load_system(model);
                    finishup=onCleanup(@()close_system(model,0));
                end
                blockPath=obj.getBlockMetaData(blockId,'BlockPath');
                handle=getSimulinkBlockHandle(blockPath);
                if handle~=-1
                    blockType=get_param(blockPath,'BlockType');
                    if isequal(blockType,'S-Function')
                        sfcnName=obj.getBlockMetaData(blockId,obj.S_FUN_FUNCTION_NAME);
                        if isempty(which([sfcnName,'.',mexext]))
                            msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnMEXNOTExist',blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                            return;
                        end
                    end
                    sfunTestMdlDir=obj.abPath(fullfile(blockName,'unittest'));
                    if~exist(sfunTestMdlDir,'dir')
                        mkdir(sfunTestMdlDir);
                        obj.Project.addFolderIncludingChildFiles(sfunTestMdlDir);
                        obj.Project.addPath(sfunTestMdlDir);
                    end
                    [sfunTestFilePath,matFile,errorstatus,me,tempmodel]=obj.createTestHarnessModel(blockPath,obj.normPath(sfunTestMdlDir));
                    if errorstatus==0
                        obj.Project.addFile(fullfile(obj.ProjectRoot,sfunTestFilePath));
                        if~isempty(matFile)
                            obj.Project.addFile(fullfile(obj.ProjectRoot,matFile));
                        end

                        obj.setFileType(sfunTestFilePath,obj.TEST_HARNESS,blockId);
                        [~,testHarness,~]=fileparts(sfunTestFilePath);
                        open_system(testHarness);
                        if~isempty(matFile)
                            set_param([testHarness,'/Harness Inputs'],'FileName',obj.abPath(matFile));
                            save_system(testHarness);
                        end
                        obj.addBlockFile(blockId,obj.TEST_HARNESS,sfunTestFilePath);

                        testScriptPath=obj.createTestScript(blockName);
                        obj.addBlockFile(blockId,obj.TEST_SCRIPT,testScriptPath);
                        obj.setBlockOpStatus(blockId,{obj.TEST_HARNESS,obj.TEST_SCRIPT,obj.TEST_CHECKBOX_ENABLE,obj.TEST},...
                        {sfunTestFilePath,testScriptPath,'true',obj.NOTRUN});
                        result.TEST=obj.NOTRUN;
                        result.TEST_HARNESS=sfunTestFilePath;
                        result.TEST_SCRIPT=testScriptPath;
                        result.TEST_CHECKBOX_ENABLE='true';
                        result.TEST_CHECKBOX='true';
                    else
                        msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKTestHarnessCreationFail'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                        lc=obj.getLastCause(me);
                        strrep(lc.message,tempmodel,'')
                    end

                else
                    msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnNoBlockInModel',blockName,model),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                end
            end
        end

        function result=runTests(obj,varargin)
            result.TEST=obj.WARNING;
            result.TEST_TIMESTAMP='';
            result.TEST_REPORT='';
            import matlab.unittest.TestRunner;
            import matlab.unittest.TestSuite;
            import matlab.unittest.plugins.TestReportPlugin;
            blockId=varargin{1};
            blockName=obj.getBlockMetaData(blockId,'BlockName');
            blockName=obj.processName(blockName);
            testScript=obj.getBlockFilesByType(blockId,obj.TEST_SCRIPT);
            [~,filename,~]=fileparts(testScript);
            if(~isempty(testScript))
                if~exist(obj.abPath(blockName),'dir')
                    msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoBlockFolder',blockName,blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    obj.setBlockOpStatus(blockId,obj.TEST,obj.NOTRUN);
                    result.TEST=obj.NOTRUN;
                    return;
                end
                try
                    suite=TestSuite.fromFile(obj.abPath(testScript));
                catch e
                    msgbox(e.message,DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    return;
                end
                runner=TestRunner.withTextOutput;
                htmlFolder=fullfile(obj.ProjectRoot,blockName,'unittest','derived');
                if~exist(htmlFolder,'dir')
                    mkdir(htmlFolder);
                end
                resultFile=fullfile(htmlFolder,[filename,'_report.html']);
                plugin=TestReportPlugin.producingHTML(htmlFolder,'MainFile',[filename,'_report.html']);
                plugin2=Simulink.BlocksetDesigner.internal.TestCancelPlugin();
                runner.addPlugin(plugin);
                runner.addPlugin(plugin2);
                testTimeStamp=datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'));
                try
                    resultStruct=runner.run(suite);
                catch ex
                    if~strcmp(ex.identifier,'Simulink:BlockSetDesigner:CancelInterrupt')
                        rethrow(ex);
                    end
                    resultStruct=plugin2.Results;
                end
                obj.Project.addFile(resultFile);
                obj.Project.addFolderIncludingChildFiles(fullfile(htmlFolder,'images'));
                obj.Project.addFolderIncludingChildFiles(fullfile(htmlFolder,'stylesheets'));
                obj.setFileType(obj.normPath(resultFile),obj.TEST_REPORT,blockId);
                disc1=fullfile(htmlFolder,'_rels');
                if exist(disc1,'dir')
                    rmdir(disc1,'s');
                end
                disc2=fullfile(htmlFolder,'[Content_Types].xml');
                if exist(disc2,'file')
                    delete(disc2);
                end
                if(nargin~=3)
                    open(resultFile);
                end
                temp=false;
                result.TEST=obj.PASS;
                for i=1:numel(resultStruct)
                    if temp
                        break;
                    end
                    temp=resultStruct(i).Failed||temp;
                end
                if temp
                    result.TEST=obj.FAIL;
                end
                obj.setBlockOpStatus(blockId,{obj.TEST,obj.TEST_TIMESTAMP,obj.TEST_REPORT},{result.TEST,testTimeStamp,obj.normPath(resultFile)});
                result.TEST_TIMESTAMP=testTimeStamp;
                result.TEST_REPORT=obj.normPath(resultFile);
            end
        end

        function result=runChecks(obj,blockId)
            modelFile=obj.getBlockFilesByType(blockId,obj.TEST_HARNESS);
            blockName=obj.getBlockMetaData(blockId,'BlockName');
            if(isempty(modelFile))
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnNoTestHarness',blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                result=obj.NOTRUN;
                return;
            end
            result=0;

            modeladvisor(modelFile);
        end

        function openTestReport(obj,blockName)
            file=obj.getBlockFilesByType(blockName,obj.TEST_REPORT);
            file=obj.restoreFilePath(file);
            if(~isempty(file)&&exist(file,'file'))
                open(obj.abPath(file));
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',file),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end
        end

        function openTestScript(obj,sfunName)
            testScript=obj.getBlockFilesByType(sfunName,obj.TEST_SCRIPT);
            if(~isempty(testScript))
                [~,~,ext]=fileparts(testScript);
                switch ext
                case '.m'
                    edit(testScript);
                case '.mldatx'
                    sltest.testmanager.load(testScript);
                    sltest.testmanager.view;

                    mgr=sltest.internal.Events.getInstance();
                    mgr.addlistener('SimulationCompleted',@obj.testCompletedCallBack);
                end
            end
        end

        function testCompletedCallBack(~,~,testEvent)






            testResult=testEvent.ResultSet;
        end

        function openTestHarness(obj,sfunName)
            testModel=obj.getBlockFilesByType(sfunName,obj.TEST_HARNESS);
            if~isempty(testModel)&&exist(testModel,'file')
                open(testModel);
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',testModel),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end
        end

        function openCheckReport(obj,blockName)
            checkReport=obj.getBlockFilesByType(blockName,obj.CHECK_REPORT);
            if~isempty(checkReport)
                rptgen.rptview(checkReport);
            end
        end


        function result=createDoc(obj,blockId)
            helpFile=obj.getBlockFilesByType(blockId,obj.DOC_SCRIPT);
            result='';
            if~isempty(helpFile)
                edit(helpFile);
            else
                result=obj.createDocBasedOnMask(blockId);
            end
        end


        function result=publishDoc(obj,blockId)
            blockType=obj.getBlockMetaData(blockId,'BlockType');
            result.DOCUMENT=obj.NOTRUN;
            result.DOC_FILE='';
            result.DOCUMENT_TIMESTAMP='';
            if isequal(blockType,'MATLABSystem')
                result.DOCUMENT=obj.PASS;
                return;
            end
            projectRoot=char(obj.Project.RootFolder);
            helpFile=obj.getBlockFilesByType(blockId,obj.DOC_SCRIPT);
            sfunName=obj.getBlockMetaData(blockId,'BlockName');
            if~exist(sfunName,'dir')
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoBlockFolder',sfunName,sfunName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                obj.setBlockOpStatus(blockId,obj.DOCUMENT,obj.NOTRUN);
                return;
            end
            docBase=fullfile(sfunName,'doc');
            if~exist(obj.abPath(docBase),'dir')
                mkdir(obj.abPath(docBase));
            end
            if exist(helpFile,'file')
                htmlFile=fullfile(docBase,['help_',sfunName,'.html']);
                matlab.internal.liveeditor.openAndConvert(fullfile(projectRoot,helpFile),obj.abPath(htmlFile));
                if(nargin~=3)
                    web(obj.abPath(htmlFile));
                end
                obj.addBlockFile(blockId,obj.DOC_FILE,htmlFile);
                obj.setBlockOpStatus(blockId,{obj.DOCUMENT,obj.DOC_FILE,obj.DOCUMENT_TIMESTAMP},...
                {obj.PASS,htmlFile,datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'))});
                result.DOCUMENT=obj.PASS;
                result.DOC_FILE=htmlFile;
                result.DOCUMENT_TIMESTAMP=datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'));
            end
        end

        function openDoc(obj,sfunName)
            helpFile=obj.getBlockFilesByType(sfunName,obj.DOC_SCRIPT);
            if~isempty(helpFile)
                edit(helpFile);
            end
        end

        function openHtml(obj,sfunName)
            helpFile=obj.getBlockFilesByType(sfunName,obj.DOC_FILE);
            if~isempty(helpFile)&&exist(helpFile,'file')
                open(helpFile);
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',helpFile),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end
        end

        function deleteBlock(obj,blockId)
            blockName=obj.getBlockMetaData(blockId,'BlockName');
            blockPath=obj.getBlockMetaData(blockId,'BlockPath');
            blockFolder=fullfile(obj.ProjectRoot,blockName);



            isSfun=strcmp(obj.getBlockMetaData(blockId,'BlockType'),'S-Function');
            if isSfun
                if strcmp(obj.getBlockMetaData(blockId,obj.ISPACKAGED),'true')
                    authoringToolFolder=fullfile(obj.ProjectRoot,'resources',blockName);


                    if isfolder(authoringToolFolder)
                        rmdir(authoringToolFolder,"s");
                    end
                end
            end

            libraryFile=obj.getBlockFilesByType(blockId,obj.BLOCK_LIBRARY);
            if~isempty(libraryFile)&&exist(libraryFile,'file')==4
                close_system(libraryFile,0);
                impacted=obj.getImpactedFilesFromDA(libraryFile);
                obj.removeBlockFromLinkedLibraries(blockPath,impacted);
            end
            if exist(blockFolder,'dir')==7
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:deleteFilesFromProject')));
                pathsep=':';
                if ispc
                    pathsep=';';
                end
                subdirs=strsplit(genpath(blockFolder),pathsep);
                for i=1:numel(subdirs)
                    if~isempty(subdirs{i})
                        try
                            removePath(obj.Project,subdirs{i});
                        catch
                        end
                    end
                end
                clear mex;
                rmdir(fullfile(obj.ProjectRoot,blockName),'s');
                removeFile(obj.Project,blockFolder);
            end

            blockFileTypes={obj.S_FUN_MEX_FILE,obj.S_FUN_FILE,obj.DOC_SCRIPT,...
            obj.DOC_FILE,obj.TEST_SCRIPT,obj.TEST_HARNESS,...
            obj.BLOCK_LIBRARY,obj.S_FUN_BUILD};
            data=obj.getBlockMetaData(blockId,blockFileTypes);
            for i=1:numel(data)
                if exist(data{i},'file')
                    delete(data{i});
                end
            end

            obj.deleteBlockMetaData(blockId);
            projectRoot=obj.Project.RootFolder;
            dataMap=obj.getFileMetaData(projectRoot);
            blockList=char(dataMap.get('blockList'));
            s1=[blockId,';'];
            s2=[';',blockId];
            if contains(blockList,s1)
                blockList=erase(blockList,s1);
            elseif contains(blockList,s2)
                blockList=erase(blockList,s2);
            elseif contains(blockList,blockId)
                blockList='';
            end
            dataMap=containers.Map();
            dataMap('blockList')=blockList;
            obj.setFileMetaData(obj.Project.RootFolder,dataMap);

        end

        function blockInfo=renameBlock(obj,blockInfo,newName)
            if~isvarname(newName)
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKInvalidIdentifier',newName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
                newName=obj.processName(newName);
            end
            if exist(['library_',newName,'.slx'],'file')==4
                msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKSfcnExist'),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                blockInfo="";
                return;
            end
            oldName=blockInfo.BlockName;
            blockInfo.BlockName=newName;
            blockType=blockInfo.BlockType;
            blockId=blockInfo.Id;
            oldBlockPath=blockInfo.BlockPath;
            oldBlockLibraryFile=blockInfo.BLOCK_LIBRARY;
            close_system(oldBlockLibraryFile,0);
            impacted=obj.getImpactedFilesFromDA(oldBlockLibraryFile);

            if exist(fullfile(obj.ProjectRoot,oldName),'dir')
                obj.updateProgressBar(getString(message('slblocksetdesigner:messages:removeFilesFromProject')));
                folders=obj.getBlockFolders(blockType);
                for i=1:numel(folders)
                    obj.Project.removeFile(fullfile(obj.ProjectRoot,oldName,folders{i}));
                end
                obj.Project.removeFile(oldName);
                movefile(fullfile(obj.ProjectRoot,oldName),fullfile(obj.ProjectRoot,newName),'f');
                obj.Project.addFolderIncludingChildFiles(newName);
                for i=1:numel(folders)
                    addPath(obj.Project,fullfile(obj.ProjectRoot,newName,folders{i}));
                end
                addPath(obj.Project,fullfile(obj.ProjectRoot,newName));
            end

            blockFileTypes={obj.S_FUN_FILE,obj.DOC_SCRIPT,...
            obj.DOC_FILE,obj.TEST_SCRIPT,obj.TEST_HARNESS,...
            obj.BLOCK_LIBRARY,obj.S_FUN_BUILD,obj.TEST_REPORT};
            files=obj.getBlockMetaData(blockId,blockFileTypes);
            tfiles=cell(1,numel(files));
            for i=1:numel(files)
                tfiles{i}=strrep(files{i},[oldName,filesep],[newName,filesep]);
            end

            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:addFilesToProject')));
            newfiles=cell(1,numel(files));
            for i=1:numel(files)
                newfiles{i}='';
                if exist(tfiles{i},'file')
                    newfiles{i}=strrep(files{i},oldName,newName);
                    if~isequal(newfiles{i},files{i})
                        obj.Project.removeFile(tfiles{i});
                        movefile(obj.abPath(tfiles{i}),obj.abPath(newfiles{i}),'f');
                        obj.Project.addFile(obj.abPath(newfiles{i}));
                        blockInfo.(blockFileTypes{i})=newfiles{i};
                        obj.setFileType(newfiles{i},blockFileTypes{i},blockId);
                    end
                end
            end
            obj.setBlockMetaData(blockId,blockFileTypes,newfiles);

            obj.setBlockMetaData(blockId,{obj.TEST,obj.TEST_TIMESTAMP},{obj.OUTOFDATE,''});
            blockInfo.TEST=obj.OUTOFDATE;
            blockInfo.TEST_TIMESTAMP='';

            if~isequal(blockType,'MATLABSystem')
                obj.setBlockMetaData(blockId,{obj.DOCUMENT,obj.DOCUMENT_TIMESTAMP},{obj.OUTOFDATE,''});
                blockInfo.DOCUMENT=obj.OUTOFDATE;
                blockInfo.DOCUMENT_TIMESTAMP='';

                docScript=obj.getBlockMetaData(blockId,obj.DOC_SCRIPT);
                if exist(docScript,'file')
                    obj.updateStringInMLX(docScript,oldName,newName);
                end
            end



            blockLibraryFile=obj.getBlockMetaData(blockId,obj.BLOCK_LIBRARY);
            if isempty(blockLibraryFile)||~exist(blockLibraryFile,'file')
                return;
            end
            [~,library,~]=fileparts(blockLibraryFile);
            load_system(library);
            set_param(library,'Lock','off');
            targetBlockPath=[library,'/',oldName];
            handle=getSimulinkBlockHandle(targetBlockPath);
            if(handle~=-1)
                set_param(handle,'Name',newName);
            end
            set_param(library,'Lock','on');
            newBlockPath=[library,'/',newName];
            blockInfo.BlockPath=newBlockPath;
            obj.setBlockMetaData(blockId,{'BlockPath','BlockName'},{newBlockPath,newName});
            save_system(library,obj.abPath(blockLibraryFile));
            result=obj.openLibraryAndRegisterIconListener(blockId,blockLibraryFile,true);
            blockInfo=obj.assignFieldsToProperties(blockInfo,result);


            if isequal(blockType,'S-Function')
                mexFilePath=obj.getBlockMetaData(blockId,'S_FUN_MEX_FILE');
                if~exist(mexFilePath,'file')
                    obj.setBlockMetaData(blockId,obj.S_FUN_FUNCTION_NAME,newName);
                    set_param(newBlockPath,'FunctionName',newName)
                    blockInfo.S_FUN_FUNCTION_NAME=newName;
                end
            end



            for i=1:numel(impacted)
                if exist(impacted{i},'file')&&~isequal(impacted{i},obj.abPath(blockLibraryFile))
                    [~,library,ext]=fileparts(impacted{i});
                    if isequal(ext,'.slx')
                        cleanup1='';
                        cleanup2='';
                        blocks='';
                        targetParam='';
                        if~bdIsLoaded(library)
                            w=warning('off','Simulink:Libraries:MissingLibrary');
                            load_system(library);
                            cleanup1=onCleanup(@()close_system(library));
                            cleanup2=onCleanup(@()warning(w));
                            targetParam='SourceBlock';
                        else
                            targetParam='ReferenceBlock';
                        end


                        blocks=find_system(library,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,targetParam,oldBlockPath);
                        set_param(library,'Lock','off');
                        for j=1:numel(blocks)
                            set_param(blocks{j},targetParam,newBlockPath);
                            if j==1
                                set_param(blocks{j},'Name',newName);
                            else
                                set_param(blocks{j},'Name',[newName,int2str(j)]);
                            end
                        end
                        save_system(library);
                    end
                end
            end


            testHarness=obj.getBlockMetaData(blockId,obj.TEST_HARNESS);
            if exist(testHarness,'file')
                [~,model,~]=fileparts(testHarness);
                cleanup1='';
                cleanup2='';
                blocks='';
                targetParam='';
                if~bdIsLoaded(model)
                    w=warning('off','Simulink:Libraries:MissingLibrary');
                    load_system(model);
                    cleanup1=onCleanup(@()close_system(model,0));
                    cleanup2=onCleanup(@()warning(w));
                    targetParam='SourceBlock';
                else
                    targetParam='ReferenceBlock';
                end


                blocks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,targetParam,oldBlockPath);
                for j=1:numel(blocks)
                    set_param(blocks{j},targetParam,newBlockPath);
                    if j==1
                        set_param(blocks{j},'Name',newName);
                    else
                        set_param(blocks{j},'Name',[newName,int2str(j)]);
                    end
                end

                signalEditorOldHarness=['harness_',oldName,'_HarnessInputs.mat'];
                signalEditorHarnessCurrentPath=fullfile(obj.ProjectRoot,newName,'unittest',signalEditorOldHarness);
                if exist(signalEditorHarnessCurrentPath,'file')==2
                    signalEditorNewHarness=['harness_',newName,'_HarnessInputs.mat'];
                    signalEditorHarnessNewPath=fullfile(obj.ProjectRoot,newName,'unittest',signalEditorNewHarness);
                    movefile(signalEditorHarnessCurrentPath,signalEditorHarnessNewPath,'f');
                    signalEditorHarnessOldPath=fullfile(obj.ProjectRoot,oldName,'unittest',signalEditorOldHarness);


                    blocks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FileName',signalEditorHarnessOldPath);
                    for j=1:numel(blocks)
                        set_param(blocks{j},'FileName',signalEditorHarnessNewPath);
                        portHandles=get_param(blocks{j},'PortHandles');
                        [~,portNum]=size(portHandles.Outport);
                        if(portNum>1)


                            inputSignalConvertBlocks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'tag','__SLT_ICS__');
                            for k=1:numel(inputSignalConvertBlocks)
                                in_lineHandle=get_param(inputSignalConvertBlocks{k},'LineHandles');
                                delete_line(in_lineHandle.Inport);
                                for q=1:portNum
                                    try
                                        add_line(model,[extractAfter(blocks{j},strlength(model)+1),'/',num2str(q)],[extractAfter(inputSignalConvertBlocks{k},strlength(model)+1),'/',num2str(q)]);
                                    catch ex
                                    end
                                end
                            end
                        end
                    end
                end
                save_system(model);
            end


            if isequal(blockType,'S-Function')
                buildScript=obj.getBlockMetaData(blockId,obj.S_FUN_BUILD);
                sfunFile=obj.getBlockMetaData(blockId,obj.S_FUN_FILE);
                obj.updateBlockNameInFile(buildScript,oldName,newName);

                isSfbuilder=obj.getBlockMetaData(blockId,obj.ISBUILDER);
                if isequal(isSfbuilder,'true')


                    obj.build(blockId,0);
                else
                    obj.updateBlockNameInFile(sfunFile,oldName,newName);
                    blockInfo.BUILD=obj.NOTRUN;
                    blockInfo.BUILD_TIMESTAMP='';
                    obj.setBlockMetaData(blockId,{obj.BUILD,obj.BUILD_TIMESTAMP},{obj.NOTRUN,''});
                end

            end


            testScript=obj.getBlockMetaData(blockId,obj.TEST_SCRIPT);
            if exist(testScript,'file')
                obj.updateBlockNameInFile(testScript,oldName,newName);
            end

        end

        function result=blockFileChanged(obj,blockId,fileType)
            result.blockId=blockId;
            if isequal(fileType,obj.S_FUN_FILE)||isequal(fileType,obj.SYSTEM_OBJECT_FILE)
                testScript=obj.getBlockMetaData(blockId,obj.TEST_SCRIPT);
                if~isempty(testScript)
                    obj.setBlockOpStatus(blockId,obj.TEST,obj.OUTOFDATE);
                    result.TEST=obj.OUTOFDATE;
                end
            end
            if isequal(fileType,obj.S_FUN_FILE)
                obj.setBlockOpStatus(blockId,obj.BUILD,obj.OUTOFDATE);
                result.BUILD=obj.OUTOFDATE;
            end
            if isequal(fileType,obj.TEST_SCRIPT)||isequal(fileType,obj.TEST_HARNESS)
                obj.setBlockOpStatus(blockId,obj.TEST,obj.OUTOFDATE);
                result.TEST=obj.OUTOFDATE;
            end
            if isequal(fileType,obj.DOC_SCRIPT)
                obj.setBlockOpStatus(blockId,obj.DOCUMENT,obj.OUTOFDATE);
                result.DOCUMENT=obj.OUTOFDATE;
            end
        end

        function moveBlock(obj,blockId,oldParentLibrary,newParentLibrary)
            blockName=obj.getBlockMetaData(blockId,'BlockName');
            blockPath=obj.getBlockMetaData(blockId,'BlockPath');
            obj.updateProgressBar(getString(message('slblocksetdesigner:messages:moveBlockToNewLibrary')));
            obj.addBlockToParentLibrary(blockName,blockPath,newParentLibrary);
            obj.removeBlockFromLinkedLibraries(blockPath,{[oldParentLibrary,'.slx']});
        end


        function blockInfo=setBlockInfo(obj,blockInfo)




            obj.writeToDataModel(blockInfo);
            properties=fields(blockInfo);
            for i=1:numel(properties)
                if obj.isFileBasedProperty(properties{i})

                    field=properties{i};
                    value=blockInfo.(field);
                    val='';
                    file=obj.getBlockFilesByType(blockInfo.Id,field);
                    obj.setFileType(file,obj.UNDEFINED,'');
                    if~isempty(value)
                        val=obj.parseUIInput(value,'all');
                    end
                    for j=1:numel(val)
                        obj.setFileType(val{j},field,blockInfo.Id);
                    end
                end
            end

            blockInfo=obj.updateBlockOpStatus(blockInfo);
        end

    end

    methods(Hidden=true)

        function result=findSfunctionFileInProject(obj,blockName,sfunName,type)
            result='';
            switch type
            case 'src'
                srcfile=which([sfunName,'.c']);
                srcFileText=extractAfter(srcfile,[obj.ProjectRoot,filesep]);
                if~isempty(srcFileText)
                    result=srcFileText;
                    return;
                end
            case 'mex'
                mexfile=which([sfunName,'.',mexext]);
                mexfileText=extractAfter(mexfile,[obj.ProjectRoot,filesep]);
                if~isempty(mexfileText)
                    result=mexfileText;
                    return;
                end
            end
            rootfolder=fullfile(obj.ProjectRoot,blockName);
            if ispc
                subfolders=strsplit(genpath(rootfolder),';');
            else
                subfolders=strsplit(genpath(rootfolder),':');
            end
            for j=1:numel(subfolders)
                folder=subfolders{j};
                if~isempty(folder)
                    switch type
                    case obj.S_FUN_BUILD
                        filepath=fullfile(folder,['mex_',sfunName,'.m']);
                        if exist(filepath,'file')==2
                            result=obj.normPath(filepath);
                            return;
                        end
                    end
                end
            end
        end

        function result=findMATLABSystemFile(obj,mlsysName,filetype)
            result='';
            switch filetype
            case obj.SYSTEM_OBJECT_FILE
                sysobjfile=which([mlsysName,'.m']);
                sysobjfileText=extractAfter(sysobjfile,[obj.ProjectRoot,filesep]);
                if~isempty(sysobjfileText)
                    result=sysobjfileText;
                end

            end
        end

        function file=findBlockFile(obj,blockName,fileType)
            file='';

            switch fileType
            case obj.TEST_HARNESS
                targetFolder=fullfile(blockName,'unittest');
                if exist(targetFolder,'dir')==7
                    files=dir(targetFolder);
                    for i=1:numel(files)
                        if~(files(i).isdir)
                            [~,~,ext]=fileparts(files(i).name);
                            if isequal(ext,'.slx')||isequal(ext,'.mdl')
                                file=obj.normPath(fullfile(files(i).folder,files(i).name));
                            end
                        end
                    end
                end
            case obj.TEST_SCRIPT
                targetFolder=fullfile(blockName,'unittest');
                if exist(targetFolder,'dir')==7
                    files=dir(targetFolder);
                    for i=1:numel(files)
                        if~(files(i).isdir)
                            [~,~,ext]=fileparts(files(i).name);
                            if isequal(ext,'.m')
                                file=obj.normPath(fullfile(files(i).folder,files(i).name));
                            end
                        end
                    end
                end
            case obj.DOC_FILE
                targetFile=fullfile('common','doc',['help_',blockName,'.html']);
                if exist(targetFile,'file')
                    file=targetFile;
                end
            case obj.DOC_SCRIPT
                targetFolder=fullfile(blockName,'doc');
                if exist(targetFolder,'dir')==7
                    files=dir(targetFolder);
                    for i=1:numel(files)
                        if~(files(i).isdir)
                            [~,~,ext]=fileparts(files(i).name);
                            if isequal(ext,'.mlx')||isequal(ext,'.m')
                                file=obj.normPath(fullfile(files(i).folder,files(i).name));
                            end
                        end
                    end
                end
            end
        end

        function createBlockFolders(obj,blockName,blockType)
            projectRoot=obj.ProjectRoot;
            blockFolder=blockName;
            proj=obj.Project;
            isnew=false;
            if~exist(fullfile(projectRoot,blockFolder),'dir')
                isnew=true;
                [status,msg,msgid]=mkdir(fullfile(projectRoot,blockFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(blockFolder);
            end

            unitTestFolder=[blockFolder,filesep,'unittest'];
            testDerived=fullfile(unitTestFolder,'derived');
            if~exist(fullfile(projectRoot,unitTestFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,unitTestFolder));
                [~,~,~]=mkdir(fullfile(projectRoot,testDerived));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(unitTestFolder);
            end

            libFolder=[blockFolder,filesep,'library'];
            libDerived=fullfile(libFolder,'derived');
            if~exist(fullfile(projectRoot,libFolder),'dir')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,libFolder));
                [~,~,~]=mkdir(fullfile(projectRoot,libDerived));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(libFolder);
            end

            docFolder=[blockFolder,filesep,'doc'];
            if~exist(fullfile(projectRoot,docFolder),'dir')&&~isequal(blockType,'MATLABSystem')
                [status,msg,msgid]=mkdir(fullfile(projectRoot,docFolder));
                if status~=1
                    error(msgid,msg);
                end
                proj.addPath(docFolder);
            end
        end




        function blockInfo=loadBlockInfo(obj,blockInfo)


            blockPath=blockInfo.BlockPath;
            blockList=strsplit(obj.getBlocksInProject(),';');
            blockId='';
            for i=1:numel(blockList)
                temp=obj.getBlockMetaData(blockList{i},'BlockPath',blockPath);
                if strcmp(blockPath,temp)
                    blockId=blockList{i};
                    break;
                end
            end


            if~isempty(blockId)
                blockInfo.Id=blockId;


                fields=properties(blockInfo);
                values=obj.getBlockMetaData(blockId,fields);
                for i=1:numel(fields)
                    blockInfo.(fields{i})=values{i};
                end


                blockInfo=obj.import(blockInfo);
                blockInfo=obj.updateBlockOpStatus(blockInfo);
            else

                blockInfo=obj.import(blockInfo);
            end
        end

        function blockInfo=updateBlockOpStatus(obj,blockInfo)


            blockName=blockInfo.Id;
            testStatus=obj.testStatus(blockName);
            blockInfo.TEST=testStatus;


            if isequal(testStatus,obj.WARNING)
                blockInfo.TEST_CHECKBOX_ENABLE='false';
            else
                blockInfo.TEST_CHECKBOX_ENABLE='true';
            end


            docScript=obj.getBlockFilesByType(blockName,obj.DOC_SCRIPT);
            if isempty(docScript)
                blockInfo.DOCUMENT_CHECKBOX_ENABLE='false';
            else
                blockInfo.DOCUMENT_CHECKBOX_ENABLE='true';
            end

            docStatus=obj.documentStatus(blockName);
            blockInfo.DOCUMENT=docStatus;
            obj.setBlockOpStatus(blockName,{obj.TEST,obj.TEST_CHECKBOX_ENABLE,obj.DOCUMENT,obj.DOCUMENT_CHECKBOX_ENABLE},{testStatus,blockInfo.TEST_CHECKBOX_ENABLE,docStatus,blockInfo.DOCUMENT_CHECKBOX_ENABLE});
        end

        function status=testStatus(obj,blockName)
            testfile=obj.getBlockFilesByType(blockName,obj.TEST_SCRIPT);
            if(~isempty(testfile))
                status=obj.getBlockMetaData(blockName,obj.TEST);
                if(isequal(status,obj.WARNING))
                    status=obj.NOTRUN;
                end
            else
                status=obj.WARNING;
            end

        end

        function status=documentStatus(obj,blockName)
            blockType=obj.getBlockMetaData(blockName,'BlockType');
            if isequal(blockType,'MATLABSystem')
                status=obj.PASS;
                return;
            end
            docfile=obj.getBlockFilesByType(blockName,obj.DOC_FILE);
            if exist(docfile,'file')
                status=obj.getBlockMetaData(blockName,obj.DOCUMENT);
                if(isequal(status,obj.WARNING))
                    status=obj.PASS;
                end
            else
                status=obj.WARNING;
            end
        end

        function openMaskEditor(obj,blk)
            h=get_param(blk,'type');
            if(strcmpi(h,'block'))
                selected=get_param(blk,'Selected');
                set_param(blk,'Selected','on');
                parent=get_param(blk,'Parent');
                parentH=get_param(parent,'Handle');

                slInternal('createOrEditMask',parentH);

                set_param(blk,'Selected',selected);
            end
        end

        function openIconEditor(obj,blk)
            aDlgStruct=Simulink.Mask.IconImageCreatorDialog(blk);
            DAStudio.Dialog(aDlgStruct);
        end



        function[modelFile,matFile,errorstatus,me,mdlName]=createTestHarnessModel(obj,srcBlock,targetDir)
            modelFile='';
            matFile='';
            errorstatus=0;
            me='';
            [~,mdlName,~]=fileparts(tempname);
            mdlH=new_system(mdlName);
            load_system(mdlH);
            name=get_param(srcBlock,'Name');
            blkName=[mdlName,'/',name];
            add_block(srcBlock,blkName);
            states.a=warning('off','Simulink:Engine:OutputNotConnected');
            states.b=warning('off','Simulink:Engine:InputNotConnected');
            states.c=warning('off','Simulink:Harness:ExportDeleteHarnessFromSystemModel');
            states.d=warning('off','Simulink:Engine:MdlFileShadowing');
            finishup=onCleanup(@()obj.exitCleanupFun(mdlH,mdlName,states));
            try
                name=obj.processName(name);
                sfunTestMdlName=['unittest_',name];



                if bdIsLoaded(sfunTestMdlName)
                    errorstatus=1;
                    me=MException('Simulink:BlockSetDesigner:CreateTestHarness',DAStudio.message('Simulink:SFunctions:BlockSetSDKTestHarnessIsOpen',sfunTestMdlName));
                    return
                end
                matFile=['harness_',name,'_HarnessInputs.mat'];
                if~isempty(which(matFile))
                    delete(which(matFile));
                end
                Simulink.harness.internal.create(blkName,false,false,'Source','Signal Editor','Name',['harness_',name]);
                Simulink.harness.internal.export(blkName,['harness_',name],false,'Name',sfunTestMdlName);
                if~isempty(targetDir)
                    if~isequal(pwd,fullfile(obj.ProjectRoot,targetDir))
                        movefile([sfunTestMdlName,'.slx'],fullfile(obj.ProjectRoot,targetDir),'f');
                        modelFile=fullfile(targetDir,[sfunTestMdlName,'.slx']);
                        if exist(matFile,'file')==2
                            movefile(matFile,fullfile(obj.ProjectRoot,targetDir),'f');
                            matFile=fullfile(targetDir,matFile);
                        else


                            matFile='';
                        end
                    end
                end
            catch me
                errorstatus=1;
            end
        end
        function exitCleanupFun(obj,mdlH,mdlName,states)
            save_system(mdlH);
            close_system(mdlH,0);
            delete([mdlName,'.slx']);
            warning(states.a.state,'Simulink:Engine:OutputNotConnected');
            warning(states.b.state,'Simulink:Engine:InputNotConnected');
            warning(states.c.state,'Simulink:Harness:ExportDeleteHarnessFromSystemModel');
            warning(states.d.state,'Simulink:Engine:MdlFileShadowing');
        end

        function addBlockFile(obj,block,fileType,filepath)

            obj.Project.addFile(fullfile(obj.ProjectRoot,filepath));
            obj.setFileType(filepath,fileType,block);
        end

        function testScriptPath=createTestScript(obj,blockName)
            filename=['test_',blockName,'.m'];
            testFolder=fullfile(blockName,'unittest');
            if~exist(testFolder,'dir')
                testFolder='';
            end
            testScriptPath=fullfile(testFolder,filename);
            fid=fopen(fullfile(obj.Project.RootFolder,testScriptPath),'w');
            fwrite(fid,['classdef test_',blockName,'< matlab.unittest.TestCase',newline]);
            fwrite(fid,['    methods (Test)',newline]);
            fwrite(fid,['        function testSimulation(testCase)',newline]);
            fwrite(fid,['            %model = ''unittest_',blockName,''';',newline]);
            fwrite(fid,['            testCase.assumeFail(''Empty testpoint'');',newline]);
            fwrite(fid,['        end',newline]);
            fwrite(fid,['        function testCodeGen(testCase)',newline]);
            fwrite(fid,['            %%model = ''unittest_',blockName,''';',newline]);
            fwrite(fid,['            testCase.assumeFail(''Empty testpoint'');',newline]);
            fwrite(fid,['        end',newline]);
            fwrite(fid,['        function testDataTypes(testCase)',newline]);
            fwrite(fid,['            %%model = ''unittest_',blockName,''';',newline]);
            fwrite(fid,['            testCase.assumeFail(''Empty testpoint'');',newline]);
            fwrite(fid,['        end',newline]);
            fwrite(fid,['    end',newline]);
            fwrite(fid,['end',newline]);
            fclose(fid);

        end

        function result=createDocBasedOnMask(obj,blockId)
            result.DOCUMENT=obj.WARNING;
            result.DOC_SCRIPT='';
            result.DOC_FILE='';
            result.DOCUMENT_TIMESTAMP='';
            result.DOCUMENT_CHECKBOX_ENABLE='false';
            result.DOCUMENT_CHECKBOX='false';

            blockLibrary=obj.getBlockFilesByType(blockId,obj.BLOCK_LIBRARY);
            if~isempty(blockLibrary)&&exist(blockLibrary,'file')
                blockName=obj.getBlockMetaData(blockId,'BlockName');
                blockName=obj.processName(blockName);
                if~exist(obj.abPath(blockName),'dir')
                    msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKNoBlockFolder',blockName,blockName),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                    obj.setBlockOpStatus(blockId,obj.DOCUMENT,obj.WARNING);
                    return;
                end
                docFolder=obj.abPath(fullfile(blockName,'doc'));
                if~exist(docFolder,'dir')
                    mkdir(docFolder);
                    obj.Project.addFolderIncludingChildFiles(docFolder);
                    obj.Project.addPath(docFolder);
                end

                finishup='';
                [~,blockLibrary,~]=fileparts(blockLibrary);
                if~bdIsLoaded(blockLibrary)
                    load_system(blockLibrary);
                    finishup=onCleanup(@()close_system(blockLibrary,0));
                end
                blockPath=obj.getBlockMetaData(blockId,'BlockPath');
                handle=getSimulinkBlockHandle(blockPath);
                if handle~=-1
                    maskObj=Simulink.Mask.get(blockPath);
                    if isempty(maskObj)
                        docScript=obj.createDocScript(docFolder,blockName);
                    else
                        set_param(blockLibrary,'Lock','off');
                        docScript=obj.createDocScript(docFolder,blockName,blockPath,maskObj.Type,maskObj.Description);
                        if isempty(maskObj.Help)
                            maskObj.Help=['web(which(''help_',blockName,'.html''), ''-helpbrowser'')'];
                        end
                        save_system(blockLibrary);
                    end
                    docScriptLive=fullfile(obj.normPath(docFolder),['help_',blockName,'.mlx']);
                    matlab.internal.liveeditor.openAndSave(docScript,obj.abPath(docScriptLive));
                    delete(docScript);
                    edit(obj.abPath(docScriptLive));
                    htmlFile=fullfile(obj.normPath(docFolder),['help_',blockName,'.html']);
                    matlab.internal.liveeditor.openAndConvert(obj.abPath(docScriptLive),obj.abPath(htmlFile));
                    obj.addBlockFile(blockId,obj.DOC_SCRIPT,docScriptLive);
                    obj.addBlockFile(blockId,obj.DOC_FILE,htmlFile);
                    obj.setBlockOpStatus(blockId,{obj.DOCUMENT,obj.DOC_SCRIPT,obj.DOCUMENT_CHECKBOX_ENABLE,obj.DOC_FILE,obj.DOCUMENT_TIMESTAMP},...
                    {obj.PASS,docScriptLive,'true',htmlFile,datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'))});
                    result.DOCUMENT=obj.PASS;
                    result.DOC_SCRIPT=docScriptLive;
                    result.DOC_FILE=htmlFile;
                    result.DOCUMENT_TIMESTAMP=datestr(datetime(clock,'InputFormat','yyyyMMddHHmm'));
                    result.DOCUMENT_CHECKBOX_ENABLE='true';
                    result.DOCUMENT_CHECKBOX='true';
                end
            else
                h=msgbox(DAStudio.message('Simulink:SFunctions:BlockSetSDKFileCannotFound',blockLibrary),DAStudio.message('Simulink:SFunctions:ComplianceCheckWarning'),'warn');
                h.Tag='Simulink_BlocksetDesigner_Alert';
            end

        end


        function removeBlockFromLinkedLibraries(obj,blockPath,impactedFiles)

            for j=1:numel(impactedFiles)
                file=impactedFiles{j};
                [~,library,ext]=fileparts(file);
                if isequal(ext,'.slx')||isequal(ext,'.mdl')
                    cleanup='';
                    if~bdIsLoaded(library)
                        load_system(library);
                        cleanup=onCleanup(@()close_system(library,0));
                    end
                    if bdIsLibrary(library)
                        set_param(library,'Lock','off');
                        emptyloc='';

                        libdata=libinfo(library);
                        for i=1:numel(libdata)
                            if strcmp(libdata(i).ReferenceBlock,blockPath)
                                emptyloc=get_param(libdata(i).Block,'Position');
                                delete_block(libdata(i).Block);
                                break;
                            end
                        end



                        allblocks=find_system(library,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
                        numberOfBlocks=numel(allblocks);

                        column=mod(numberOfBlocks-1,3);
                        row=(numberOfBlocks-1-column)/3;
                        position=[150*(column+1),120*(row+1),100+150*(column+1),70+120*(row+1)];

                        for i=2:numberOfBlocks
                            temp=get_param(allblocks{i},'Position');
                            if isequal(temp,position)
                                set_param(allblocks{i},'Position',emptyloc);
                                break;
                            end
                        end

                        set_param(library,'Lock','on');
                        save_system(library);

                    end
                end
            end
        end

        function docScriptPath=createDocScript(obj,loc,blockName,varargin)
            flag=0;
            if nargin>3
                flag=1;
            end
            docScriptPath=fullfile(loc,['help_',blockName,'.m']);
            fid=fopen(docScriptPath,'w');
            if~flag
                fwrite(fid,['%% Template MATLAB script for generating html help doc for the block.',newline]);
                fwrite(fid,['% *Put ''web(which(''help_',blockName,'.html''), ''-helpbrowser'') in the HELP section within mask/Documentation to link the generated doc in block mask.*',newline]);
            else
                block=varargin{1};
                type=varargin{2};
                description=varargin{3};
                fwrite(fid,['%% Help doc for block ',block,newline]);
                fwrite(fid,['%% Type:',newline]);
                fwrite(fid,['% ',type,newline]);
                fwrite(fid,['%% Description:',newline]);
                fwrite(fid,['% ',description,newline]);
            end
            fclose(fid);
        end

        function result=parseUIInput(obj,text,varargin)
            result='';
            text=strtrim(text);
            files=strsplit(text,newline);
            if(~isempty(varargin)&&isequal(varargin{1},'all'))
                result=files;
            else
                if(~isempty(files))
                    result=files{1};
                end
            end
        end

        function updateStringInMLX(obj,mlxfilepath,oldstring,newstring)
            mlxfilepath=obj.abPath(mlxfilepath);
            [~,tempstr,~]=fileparts(tempname);
            tempMFile=[tempstr,'.m'];
            matlab.internal.liveeditor.openAndConvert(mlxfilepath,obj.abPath(tempMFile));
            obj.updateBlockNameInFile(tempMFile,oldstring,newstring);
            matlab.internal.livecode.FileModel.convertFileToLiveCode(tempMFile,mlxfilepath);
            if exist(tempMFile,'file')
                delete(tempMFile);
            end
        end
    end
end

