function upgrade(hObj)
    if hObj.versionCompare("20.0.0")<0
        hObj.IncludeModelTypesInModelClass='off';
        if strcmp(hObj.GenerateExternalIOAccessMethods,'None')
            hObj.ExternalIOMemberVisibility='public';
        else
            hObj.ExternalIOMemberVisibility='protected';
        end
    end
end
