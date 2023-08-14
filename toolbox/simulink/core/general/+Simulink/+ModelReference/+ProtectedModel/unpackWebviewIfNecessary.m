function dstDir=unpackWebviewIfNecessary(filename)




    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;

    [opts,fullName]=getOptions(filename,'runConsistencyChecksNoPlatform');
    protectedModel=opts.modelName;
    if strcmp(opts.modes,'ViewOnly')
        setCurrentTarget(protectedModel,'viewonly','runConsistencyChecksNoPlatform');
    else
        setCurrentTarget(protectedModel,'sim','runConsistencyChecksNoPlatform');
    end

    buildDirs=RTW.getBuildDir(opts.modelName);
    dstDir='';
    if opts.webview
        if slsvTestingHook('ProtectedModelCleanupTest')
            rootSimDir=getSimBuildDir();
            dstDir=fullfile(rootSimDir,buildDirs.ModelRefRelativeSimDir);
        else

            dstDir=ExtractWebview.getExtractionDir(protectedModel);
        end

        getPasswordFromDialog(protectedModel,'','VIEW',true,opts);

        try

            runCallback(fullName,'PreAccess','VIEW');
            year=RelationshipProtectedModelWebview.getRelationshipYear();
            writeRelationship(fullName,dstDir,'webview',year);
        catch me
            if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
                myException=getWrongPasswordDetailedException(opts.modelName,'VIEW');
                myException.throw;
            else
                rethrow(me);
            end
        end
    end
end

