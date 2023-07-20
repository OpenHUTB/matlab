function emcBuildLLVMTarget(bldParams,shouldkeepBitCode)




    if usejava('swing')
        try


            com.mathworks.toolbox.coder.app.MatlabJavaNotifier.publishGlobally('CODEGEN_BUILD_PHASE_STARTING');
        catch me
            coder.internal.gui.asyncDebugPrint(me);
        end
    end

    bldDirectory=bldParams.project.BldDirectory;
    outDirectory=bldParams.project.OutDirectory;
    baseFileName=bldParams.project.FileName;

    srcCGFileName=fullfile(bldDirectory,[baseFileName,'.cg']);


    srcMexFileName=coder.internal.getSurrogateMexFunctionPath(Debug=bldParams.configInfo.EnableDebugging);

    buildMexFileName=fullfile(outDirectory,[baseFileName,'.',mexext()]);

    dstMexFileName=fullfile(bldDirectory,[baseFileName,'.',mexext()]);
    emcGenerateLLVMMex(srcMexFileName,srcCGFileName,dstMexFileName);


    if~shouldkeepBitCode
        delete(srcCGFileName);
    else
        movefile(srcCGFileName,outDirectory);
    end

    clear(baseFileName);
    if isfile(buildMexFileName)
        delete(buildMexFileName);
    end
    [status,~,messageId]=copyfile(dstMexFileName,buildMexFileName);

    if~status
        error(messageId);
    end
end

