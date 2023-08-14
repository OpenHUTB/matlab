function cp_ir=runthroughba(model,chip,constraint,projFolder,codeFolder,guidanceFile,cpAnnotationFile)





    cmd=qoroptimizations.makehdlcmd(model,chip,codeFolder,constraint,'',guidanceFile,cpAnnotationFile,'on','off','on','off');

    eval(cmd);

    [hD,toolID]=qoroptimizations.setupDI(model,projFolder);
    hD.run('CreateProject');
    hD.run('PostMapTiming');

    timingFile=getPostMapTimingReportPath(hD);
    hdlannotatepath('model',model,'1',timingFile,'targetPlatform',toolID,'showdelays','off','skipannotation','on');
    cp_ir=hdlannotatepath_kernel('printAbstractCP');

end



