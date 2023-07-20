function writeContentsForSaveVars(obj,vs)





    vs.writeProperty('Name',obj.Name);

    vs.writeProperty('Complexity',obj.Complexity);
    vs.writeProperty('Dimensions',obj.Dimensions);
    vs.writeProperty('DataType',obj.DataType);
    vs.writeProperty('Min',obj.Min);
    vs.writeProperty('Max',obj.Max);
    vs.writeProperty('DimensionsMode',obj.DimensionsMode);
    vs.writeProperty('SamplingMode',obj.SamplingMode);
    vs.writeProperty('DocUnits',obj.DocUnits);

    if(sl('busUtils','BusElementSampleTime')==0)
        vs.writeProperty('SampleTime',obj.SampleTime);
    end

    vs.writeProperty('Description',obj.Description);



    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(obj.TargetUserData)
        vs.writeProperty('TargetUserData',obj.TargetUserData);
    end
end



