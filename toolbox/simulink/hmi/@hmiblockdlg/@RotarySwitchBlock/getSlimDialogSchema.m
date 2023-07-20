function dlg=getSlimDialogSchema(obj,~)




    dlg=obj.getBaseSlimDialogSchema();


    legendPositionLabel.Type='text';
    legendPositionLabel.Tag='labelPositionLabel';
    legendPositionLabel.Name=...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionPrompt');
    legendPositionLabel.RowSpan=[3,3];
    legendPositionLabel.ColSpan=[1,3];

    legendPosition.Type='combobox';
    legendPosition.Tag='labelPosition';
    legendPosition.Source=obj;
    legendPosition.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionTop'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionBottom'),...
    DAStudio.message('SimulinkHMI:dialogs:LabelPositionHide')...
    };
    labelPosition=simulink.hmi.getLabelPosition(obj.getBlock().LabelPosition);
    legendPosition.Value=labelPosition;
    legendPosition.MatlabMethod='utils.slimDialogUtils.setCoreBlockLabelPosition';
    legendPosition.MatlabArgs={'%dialog','%source','%tag','%value'};
    legendPosition.RowSpan=[3,3];
    legendPosition.ColSpan=[4,5];

    useEnumDataType=strcmp(obj.getBlock().UseEnumeratedDataType,'on');


    hBlk=get(obj.getBlock(),'handle');
    model=get_param(bdroot(hBlk),'Name');

    keys=obj.propMap.keys;
    remove(obj.propMap,keys);

    blkVals=get_param(hBlk,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    initProps=utils.getDiscreteKnobInitialPropertiesStruct(model,obj.widgetId,obj.isLibWidget);
    defaultLabels=cell(size(initProps));
    defaultValues=zeros(size(initProps));
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



    enableEnumType.Type='checkbox';
    enableEnumType.Tag='UseEnumDataType';
    enableEnumType.Name=DAStudio.message('SimulinkHMI:dialogs:RadioButtonGroupUsEnumDataType');
    enableEnumType.Source=obj;
    enableEnumType.Value=useEnumDataType;
    enableEnumType.MatlabMethod='utils.slimDialogUtils.setUseEnumDataType';
    enableEnumType.MatlabArgs={'%dialog','%source','%tag','%value'};
    enableEnumType.RowSpan=[2,2];
    enableEnumType.ColSpan=[1,2];

    enumDataType.Type='edit';
    enumDataType.Tag='EnumDataType';
    enumDataType.Source=obj;
    enumDataType.Value=obj.getBlock().EnumeratedDataType;
    enumDataType.Enabled=enableEnumType.Value;
    enumDataType.MatlabMethod='utils.slimDialogUtils.setEnumDataType';
    enumDataType.MatlabArgs={'%dialog','%source','%tag','%value'};
    enumDataType.RowSpan=[2,2];
    enumDataType.ColSpan=[3,5];


    obj.tableState=~((Simulink.HMI.isLibrary(model))||...
    (utils.isLockedLibrary(model))||useEnumDataType);

    fp='toolbox/simulink/hmi/web/Dialogs/ParameterDialog';
    url=[fp,'/DiscreteKnobPropertiesWidget.html?widgetID=',obj.widgetId...
    ,'&model=',model,'&isLibWidget=',num2str(obj.isLibWidget),...
    '&isSlimDialog=',num2str(true)];
    propbrowser.Type='webbrowser';
    propbrowser.Tag='sl_hmi_DiscretKnobProperties';
    propbrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    propbrowser.DisableContextMenu=true;
    propbrowser.MatlabMethod='slDialogUtil';
    propbrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};
    propbrowser.RowSpan=[5,5];
    propbrowser.ColSpan=[1,5];
    propbrowser.Enabled=obj.tableState;


    dlg.LayoutGrid=[6,5];
    dlg.RowStretch=[0,0,0,0,0,1];
    dlg.ColStretch=[0,0,0,0,1];
    dlg.Items=[dlg.Items,{...
    enableEnumType,enumDataType,legendPositionLabel,legendPosition,...
    propbrowser}];
end