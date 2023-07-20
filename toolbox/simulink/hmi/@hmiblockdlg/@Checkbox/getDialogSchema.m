
function dlg=getDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    values=get_param(blockHandle,'Values');
    label=get_param(blockHandle,'Label');
    labelPosition=get_param(blockHandle,'LabelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    dlg=obj.getBaseDialogSchema();

    opacity=get_param(blockHandle,'Opacity');
    colorJson=get_param(blockHandle,'BackgroundForegroundColor');
    [obj.BackgroundColor,obj.ForegroundColor]=hmiblockdlg.formatColorStrings(colorJson);

    text.Type='text';
    desc=DAStudio.message('SimulinkHMI:dialogs:CheckboxDialogDesc');
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:messages:DashboardCheckbox');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,2];

    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[2,2];
    webbrowser.ColSpan=[1,2];



    checkedRowHeader=DAStudio.message('SimulinkHMI:messages:DashboardCheckboxCheckedLabel');
    uncheckedRowHeader=DAStudio.message('SimulinkHMI:messages:DashboardCheckboxUncheckedLabel');
    checkedStateRowSpan=[2,2];
    uncheckedStateRowSpan=[1,1];

    uncheckedState.Type='text';
    uncheckedState.Name=uncheckedRowHeader;
    uncheckedState.WordWrap=true;
    uncheckedState.RowSpan=uncheckedStateRowSpan;
    uncheckedState.ColSpan=[1,1];

    uncheckedValue.Type='edit';
    uncheckedValue.Tag='uncheckedValue';
    uncheckedValue.Value=num2str(values(1),16);
    uncheckedValue.RowSpan=uncheckedStateRowSpan;
    uncheckedValue.ColSpan=[2,2];

    checkedState.Type='text';
    checkedState.Name=checkedRowHeader;
    checkedState.WordWrap=true;
    checkedState.RowSpan=checkedStateRowSpan;
    checkedState.ColSpan=[1,1];

    checkedValue.Type='edit';
    checkedValue.Tag='checkedValue';
    checkedValue.Value=num2str(values(2),16);
    checkedValue.RowSpan=checkedStateRowSpan;
    checkedValue.ColSpan=[2,2];

    stateLabelsGroup.Type='group';
    stateLabelsGroup.Name=DAStudio.message('SimulinkHMI:dialogs:CheckboxValuesPrompt');

    stateLabelsGroup.Items={uncheckedState,uncheckedValue,checkedState,checkedValue};
    stateLabelsGroup.RowSpan=[2,2];
    stateLabelsGroup.ColSpan=[1,2];
    stateLabelsGroup.LayoutGrid=[2,2];
    stateLabelsGroup.ColStretch=[0,1];

    labelField.Type='edit';
    labelField.Tag='labelField';
    labelField.Name=...
    [DAStudio.message('SimulinkHMI:dialogs:CheckboxLabelPrompt'),':'];
    labelField.RowSpan=[1,1];
    labelField.ColSpan=[1,2];
    labelField.Value=label;


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
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[1,2];



    opacityField.Type='edit';
    opacityField.Tag='opacity';
    opacityField.Name=[DAStudio.message('SimulinkHMI:dialogs:DashboardBlockOpacityPrompt'),':'];
    opacityField.Value=opacity;
    opacityField.RowSpan=[1,1];
    opacityField.ColSpan=[1,3];

    colorsHtmlPath='toolbox/simulink/hmi/web/Dialogs/SignalDialog/ForegroundBackgroundColors.html';
    colorWebbrowser=hmiblockdlg.createColorBrowserStructure(obj,colorsHtmlPath,false);
    colorWebbrowser.PreferredSize=[100,155];
    colorWebbrowser.RowSpan=[2,2];
    colorWebbrowser.ColSpan=[1,3];

    mainGroup.Type='group';
    mainGroup.Items={labelField,stateLabelsGroup,legendPosition};
    mainGroup.RowSpan=[2,2];
    mainGroup.ColSpan=[1,2];
    mainGroup.LayoutGrid=[4,2];
    mainGroup.RowStretch=[0,0,0,1];
    mainGroup.ColStretch=[1,1];

    formatGroup.Type='group';
    formatGroup.Items={opacityField,colorWebbrowser};
    formatGroup.RowSpan=[2,2];
    formatGroup.ColSpan=[1,2];
    formatGroup.LayoutGrid=[3,2];
    formatGroup.RowStretch=[0,0,1];
    formatGroup.ColStretch=[1,1];


    mainTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockMainGroup');
    mainTab.Items={mainGroup};


    formatTab.Name=DAStudio.message('SimulinkHMI:dialogs:GaugeBlockFormatGroup');
    formatTab.Items={formatGroup};


    tabContainer.Type='tab';
    tabContainer.Name='tabContainer';
    tabContainer.Tabs={mainTab,formatTab};

    dlg.Items={descGroup,webbrowser,tabContainer};
    dlg.LayoutGrid=[3,2];
    dlg.RowStretch=[0,0,1];
    dlg.ColStretch=[1,0];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_check_box'};


end