function writeContentsForSaveVars(obj,vs)



    vs.writeProperty('Description',obj.Description);
    vs.writeProperty('DataScope',obj.DataScope);
    vs.writeProperty('HeaderFile',obj.HeaderFile);
    vs.writeProperty('DataTypeMode',obj.DataTypeMode);
    vs.writeProperty('SignednessBool',obj.SignednessBool);
    vs.writeProperty('WordLength',obj.WordLength);
    vs.writeProperty('FixedExponent',obj.FixedExponent);
    vs.writeProperty('SlopeAdjustmentFactor',obj.SlopeAdjustmentFactor);
    vs.writeProperty('Bias',obj.Bias);
    vs.writeProperty('DataTypeOverride',obj.DataTypeOverride);
    vs.writeProperty('IsAlias',obj.IsAlias);



    if slfeature('SLDataDictionarySetUserData')>0&&...
        ~isempty(obj.TargetUserData)
        vs.writeProperty('TargetUserData',obj.TargetUserData);
    end
end
