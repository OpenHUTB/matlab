function fileNamePanel=getBrowseForFileWidget(widgetStruct)




    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end


    browseButton.Type='pushbutton';
    browseButton.ToolTip=getString(message('Simulink:dialog:SL_DSCPT_FROMFILE_BROWSE_TOOLTIP'));
    browseButton.FilePath=fullfile(matlabroot,'toolbox','simulink','core','general','+Simulink','+fromfile','images','Open_16.png');
    browseButton.Tag='BrowseButton:';
    browseButton.RowSpan=[1,1];
    browseButton.ColSpan=[2,2];
    browseButton.MatlabMethod='Simulink.fromfile.cb_browse';
    browseButton.MatlabArgs={'%dialog'};


    fileNamePanel.Type='panel';
    fileNamePanel.Name='';
    fileNamePanel.LayoutGrid=[1,2];
    fileNamePanel.Tag=[widgetStruct.Tag,'|Panel'];
    fileNamePanel.Items={widgetStruct,browseButton};
    fileNamePanel.RowSpan=[1,1];
    fileNamePanel.ColSpan=[1,1];

