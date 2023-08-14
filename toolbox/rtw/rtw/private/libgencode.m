function libgencode(bd,lDefaultCompInfo)











    load_system(bd);


    contextBasedComponentCG=...
    coder.internal.libcodegen.ContextBasedComponentCodeGenerator(bd);


    contextBasedComponentCG.build()



    ssComponents=contextBasedComponentCG.getComponents();

    anyNewCodeGenerated=false;

    folderManager=contextBasedComponentCG.getFolderManager();
    for i=1:length(ssComponents)

        thisComponent=ssComponents{i};
        CGContextList=contextBasedComponentCG.getComponentCodeContexts(thisComponent);

        for j=1:length(CGContextList)
            cgContext=CGContextList(j).name;

            cgCtxBuilder=coder.internal.libcodegen.CGContextBuilder(...
            cgContext,thisComponent.getComponentPath(),folderManager,bd);

            [cgCtxInfo,folderExists]=constructCGCtxInfo(cgCtxBuilder);


            contextBasedComponentCG.addCGCtxInfo(cgCtxInfo)

            if folderExists&&~cgCtxBuilder.contextNeedsRebuild()
                delete(cgCtxBuilder);
                continue;
            end

            buildSuccessful=cgCtxBuilder.build(lDefaultCompInfo);

            anyNewCodeGenerated=anyNewCodeGenerated||buildSuccessful;
            buildDir=folderManager.CurrentCtxBuildDir;

            currentCodeFolder=cgCtxInfo.LibraryCodeFolder;

            if buildSuccessful
                postBuildTasks(cgCtxBuilder,buildDir,currentCodeFolder,thisComponent.getComponentPath(),folderManager)
            end

            rmdir(buildDir.BuildDirectory,'s');

            delete(cgCtxBuilder);
        end


    end

    if~anyNewCodeGenerated
        disp(DAStudio.message('Simulink:librarycodegen:NoSubsystemCodeGenerated',bd));
    end
    contextBasedComponentCG.invokeCompile(lDefaultCompInfo);

    delete(contextBasedComponentCG);
end

function copyInterfaceDescFiles(buildDir,cacheFolder,rls,cgContext,folderManager)



    maxIdLength=get_param(cgContext,'MaxIdLength');
    rls=coder.internal.libcodegen.LibraryCodeFolderUtils.block2FolderName(rls,maxIdLength);
    destDir=fullfile(cacheFolder,folderManager.getSCMVersion(),rls,cgContext);
    if~isfolder(destDir)
        mkdir(destDir);
    end

    codeDesc=fullfile(buildDir.BuildDirectory,'codedescriptor.dmr');
    copyfile(codeDesc,destDir);

    binfoMATFile=coderprivate.getBinfoMATFileAndCodeName(buildDir.BuildDirectory);
    [tmwinternalFolder,binfoName,binfoExt]=fileparts(binfoMATFile);
    copyfile(binfoMATFile,destDir);
    updateRelativePathToAnchor(binfoMATFile,destDir,[binfoName,binfoExt]);

    compileInfo=fullfile(tmwinternalFolder,'CompileInfo.xml');
    copyfile(compileInfo,destDir);
end

function updateRelativePathToAnchor(binfoMATFile,destDir,binfoFileName)




    struct=load(binfoMATFile,'infoStruct');
    infoStruct=struct.infoStruct;

    infoStruct.relativePathToAnchor=fullfile('..','..','..');

    save(fullfile(destDir,binfoFileName),'infoStruct','-append');
end

function[cgCtxInfo,folderExists]=constructCGCtxInfo(cgCtxBuilder)

    cgContext=cgCtxBuilder.getCgCtx();
    stf=get_param(cgContext,'SystemTargetFile');


    ctxConfigSet=cgCtxBuilder.getCtxConfigSet();
    hardware=get_param(ctxConfigSet,'TargetHWDeviceType');
    bd=cgCtxBuilder.getParentLibrary();
    fc=Simulink.filegen.internal.FolderConfiguration.forSpecifiedSTFAndHardware(bd,stf,hardware);
    folderSet=fc.getFolderSetFor('RTW');



    currentCodeFolder=fullfile(pwd,folderSet.ModelCode);

    folderExists=cgCtxBuilder.getFolderManager().makeLibraryCodeFolder(currentCodeFolder);

    thisComponent=cgCtxBuilder.getParentRLSBlock();
    cgCtxInfo=coder.internal.libcodegen.CGContextInfo(cgContext,thisComponent,...
    bd,currentCodeFolder);
end

function postBuildTasks(cgCtxBuilder,buildDir,currentCodeFolder,thisComponent,folderManager)
    sourceExt=cgCtxBuilder.getSourceFileExt();
    cgContext=cgCtxBuilder.getCgCtx();
    sharedCodeUpdate(buildDir.SharedUtilsTgtDir,currentCodeFolder,...
    'interactive',false,...
    'CopyForLibCodeGen',true,...
    'sourceExt',sourceExt);
    copyInterfaceDescFiles(buildDir,currentCodeFolder,...
    get_param(thisComponent,'Name'),cgContext,folderManager);
end





