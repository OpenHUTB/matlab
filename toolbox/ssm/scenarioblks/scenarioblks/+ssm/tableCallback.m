function tableCallback

    signalName='';
    portName='';
    maskObj=Simulink.Mask.get(gcb);
    tableControl=maskObj.getDialogControl('queryTable');
    temp={maskObj.Parameters.Name};
    paramIdx=find(ismember(temp,'BusTypeMask'));
    selectedBusType=evalin('base',maskObj.Parameters(paramIdx).Value);
    if(isa(selectedBusType,'Simulink.Bus'))
        nBusElements=numel(selectedBusType.Elements);
        for idx=1:nBusElements
            if idx==1
                signalName=[selectedBusType.Elements(idx).Name];
                portName=[':',selectedBusType.Elements(idx).Name,':'];
            else
                signalName=[signalName,{selectedBusType.Elements(idx).Name}];%#ok<*AGROW>
                portName=[portName,{[':',selectedBusType.Elements(idx).Name,':']}];%#ok<*AGROW>
            end
        end
    end
    tableControl.getColumn(1).Type='popup';
    tableControl.getColumn(1).TypeOptions=signalName';
    tableControl.getColumn(2).Type='popup';
    tableControl.getColumn(2).TypeOptions=[{' '},{'-'},{'+'}];
    tableControl.getColumn(3).Type='edit';
    tableControl.getColumn(4).Type='popup';
    tableControl.getColumn(4).TypeOptions=[{'<'},{'>'},{'<='},{'>='},{'=='},{'!='},{'||'},{'&&'}];
    tableControl.getColumn(5).Type='popup';
    tableControl.getColumn(5).TypeOptions=[portName,{'Dialog'}]';
    tableControl.getColumn(6).Type='edit';
    test=tableControl.getChangedCells();
    if~isempty(tableControl.getChangedCells)

    end
end

