function unitDisplayString=getUnitDisplayName(valueContElement,isStructure)




    unitDisplayString=strings(1);


    if isStructure
        return;
    end


    unitDisplayElement=valueContElement.UNIT_DISPLAY_NAME;


    if~isempty(unitDisplayElement)
        unitDisplayString=string(valueContElement.UNIT_DISPLAY_NAME.elementValue);
    end

end

