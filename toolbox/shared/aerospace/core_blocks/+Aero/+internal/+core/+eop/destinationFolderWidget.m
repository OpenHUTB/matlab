function fileNamePanel=destinationFolderWidget(widgetStruct)




    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    browseButton.Type='pushbutton';
    browseButton.ToolTip=getString(message('aerospace:eop:browseFolderTooltip'));
    browseButton.FilePath=fullfile(matlabroot,'toolbox','shared','aerospace',...
    'customization','icons','Browse_16.png');
    browseButton.Tag='BrowseButton:';
    browseButton.RowSpan=[1,1];
    browseButton.ColSpan=[2,2];
    browseButton.MatlabMethod='Aero.internal.core.eop.browseForDestinationFolder';
    browseButton.MatlabArgs={'%dialog'};

    generateFileButton.Type='pushbutton';
    generateFileButton.ToolTip=getString(message('aerospace:eop:generateFileTooltip'));
    generateFileButton.Tag='GenerateFileButton';
    generateFileButton.RowSpan=[1,1];
    generateFileButton.ColSpan=[3,3];
    generateFileButton.MatlabMethod='Aero.internal.core.eop.createIERSFile';
    generateFileButton.MatlabArgs={'%dialog'};
    generateFileButton.Name=getString(message('aerospace:eop:createFile'));


    fileNamePanel.Type='panel';
    fileNamePanel.Name='';
    fileNamePanel.LayoutGrid=[1,3];
    fileNamePanel.Tag=[widgetStruct.Tag,'|Panel'];
    fileNamePanel.Items={widgetStruct,browseButton,generateFileButton};
    fileNamePanel.RowSpan=[1,1];
    fileNamePanel.ColSpan=[1,1];
