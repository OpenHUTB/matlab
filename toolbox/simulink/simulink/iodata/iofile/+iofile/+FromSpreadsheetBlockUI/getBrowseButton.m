function panelWithButton=getBrowseButton(widgetStruct)





    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    browseButton.Type='pushbutton';
    browseButton.ToolTip=getString(message('sl_iofile:excelfile:Browse_ToolTip'));
    browseButton.FilePath=slfullfile(slfileparts(mfilename('fullpath')),'images','Open_16.png');
    browseButton.Tag='BrowseButton:';
    browseButton.RowSpan=[1,1];
    browseButton.ColSpan=[2,2];
    browseButton.MatlabMethod='iofile.FromSpreadsheetBlockUI.cb_browse';
    browseButton.MatlabArgs={'%dialog'};


    panelWithButton.Type='panel';
    panelWithButton.Name='';
    panelWithButton.LayoutGrid=[1,3];
    panelWithButton.Tag=[widgetStruct.Tag,'|Panel'];
    panelWithButton.Items={widgetStruct,browseButton};
    panelWithButton.RowSpan=[1,1];
    panelWithButton.ColSpan=[1,1];

