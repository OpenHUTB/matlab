function property=getPropertyFromQuantityName(quantityName,VariableNames,ObjectiveNames)











    if any(strcmp(quantityName,VariableNames))
        property="Variables";
    elseif any(strcmp(quantityName,ObjectiveNames))
        property="Objective";
    else
        property="Constraints";
    end

end