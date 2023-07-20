function outputGroup=createOutputGroup(source)



    filterEdit.Type='spreadsheetfilter';
    filterEdit.Tag='filterEdit_input';
    filterEdit.RowSpan=[1,1];
    filterEdit.ColSpan=[1,3];
    filterEdit.TargetSpreadsheet='outputList';
    filterEdit.PlaceholderText=DAStudio.message('FMUBlock:FMU:SearchVariable');
    filterEdit.Clearable=true;


    outputList.Type='spreadsheet';
    outputList.Columns={DAStudio.message('FMUBlock:FMU:VarName'),DAStudio.message('FMUBlock:FMU:VarVisibility'),DAStudio.message('FMUBlock:FMU:VarStart'),DAStudio.message('FMUBlock:FMU:VarUnit'),DAStudio.message('FMUBlock:FMU:VarBusObjectName')};
    outputList.RowSpan=[2,2];
    outputList.ColSpan=[1,3];
    outputList.Tag='outputList';
    outputList.DialogRefresh=false;
    outputList.Hierarchical=true;
    outputList.Source=source.DialogData.outputListSource;



    resetButton.Name=DAStudio.message('FMUBlock:FMU:RestoreOutput');
    resetButton.Type='pushbutton';
    resetButton.Enabled=1;
    resetButton.RowSpan=[3,3];
    resetButton.ColSpan=[1,1];
    resetButton.Tag='reset_output';
    resetButton.MatlabMethod='fmuResetCallback';
    resetButton.MatlabArgs={source,'%dialog','outputList'};
    resetButton.ArgDataTypes={'handle','handle','string'};


    outputGroup.Type='panel';
    outputGroup.Items={filterEdit,outputList,resetButton};
    outputGroup.LayoutGrid=[3,3];
    outputGroup.RowSpan=[2,2];
    outputGroup.ColSpan=[1,1];

end
