function addQueryRow()

    maskObj=Simulink.Mask.get(gcb);
    tableControl=maskObj.getDialogControl('queryTable');
    temp={maskObj.Parameters.Name};
    paramIdx=find(ismember(temp,'BusTypeMask'));
    selectedBusType=evalin('base',maskObj.Parameters(paramIdx).Value);
    if(isa(selectedBusType,'Simulink.Bus'))
        nBusElements=numel(selectedBusType.Elements);
        for idx=1:nBusElements
            if idx==1
                tempName=selectedBusType.Elements(idx).Name;
            else
                tempName=[tempName,{selectedBusType.Elements(idx).Name}];%#ok<*AGROW>
            end
        end
    end
    tableControl.getColumn(1).Type='popup';
    tableControl.getColumn(1).TypeOptions=tempName';
    tableControl.getColumn(2).Type='popup';
    tableControl.getColumn(2).TypeOptions=[{''},{'-'},{'+'}];
    tableControl.getColumn(3).Type='edit';
    tableControl.getColumn(4).Type='popup';
    tableControl.getColumn(4).TypeOptions=[{'<'},{'>'},{'<='},{'>='},{'=='},{'!='},{'||'},{'&&'}];
    tableControl.getColumn(5).Type='popup';
    tableControl.getColumn(5).TypeOptions=[tempName,{'Dialog'}]';
    tableControl.getColumn(6).Type='edit';

    tempRangeOperators=tableControl.getColumn(2).TypeOptions;
    tempOperators=tableControl.getColumn(4).TypeOptions;
    tempDataSource=[tempName,{'Dialog'}]';

    tableControl.addRow(tempName{1},tempRangeOperators{1},'',tempOperators{1},tempDataSource{end},'');

end

