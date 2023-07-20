function writeContentsForSaveVars(obj,vs)




    vs.writeProperty('Description',obj.Description);
    vs.writeProperty('DataScope',obj.DataScope);
    vs.writeProperty('HeaderFile',obj.HeaderFile);
    vs.writeProperty('Alignment',obj.Alignment);
    if sl('busUtils','NDIdxBusUI')
        vs.writeProperty('PreserveElementDimensions',obj.PreserveElementDimensions);
    end


    elements=obj.Elements;
    if~isempty(elements)
        elements=vs.writeToTempVar(elements);
        vs.writeProperty('Elements',elements);
    end



    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(obj.TargetUserData)
        vs.writeProperty('TargetUserData',obj.TargetUserData);
    end
end
