

function unpackProtectedModelSimTargetArtifactsForCodegenIfNecessary(protectedModelFile,topMdl)



    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;

    [opts,fullName]=getOptions(protectedModelFile);

    if~supportsCodeGen(opts)

        DAStudio.error('Simulink:protectedModel:ProtectedModelUnsupportedModeRTW',...
        opts.modelName);
    end

    stfFile=strtrim(coder.internal.getCachedAccelOriginalSTF(topMdl,false));
    [~,target,~]=fileparts(stfFile);
    setCurrentTarget(opts.modelName,target,'skipModifiableCheck');

    simCGYear=RelationshipAccelForCodegen.getRelationshipYear();
    simsharedutilsCGYear=RelationshipAccelSharedUtilsForCodegen.getRelationshipYear();
    try
        currentTarget=getCurrentTarget(opts.modelName);
        simCGName=constructTargetRelationshipName('simCG',currentTarget);
        simUtilsCGName=constructTargetRelationshipName('simsharedutilsCG',currentTarget);
        isSimForRTWBuild=true;
        unpackProtectedModelSimCommon(fullName,opts,topMdl,...
        simCGName,simCGYear,simUtilsCGName,simsharedutilsCGYear,isSimForRTWBuild);
    catch me
        FileDeleter.cleanup(topMdl);
        if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
            myException=getWrongPasswordDetailedException(opts.modelName,'RTW');
            myException.throw;
        else
            rethrow(me);
        end
    end
end


