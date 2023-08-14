function out=getEncryptionCategoryForRelationship(fullName,relationship)






    import Simulink.ModelReference.ProtectedModel.*;

    if strcmp(relationship,'webview')
        [opts,~]=getOptions(fullName,'runConsistencyChecksNoPlatform');
    else
        [opts,~]=getOptions(fullName);
    end

    tgtRelName=getCurrentTarget(opts.modelName);

    if strcmp(tgtRelName,relationship)&&~strcmp(tgtRelName,'sim')
        out='RTW';
    else
        [~,out]=getStaticInformationForRelationship(relationship,getCurrentTarget(opts.modelName));
    end
end



