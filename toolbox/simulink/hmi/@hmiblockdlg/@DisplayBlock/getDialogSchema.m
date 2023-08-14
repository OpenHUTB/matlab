

function dlg=getDialogSchema(obj,~)

    blockHandle=get(obj.blockObj,'handle');


    text.Type='text';

    desc=DAStudio.message('SimulinkHMI:dialogs:DisplayBlockDesc');
    text.WordWrap=true;
    text.Name=desc;
    descGroup.Type='group';
    descGroup.Name='Display';
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    dlg=obj.getBaseDialogSchema();
    labelPosition=get_param(blockHandle,'LabelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    format=get_param(blockHandle,'Format');
    formatString=get_param(blockHandle,'FormatString');
    alignment=get_param(blockHandle,'Alignment');
    opacity=get_param(blockHandle,'Opacity');
    layout=get_param(blockHandle,'Layout');
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    gridColor=get_param(blockHandle,'GridColor');
    showGridValue=get_param(blockHandle,'ShowGrid');

    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);
    obj.GridColor="["+gridColor(1)+","+gridColor(2)+","+gridColor(3)+"]";


    bindingTableBrowser=dlg.Items{1};
    bindingTableBrowser.RowSpan=[1,1];
    bindingTableBrowser.ColSpan=[1,3];
    bindingTableBrowser.MinimumSize=[100,80];


    format_tag.Type='combobox';
    format_tag.Tag='format';
    format_tag.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFormatPrompt'),':'];
    format_tag.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_E'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_E'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_G'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_G'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_ENG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:LONG_ENG'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:BANK'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:PLUS'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:HEX'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:RAT'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:INTEGER')
    };
    format_tag.Value=format;
    format_tag.MatlabMethod='utils.slimDialogUtils.callBackOfFormat';
    format_tag.MatlabArgs={'%dialog'};
    format_tag.RowSpan=[1,1];
    format_tag.ColSpan=[1,3];


    formatString_tag.Type='edit';
    formatString_tag.Tag='formatString';
    formatString_tag.Enabled=strcmp(format,DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM'));
    formatString_tag.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFormatStringPrompt'),':'];
    formatString_tag.Value=formatString;
    formatString_tag.RowSpan=[2,2];
    formatString_tag.ColSpan=[1,3];


    alignment_tag.Type='combobox';
    alignment_tag.Tag='alignment';
    alignment_tag.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockAlignmentPrompt'),':'];
    alignment_tag.Entries={...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockLeftAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockCenterAlignment'),...
    DAStudio.message('SimulinkHMI:dashboardblocks:DisplayBlockRightAlignment')...
    };
    alignment_tag.Value=utils.getTranslatedAlignment(alignment);
    alignment_tag.RowSpan=[3,3];
    alignment_tag.ColSpan=[1,3];


    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    legendPosition.Value=labelPosition;
    legendPosition.RowSpan=[4,4];
    legendPosition.ColSpan=[1,3];


    fitToView_tag.Type='combobox';
    fitToView_tag.Tag='fitToView';
    fitToView_tag.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockFitToViewPrompt'),':'];
    fitToView_tag.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutPreserveDimensions'),...
    DAStudio.message('SimulinkHMI:dialogs:DisplayBlockLayoutFillSpace')...
    };
    fitToView_tag.Value=utils.getTranslatedLayout(layout);
    fitToView_tag.RowSpan=[5,5];
    fitToView_tag.ColSpan=[1,3];


    transparency_tag.Type='edit';
    transparency_tag.Tag='opacity';
    transparency_tag.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    transparency_tag.Value=opacity;
    transparency_tag.RowSpan=[2,2];
    transparency_tag.ColSpan=[1,3];


    showGrid.Type='checkbox';
    showGrid.Tag='showGrid';
    showGrid.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockShowGridText')];
    showGrid.Value=strcmp(showGridValue,'on');
    if strcmpi(showGridValue,'on')
        showGrid.Value=1;
    else
        showGrid.Value=0;
    end
    showGrid.RowSpan=[1,1];
    showGrid.ColSpan=[1,3];


    mainGroup.Type='group';
    mainGroup.Tag='mainGroupTag';
    mainGroup.Items={format_tag,formatString_tag,alignment_tag,...
    legendPosition,fitToView_tag};
    numMainItems=length(mainGroup.Items);
    mainGroup.LayoutGrid=[numMainItems+1,3];
    mainGroup.RowStretch(1:numMainItems)=0;
    mainGroup.RowStretch(end+1)=1;
    mainGroup.ColStretch=[0,0,1];



    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/DisplayBlockColors.html';
    webbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,false);
    webbrowser.PreferredSize=[100,160];
    webbrowser.MinimumSize=[100,160];
    webbrowser.RowSpan=[9,9];
    webbrowser.ColSpan=[1,3];


    colorsGroup.Type='panel';
    colorsGroup.Tag='colorGroupTag';
    colorsGroup.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:DisplayBlockColorsGroup')];
    colorsGroup.RowSpan=[3,3];
    colorsGroup.ColSpan=[1,3];
    colorsGroup.LayoutGrid=[1,1];
    colorsGroup.Items={webbrowser};


    propGroup.Type='group';
    propGroup.Items={bindingTableBrowser};
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[4,3];
    propGroup.RowStretch=[1,0,0,0];
    propGroup.ColStretch=[0,0,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:DisplayBlockMainGroup');
    mainTab.Items={mainGroup};


    formatGroup.Type='group';
    formatGroup.Tag='formatGroupTag';
    formatGroup.Items={showGrid,transparency_tag,colorsGroup};
    numFormatItems=length(formatGroup.Items);
    formatGroup.LayoutGrid=[numFormatItems+1,3];
    formatGroup.RowStretch(1:numFormatItems)=0;
    formatGroup.RowStretch(end+1)=1;
    formatGroup.ColStretch=[0,0,1];


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab};

    dlg.Items={descGroup,propGroup,tabContainer};

    dlg.LayoutGrid=[3,3];
    dlg.RowStretch=[0,1,1];
    dlg.ColStretch=[1,0,0];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_display'};
end



