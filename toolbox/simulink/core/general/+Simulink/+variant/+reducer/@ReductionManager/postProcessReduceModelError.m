function postProcessReduceModelError(rMgrObj)






    if isempty(rMgrObj.BDNameRedBDNameMap)
        return;
    end



    if isempty(rMgrObj.Error)
        return;
    end





    red2orig=containers.Map(rMgrObj.BDNameRedBDNameMap.values,...
    rMgrObj.BDNameRedBDNameMap.keys);

    rMgrObj.Error=Simulink.variant.reducer.utils.fixErrorToRemoveSuffix(red2orig,rMgrObj.Error);
end


