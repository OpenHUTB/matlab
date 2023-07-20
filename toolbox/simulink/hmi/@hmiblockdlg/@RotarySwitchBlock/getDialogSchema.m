function dlg=getDialogSchema(obj,~)

    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');
    dlg=obj.getBaseDialogSchema();

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    blkVals=get_param(blockHandle,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    initProps=utils.getDiscreteKnobInitialPropertiesStruct(model,obj.widgetId,obj.isLibWidget);
    defaultLabels=cell(1,length(initProps));
    defaultValues=zeros(1,length(initProps));
    for idx=1:length(initProps)
        defaultLabels{idx}=initProps(idx).stateLabels;
        defaultValues(idx)=str2double(initProps(idx).states);
    end
    if~isequal(defaultLabels,curLabels)||~isequal(defaultValues,curValues)
        for idx=1:length(curLabels)
            newProps.index=idx;
            newProps.states=curValues(idx);
            newProps.stateLabels=curLabels{idx};
            obj.propMap(idx)=newProps;
        end
    else
        for idx=1:length(initProps)
            obj.propMap(idx)=initProps(idx);
        end
    end

    labelPosition=get_param(blockHandle,'LabelPosition');
    labelPosition=simulink.hmi.getLabelPosition(labelPosition);
    enableEnumTypeValue=get_param(blockHandle,'UseEnumeratedDataType');
    enumDataTypeValue=get_param(blockHandle,'EnumeratedDataType');


    text.Type='text';
    desc=DAStudio.message('SimulinkHMI:dialogs:DiscreteKnobDialogDesc');
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=DAStudio.message('SimulinkHMI:dialogs:DiscreteKnob');
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];




    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||strcmp(enableEnumTypeValue,'on'));

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(false)];

    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_DiscretKnobProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.RowSpan=[2,2];
    propbrowser.ColSpan=[1,3];
    propbrowser.Enabled=obj.tableState;


    enableEnumType.Type='checkbox';
    enableEnumType.Tag='EnableEnumDataType';
    enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
    enableEnumType.Value=strcmp(enableEnumTypeValue,'on');
    enableEnumType.MatlabMethod='utils.enableEnumTypeChanged';
    enableEnumType.MatlabArgs={'%dialog','%source',false};
    enableEnumType.RowSpan=[3,3];
    enableEnumType.ColSpan=[1,1];

    enumDataType.Type='edit';
    enumDataType.Tag='EnumDataTypeName';
    enumDataType.Value=enumDataTypeValue;
    enumDataType.Enabled=strcmp(enableEnumTypeValue,'on');
    enumDataType.RowSpan=[3,3];
    enumDataType.ColSpan=[2,3];


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


    propGroup.Type='group';
    propGroup.Items={webbrowser,propbrowser,enableEnumType,enumDataType,legendPosition};
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[4,3];
    propGroup.RowStretch=[1,0,0,0];
    propGroup.ColStretch=[0,0,1];

    dlg.Items={descGroup,propGroup};
    dlg.LayoutGrid=[3,3];
    dlg.RowStretch=[0,1,0];
    dlg.ColStretch=[0,0,1];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.DialogRefresh=true;

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],'hmi_rotary_switch'};
end