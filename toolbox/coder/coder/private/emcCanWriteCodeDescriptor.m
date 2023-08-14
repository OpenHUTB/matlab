function p=emcCanWriteCodeDescriptor(bldParams)





    p=true;
    buildDir=emcGetBuildDirectory(bldParams.buildInfo,coder.internal.BuildMode.Normal);
    cdname='codedescriptor.dmr';
    outfile=fullfile(buildDir,cdname);
    if isfile(outfile)




        emcRemoveFile(buildDir,cdname);
        if isfile(outfile)
            p=false;
        end
    end

