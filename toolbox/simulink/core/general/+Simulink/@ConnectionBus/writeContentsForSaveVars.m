function writeContentsForSaveVars(obj,vs)




    vs.writeProperty('Description',obj.Description);
    elements=obj.Elements;
    if~isempty(elements)
        elements=vs.writeToTempVar(elements);
        vs.writeProperty('Elements',elements);
    end
end
