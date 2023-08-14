


function result=invokeCommand(inputInfo)
    h='';
    result.command=inputInfo.command;
    result.data='';
    result.header='';
    opCode=inputInfo.opCode;

    switch opCode
    case 0
        h=Simulink.BlocksetDesigner.BlockAuthoring();
    case 1
        h=Simulink.BlocksetDesigner.Blockset();
    case 2
        h=Simulink.BlocksetDesigner.Sublibrary();
    case 3
        h=Simulink.BlocksetDesigner.Block();
    case 4
        h=Simulink.BlocksetDesigner.Sfunction();
    case 5
        h=Simulink.BlocksetDesigner.Subsystem();
    case 6
        h=Simulink.BlocksetDesigner.MATLABSystem();
    otherwise
        h=Simulink.BlocksetDesigner.BlockAuthoring();
    end

    switch inputInfo.command
    case 'add_sublibrary'
        result.data=h.create(inputInfo.sublibraryName,inputInfo.parentId);
        result.header.parentId=inputInfo.parentId;
    case 'init_blockset'
        result.data=h.init();

        result.header.rootFolder=h.ProjectRoot;


        contentUrlPath=connector.addStaticContentOnPath('projs',h.ProjectRoot);
        result.header.urlPath=contentUrlPath;
    case 'add_sfunction'
        result.data=h.create(inputInfo.sfunName,inputInfo.type,inputInfo.parentId);


        result.header.SFunctionType=inputInfo.type;
        result.header.parentId=inputInfo.parentId;
    case 'add_subsystem'
        result.data=h.create(inputInfo.subsysName,inputInfo.parentId);
        result.header.parentId=inputInfo.parentId;
    case 'add_mlsys'
        result.data=h.create(inputInfo.mlsysName,inputInfo.type,inputInfo.parentId);
        result.header.parentId=inputInfo.parentId;
    case 'get_sfunction_examples'
        result.data=Simulink.BlocksetDesigner.internal.getSfunctionExamples();
    case 'add_sfunction_from_example'
        result.data=h.createFromExample(inputInfo.sfunName,inputInfo.example,inputInfo.parentId);
        result.header.parentId=inputInfo.parentId;
    case 'open_block_library'
        result.data=h.editBlockLibrary(inputInfo.id);
    case 'open_library_help'
        h.openLibraryHelp();
    case 'open_code_importer'
        internal.CodeImporter.launchFromBlocksetDesigner(h.ProjectRoot,inputInfo.cCallarLibName,inputInfo.parentId);
    case 'edit_source'
        h.editBlockSource(inputInfo.id);
    case 'edit_mask'
        h.editBlockMask(inputInfo.id);
    case 'edit_icon'
        h.editBlockIcon(inputInfo.id);
    case 'edit_packaged_s_function'




        blkHandle=getSimulinkBlockHandle(['tempSFB__',inputInfo.blcokPath]);
        sfcnbuilder.setup(blkHandle,0,true)
    case 'run_block'
        result.data=runBlock(inputInfo,h);
        result.header.id=inputInfo.id;
    case 'run_all_blocks'
        result.data=runBlock(inputInfo,h);
        result.header.id=inputInfo.id;
        result.header.index=inputInfo.index+1;
    case 'build'
        result.data=h.build(inputInfo.id,inputInfo.isReport);
    case 'open_build_report'
        h.openBuildReport(inputInfo.id);
    case 'create_test_harness'
        result.data=h.createTestHarness(inputInfo.id);
        result.header.id=inputInfo.id;
    case 'run_tests'
        result.data=h.runTests(inputInfo.id);
    case 'open_test_harness'
        h.openTestHarness(inputInfo.id);
    case 'open_test_report'
        h.openTestReport(inputInfo.id);
    case 'open_test_script'
        h.openTestScript(inputInfo.id);
    case 'run_checks'
        result.data=h.runChecks(inputInfo.id);
    case 'open_check_report'
        h.openCheckReport(inputInfo.id);
    case 'create_doc'
        result.data=h.createDoc(inputInfo.id);
        result.header.id=inputInfo.id;
    case 'publish_doc'
        result.data=h.publishDoc(inputInfo.id);
    case 'open_doc'
        h.openDoc(inputInfo.id);
    case 'open_html'
        h.openHtml(inputInfo.id);
    case 'edit_buildrule'
        h.editBuildRule(inputInfo.id);
    case 'sfuncheck'
        h.runSfunctionCheck(inputInfo.id);
    case 'delete_block'
        h.deleteBlock(inputInfo.id);
    case 'rename_block'
        result.data=h.renameBlock(inputInfo.blockInfo,inputInfo.newName);
    case 'block_file_changed'
        result.data=h.blockFileChanged(inputInfo.id,inputInfo.fileType);
    case 'move_block'
        h.moveBlock(inputInfo.id,inputInfo.oldParentLibrary,inputInfo.newParentLibrary);
    case 'delete_sublibrary'
        h.deleteSublibrary(inputInfo.id);
    case 'move_sublibrary'
        h.moveSublibrary(inputInfo.id,inputInfo.oldParentLibrary,inputInfo.newParentLibrary);
    case 'view_blockset'
        h.viewBlockSet();
    case 'view_blockset_inslbrowser'
        h.viewBlockSetInSlBrowser();
    case 'view_sublibrary'
        h.open(inputInfo.LibPath);
    case 'rename_sublibrary'
        result.data=h.renameSublibrary(inputInfo.sublibraryInfo,inputInfo.newName);
    case 'publish_blockset'
        h.publish(inputInfo);
    case 'rename_blockset'
        result.data=h.renameBlockset(inputInfo.sublibraryInfo,inputInfo.newName);
    case 'blockset_doc_script_changed'
        if~isempty(inputInfo.DOC_SCRIPT)
            helpScriptPath=inputInfo.DOC_SCRIPT;
            if isempty(strfind(helpScriptPath,h.ProjectRoot))
                helpScriptPath=fullfile(h.ProjectRoot,helpScriptPath);
            end
            h.generateBlockSetDocHTMLFromScript(helpScriptPath);
        end
    case 'update_root_library'
        if~isempty(inputInfo.LibPath)
            [parentfolder,blocksetlibrary,~]=fileparts(inputInfo.LibPath);
            if~isempty(parentfolder)
                addPath(simulinkproject,parentfolder);
            else
                addPath(simulinkproject,pwd);
            end
            h.setBlockSetMetaData(h.BLOCKSET_LIBRARY,inputInfo.LibPath);
            slblockspath=h.createSlblocksScript(blocksetlibrary);
            if~isempty(slblockspath)
                h.setBlockSetMetaData(h.BLOCKSET_SCRIPT,slblockspath);
            end
            result.data=h.init();

            result.header.rootFolder=h.ProjectRoot;
            contentUrlPath=connector.addStaticContentOnPath('projs',h.ProjectRoot);
            result.header.urlPath=contentUrlPath;
        end
    case 'set_block_info'

        result.data=h.setBlockInfo(inputInfo.blockInfo);
        result.header.id=inputInfo.blockInfo.Id;
    case 'clear'

        Simulink.BlocksetDesigner.BlockAuthoring.setgetMetaDataManager('');
    end

    h.notifyUI(result);
end



function runResults=runBlock(inputInfo,h)
    runResults=[];
    if isempty(inputInfo.runOptions)
        return
    end

    index=cellfun(@(x)~isempty(x),inputInfo.runOptions);
    runOptions=inputInfo.runOptions(index);

    if any(cellfun(@(x)contains(x,'build'),runOptions))&&isa(h,'Simulink.BlocksetDesigner.Sfunction')
        buildResults=h.build(inputInfo.id,false);
        runResults=mergeResults(runResults,buildResults);
    end
    if any(cellfun(@(x)contains(x,'test'),runOptions))
        testResults=h.runTests(inputInfo.id);
        runResults=mergeResults(runResults,testResults);
    end
    if any(cellfun(@(x)contains(x,'document'),runOptions))
        documentResults=h.publishDoc(inputInfo.id);
        runResults=mergeResults(runResults,documentResults);
    end
end


function runResults=mergeResults(runResults,result)
    f=fieldnames(result);
    for i=1:length(f)
        runResults.(f{i})=result.(f{i});
    end
end
