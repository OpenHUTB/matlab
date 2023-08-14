function jTypes=getJComparisonTypesViaMATLAB(left,right)




    options=struct("Type","");
    left=comparisons.internal.makeFileSource(left);
    right=comparisons.internal.makeFileSource(right);
    args={left,right,options};

    import comparisons.internal.getProvidersFor
    availableProviders=getProvidersFor("DiffGUIProviders",args);

    jTypes=java.util.ArrayList();

    if~isempty(availableProviders)
        priorities=arrayfun(@(x)x.getPriority(left,right,options),availableProviders);
        [~,inds]=sort(priorities,"descend");

        arrayfun(@(provider)addJComparisonType(provider,jTypes),availableProviders(inds));
    end

end

function addJComparisonType(provider,jTypes)


    jType=comparisons.internal.dispatcherutil.getJComparisonType(provider.getType());

    if isempty(jType)



        jType=com.mathworks.comparisons.gui.selection.MATLABOnlyComparisonType(...
        provider.getType(),...
        provider.getDisplayType()...
        );
    end

    jTypes.add(jType);
end
