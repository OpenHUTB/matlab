function removeExclusion(modelName,type,id)






























    try
        if strcmp(type,'object')&&isa(id,'advisor.filter.AdvisorFilterSpecification')
            type=id.type;
            id=id.id;
        else
            type=slcheck.getFilterTypeEnum(type);
        end

        manager=slcheck.getAdvisorFilterManager(modelName);
        status=manager.removeFilterSpecification(type,slcheck.getsid(id));
        if~status
            DAStudio.warning('slcheck:filtercatalog:UnableToRemoveExclusion');
        end
        slcheck.refreshExclusionUI(modelName);
    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_remove'),ex.message]);
    end

end

