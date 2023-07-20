function success=launchCustomHelp(instance)


    success=false;
    CSHParameters=[];


    if ischar(instance)
        am=Advisor.Manager.getInstance;

        am.updateCacheIfNeeded;

        if(am.slCustomizationDataStructure.CheckIDMap.isKey(instance))
            key=am.slCustomizationDataStructure.CheckIDMap(instance);
            instance=am.slCustomizationDataStructure.checkCellArray{key};
        end
    end

    if isa(instance,'ModelAdvisor.Node')||isa(instance,'ModelAdvisor.Check')
        CSHParameters=instance.CSHParameters;
    end


    if~isempty(CSHParameters)

        if isfield(CSHParameters,'webpage')&&ischar(CSHParameters.webpage)
            success=~logical(web(CSHParameters.webpage));
        elseif isfield(CSHParameters,'file')&&ischar(CSHParameters.file)
            open(CSHParameters.file);
            success=true;
        end


    end

end

