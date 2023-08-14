

function unpackProtectedModelSimTargetArtifactsIfNecessary(protectedModelFile,topMdl)



    import Simulink.ModelReference.ProtectedModel.*;
    import Simulink.ModelReference.common.*;
    [opts,fullName]=getOptions(protectedModelFile);
    if supportsAccel(opts)
        yearAccel=RelationshipAccel.getRelationshipYear();
        yearAccelSharedUtils=RelationshipAccelSharedUtils.getRelationshipYear();
        try
            isSimForRTWBuild=false;
            unpackProtectedModelSimCommon(fullName,opts,topMdl,...
            'sim',yearAccel,'simsharedutils',yearAccelSharedUtils,isSimForRTWBuild);
        catch me

            FileDeleter.cleanup(topMdl);
            if strcmp(me.identifier,'Simulink:protectedModel:ProtectedModelWrongPassword')
                myException=getWrongPasswordDetailedException(opts.modelName,'SIM');
                myException.throw;
            else
                rethrow(me);
            end
        end
    else

        DAStudio.error('Simulink:protectedModel:ProtectedModelUnsupportedModeAccel',...
        opts.modelName);
    end
end


