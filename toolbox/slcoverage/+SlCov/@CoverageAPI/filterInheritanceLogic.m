
function[isFiltered,isJustified,filterRationale]=filterInheritanceLogic(isFiltered,isJustified,...
    isFilteredParent,isJustifiedParent,...
    filterRationale,filterRationaleParent)


    if isFilteredParent
        if~isFiltered
            filterRationale=filterRationaleParent;
        end
        isFiltered=true;
        isJustified=false;
    else
        if isFiltered
            isJustified=false;
        elseif isJustifiedParent
            isJustified=true;
        end
    end

