function writeSelfContentsForSaveVars(obj,vs)


    vs.writeProperty('DataType',obj.DataType);
    vs.writeProperty('Min',obj.Min);
    vs.writeProperty('Max',obj.Max);
    vs.writeProperty('Unit',obj.Unit);
    vs.writeProperty('FieldName',obj.FieldName);
    vs.writeProperty('Description',obj.Description);
end
