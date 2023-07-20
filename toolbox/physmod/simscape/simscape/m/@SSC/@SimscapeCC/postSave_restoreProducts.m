function postSave_restoreProducts(mdl)










    persistent getConfigSetCC
    if isempty(getConfigSetCC)
        getConfigSetCC=ssc_private('ssc_get_configset');
    end


    [~,allSimscapeCC]=getConfigSetCC(mdl);

    numCC=numel(allSimscapeCC);
    for j=1:numCC
        if~isObjectLocked(allSimscapeCC(j))
            allSimscapeCC(j).attachAllSubComponents(true);
        end
    end

end

