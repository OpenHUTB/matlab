function inputGroup=createInputGroup(source)



    filterEdit.Type='spreadsheetfilter';
    filterEdit.Tag='filterEdit_input';
    filterEdit.RowSpan=[1,1];
    filterEdit.ColSpan=[1,3];
    filterEdit.TargetSpreadsheet='inputList';
    filterEdit.PlaceholderText=DAStudio.message('FMUBlock:FMU:SearchVariable');
    filterEdit.Clearable=true;


    inputList.Type='spreadsheet';
    inputList.Columns={DAStudio.message('FMUBlock:FMU:VarName'),...
    DAStudio.message('FMUBlock:FMU:VarVisibility'),...
    DAStudio.message('FMUBlock:FMU:VarStart'),...
    DAStudio.message('FMUBlock:FMU:VarUnit'),...
    DAStudio.message('FMUBlock:FMU:VarBusObjectName')};
    inputList.RowSpan=[2,2];
    inputList.ColSpan=[1,3];
    inputList.Tag='inputList';
    inputList.DialogRefresh=false;
    inputList.Hierarchical=true;
    inputList.Source=source.DialogData.inputListSource;
    inputList.ValueChangedCallback=@(widgetTag,rowObj,propName,propValue,dlgH)onValueChange(widgetTag,rowObj,propName,propValue,dlgH);


    resetButton.Name=DAStudio.message('FMUBlock:FMU:RestoreInput');
    resetButton.Type='pushbutton';
    resetButton.Enabled=1;
    resetButton.RowSpan=[3,3];
    resetButton.ColSpan=[1,1];
    resetButton.Tag='reset_input';
    resetButton.MatlabMethod='fmuResetCallback';
    resetButton.MatlabArgs={source,'%dialog','inputList'};
    resetButton.ArgDataTypes={'handle','handle','string'};


    inputGroup.Type='panel';
    inputGroup.Items={filterEdit,inputList,resetButton};
    inputGroup.LayoutGrid=[3,3];
    inputGroup.RowSpan=[2,2];
    inputGroup.ColSpan=[1,1];

end

function onValueChange(widgetTag,rowObj,propName,propValue,dlgH)


    ss=dlgH.getWidgetInterface('inputList');
    if~isempty(ss)
        ss.update(true);
    end
end
