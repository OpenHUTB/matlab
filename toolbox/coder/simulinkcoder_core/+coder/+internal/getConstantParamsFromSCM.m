function[paramNames,csVals]=getConstantParamsFromSCM(modelName,scmFileName)



    isOk=~isempty(modelName);
    paramNames={};
    csVals={};
    if isOk

        scm_db=SharedCodeManager.SharedConstantsInterface(scmFileName);
        sharedConstIdentities=scm_db.retrieveAllIdentities('SCM_SHARED_CONSTANTS');

        if length(sharedConstIdentities)<=0
            return
        end


        for idx=1:length(sharedConstIdentities)
            thisConstIdentity=sharedConstIdentities{idx};
            cs=thisConstIdentity;
            csVals{end+1}=[cs.ChecksumElement1,cs.ChecksumElement2...
            ,cs.ChecksumElement3,cs.ChecksumElement4];%#ok
        end


        paramNames=scm_db.getAllConstantsNames;
    end
end


