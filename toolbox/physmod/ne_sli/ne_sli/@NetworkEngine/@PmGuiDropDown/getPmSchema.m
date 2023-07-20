function[retStatus,pmSchema]=getPmSchema(hThis,~)














    Parameters=struct(...
    'ValueBlkParam',{hThis.ValueBlkParam},...
    'Label',{hThis.Label},...
    'LabelAttrb',{hThis.LabelAttrb},...
    'Choices',{hThis.Choices},...
    'ChoiceVals',{hThis.ChoiceVals},...
    'MapVals',{hThis.MapVals});
    pmSchema=struct('ClassName',{'NetworkEngine.PmGuiDropDown'},...
    'Version',{'1.0.0'},...
    'Parameters',{Parameters});
    retStatus=true;
end