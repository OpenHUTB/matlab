function fileNamePanel=browseForIERSFile(widgetStruct)




    widgetStruct.ColSpan=[1,1];
    widgetStruct.RowSpan=[1,1];
    if isfield(widgetStruct,'NameLocation')
        widgetStruct=rmfield(widgetStruct,'NameLocation');
    end

    browseButton.Type='pushbutton';
    browseButton.ToolTip=getString(message('aerospace:eop:browseTooltip'));
    browseButton.FilePath=fullfile(matlabroot,'toolbox','shared','aerospace',...
    'customization','icons','Browse_16.png');
    browseButton.Tag='BrowseFileButton';
    browseButton.RowSpan=[1,1];
    browseButton.ColSpan=[3,3];
    browseButton.MatlabMethod='Aero.internal.core.eop.openIERSFile';
    browseButton.MatlabArgs={'%dialog'};

    fileNamePanel.Type='panel';
    fileNamePanel.Name='';
    fileNamePanel.LayoutGrid=[1,2];
    fileNamePanel.Tag=[widgetStruct.Tag,'|Panel'];
    fileNamePanel.Items={widgetStruct,browseButton};
    fileNamePanel.RowSpan=[1,1];
    fileNamePanel.ColSpan=[1,1];
