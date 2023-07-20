function writeContentsForSaveVars(obj,vs)




    vs.writeProperty('Description',obj.Description);
    vs.writeProperty('DataScope',obj.DataScope);
    vs.writeProperty('HeaderFile',obj.HeaderFile);
    vs.writeProperty('BaseType',obj.BaseType);



    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(obj.TargetUserData)
        vs.writeProperty('TargetUserData',obj.TargetUserData);
    end
end
