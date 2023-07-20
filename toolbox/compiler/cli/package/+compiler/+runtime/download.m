function download()



    narginchk(0,0);

    if matlab.internal.environment.context.isMATLABOnline()
        error(message('Compiler:runtime:matlabOnline','compiler.runtime.download'));
    end



    out=compiler.internal.runtime.utils.getExistingMCRInstallerWithValidation;
    if~isempty(out)
        disp(getString(message('Compiler:runtime:installerAlreadyExist',out)));
        return;
    end


    cacheDir=mcrcachedir;


    if endsWith(cacheDir,filesep)
        cacheDir(end)=[];
    end
    cacheRoot=fileparts(cacheDir);
    targetDir=fullfile(cacheRoot,...
    sprintf('MCRInstaller%s',compiler.internal.runtime.utils.expectedMcrVersion));
    if exist(targetDir,'dir')==0
        [succeeded,msg]=mkdir(targetDir);
        if~succeeded
            error(msg);
        end
    end
    targetFile=fullfile(targetDir,...
    compiler.internal.runtime.utils.augmentedMCRInstallerFileName);
    downloadURL=compiler.internal.runtime.utils.getMCRInstallerDownloadURL;
    try
        disp(getString(message('Compiler:runtime:downloading')));
        out=websave(targetFile,downloadURL);
        compiler.internal.runtime.utils.setInstallerLocation(out);
        disp(getString(message('Compiler:runtime:installerDownloaded',out)));
    catch e
        knownErrors={'MATLAB:webservices:UnknownHost'...
        ,'MATLAB:webservices:ConnectionRefused'...
        ,'MATLAB:webservices:ConnectionFailed'};
        if(any(strcmp(e.identifier,knownErrors)))
            error(message('Compiler:runtime:couldNotDownload',downloadURL));
        else
            throw(e);
        end
    end
