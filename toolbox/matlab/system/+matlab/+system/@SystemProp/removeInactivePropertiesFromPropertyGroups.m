function matlabGroups=removeInactivePropertiesFromPropertyGroups(obj,matlabGroups)




    for n=1:numel(matlabGroups)
        propertyList=matlabGroups(n).PropertyList;

        if isstruct(propertyList)
            propertyList=filterStructGroup(obj,propertyList);
        else
            propertyList=filterCellStringGroup(obj,propertyList);
        end

        matlabGroups(n).PropertyList=propertyList;
    end
end

function filteredList=filterStructGroup(obj,propertyList)
    propNames=fieldnames(propertyList);
    numProperties=numel(propNames);
    filteredList=propertyList;
    for m=1:numProperties
        if isInactiveProperty(obj,propNames{m})
            filteredList=rmfield(filteredList,propNames{m});
        end
    end
end

function filteredList=filterCellStringGroup(obj,propertyList)
    numProperties=numel(propertyList);
    keepIdx=false(1,numProperties);
    for m=1:numProperties
        keepIdx(m)=~isInactiveProperty(obj,propertyList{m});
    end
    filteredList=propertyList(keepIdx);
end
