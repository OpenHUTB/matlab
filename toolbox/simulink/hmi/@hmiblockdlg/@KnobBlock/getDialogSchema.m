


function dlg=getDialogSchema(obj,~)
    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');


    type=get_param(blockHandle,'BlockType');
    switch type
    case 'KnobBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:ContinuousKnobDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:ContinuousKnob');
        helpTag='hmi_knob';
    case 'SliderBlock'
        desc=DAStudio.message('SimulinkHMI:dialogs:SliderDialogDesc');
        name=DAStudio.message('SimulinkHMI:dialogs:Slider');
        helpTag='hmi_slider';
    otherwise
        assert(false);
    end


    dlg=obj.getBaseDialogSchema();


    if Simulink.HMI.isLibrary(model)
        labelPosition=0;
        scaleType=0;
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
        labelPosition=simulink.hmi.getLabelPosition(labelPosition);

        scaleType=get_param(blockHandle,'ScaleType');
        scaleType=simulink.hmi.getScaleType(scaleType);
    end


    text.Type='text';
    text.Name=desc;
    text.WordWrap=true;
    descGroup.Type='group';
    descGroup.Name=name;
    descGroup.Items={text};
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={};
    propGroup.RowSpan=[2,2];
    propGroup.ColSpan=[1,3];
    propGroup.LayoutGrid=[6,3];
    propGroup.RowStretch=[1,0,0,0,0,0];
    propGroup.ColStretch=[1,1,1];


    bindingTable=dlg.Items{1};
    bindingTable.RowSpan=[1,1];
    bindingTable.ColSpan=[1,3];
    propGroup.Items{end+1}=bindingTable;


    scaleTypeValue.Type='combobox';
    scaleTypeValue.Tag='scaleType';
    scaleTypeValue.Name=DAStudio.message('SimulinkHMI:dialogs:ScaleType');
    scaleTypeValue.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLinear'),...
    DAStudio.message('SimulinkHMI:dialogs:ScaleTypeLog')
    };
    scaleTypeValue.Value=scaleType;
    scaleTypeValue.RowSpan=[2,2];
    scaleTypeValue.ColSpan=[1,3];
    scaleTypeValue.MatlabMethod='utils.scaleTypeChanged';
    scaleTypeValue.MatlabArgs={'%dialog',obj,false};
    propGroup.Items{end+1}=scaleTypeValue;


    minimumValue.Type='edit';
    minimumValue.Tag='minimumValue';
    minimumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MinimumPrompt');
    minimumValue.Value=get_param(blockHandle,'ScaleMin');
    minimumValue.RowSpan=[3,3];
    minimumValue.ColSpan=[1,3];
    propGroup.Items{end+1}=minimumValue;


    maximumValue.Type='edit';
    maximumValue.Tag='maximumValue';
    maximumValue.Name=DAStudio.message('SimulinkHMI:dialogs:MaximumPrompt');
    maximumValue.Value=get_param(blockHandle,'ScaleMax');
    maximumValue.RowSpan=[4,4];
    maximumValue.ColSpan=[1,3];
    propGroup.Items{end+1}=maximumValue;


    tickInterval.Type='edit';
    tickInterval.Tag='tickInterval';
    if scaleType
        tickInterval.Name=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalPrompt');
    else
        tickInterval.Name=DAStudio.message('SimulinkHMI:dialogs:TickIntervalPrompt');
    end
    tickInterval.Value=get_param(blockHandle,'TickInterval');
    tickInterval.RowSpan=[5,5];
    tickInterval.ColSpan=[1,3];
    propGroup.Items{end+1}=tickInterval;


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
    legendPosition.RowSpan=[6,6];
    legendPosition.ColSpan=[1,3];
    propGroup.Items{end+1}=legendPosition;


    dlg.Items={descGroup,propGroup};
    dlg.LayoutGrid=[2,2];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[1,1];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};
    dlg.HelpMethod='helpview';
    dlg.HelpArgs={[docroot,'/simulink/helptargets.map'],helpTag};
end



