function writeSelfContentsForSaveVars(obj,vs)
    vs.writeProperty('Name',obj.Name);
    vs.writeProperty('DataScope',obj.DataScope);
    vs.writeProperty('HeaderFileName',obj.HeaderFileName);
end
