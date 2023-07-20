function panelWithButton=getRangeButton(widgetStruct)





    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    rangeButton.Type='pushbutton';
    rangeButton.ToolTip=getString(message('sl_iofile:excelfile:Range_ToolTip'));
    rangeButton.FilePath=slfullfile(slfileparts(mfilename('fullpath')),'images','Range_16.png');
    rangeButton.Tag='RangeButton:';
    rangeButton.RowSpan=[1,1];
    rangeButton.ColSpan=[2,2];
    rangeButton.MatlabMethod='iofile.FromSpreadsheetBlockUI.cb_LaunchRangeSelector';
    rangeButton.MatlabArgs={'%dialog',true};


    panelWithButton.Type='panel';
    panelWithButton.Name='';
    panelWithButton.LayoutGrid=[1,3];
    panelWithButton.Tag=[widgetStruct.Tag,'|Panel'];
    panelWithButton.Items={widgetStruct,rangeButton};
    panelWithButton.RowSpan=[1,1];
    panelWithButton.ColSpan=[1,1];