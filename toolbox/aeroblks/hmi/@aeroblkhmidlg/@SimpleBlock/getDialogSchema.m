function dlg=getDialogSchema(obj,~)





    blockHandle=get(obj.blockObj,'handle');
    model=get_param(bdroot(blockHandle),'Name');

    type=get_param(blockHandle,'BlockType');
    switch type
    case 'AltimeterBlock'
        desc=DAStudio.message('aeroblksHMI:aeroblkhmi:AltimeterDialogDesc');
        name=DAStudio.message('aeroblksHMI:aeroblkhmi:Altimeter');
        helparg='altimeter';
    case 'ArtificialHorizonBlock'
        desc=DAStudio.message('aeroblksHMI:aeroblkhmi:ArtificialHorizonDialogDesc');
        name=DAStudio.message('aeroblksHMI:aeroblkhmi:ArtificialHorizon');
        helparg='artificialhorizon';
    case 'HeadingIndicatorBlock'
        desc=DAStudio.message('aeroblksHMI:aeroblkhmi:HeadingIndicatorDialogDesc');
        name=DAStudio.message('aeroblksHMI:aeroblkhmi:HeadingIndicator');
        helparg='headingindicator';
    case 'TurnCoordinatorBlock'
        desc=DAStudio.message('aeroblksHMI:aeroblkhmi:TurnCoordinatorDialogDesc');
        name=DAStudio.message('aeroblksHMI:aeroblkhmi:TurnCoordinator');
        helparg='turncoordinator';
    end


    dlg=obj.getBaseDialogSchema();


    if utils.isAeroHMILibrary(model)
        labelPosition='Hide';
    else
        labelPosition=get_param(blockHandle,'LabelPosition');
    end

    text.Type='text';
    text.WordWrap=true;
    text.Name=desc;
    descGroup.Type='group';
    descGroup.Items={text};
    descGroup.Name=name;
    descGroup.RowSpan=[1,1];
    descGroup.ColSpan=[1,3];


    webbrowser=dlg.Items{1};
    webbrowser.RowSpan=[1,1];
    webbrowser.ColSpan=[1,3];


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
    legendPosition.RowSpan=[2,2];
    legendPosition.ColSpan=[1,3];


    propGroup.Type='group';
    propGroup.Items={...
    webbrowser,legendPosition...
    };
    propGroup.RowSpan=[2,3];
    propGroup.ColSpan=[1,3];
    propGroup.RowStretch=[1,0];
    propGroup.LayoutGrid=[2,3];

    dlg.Items={descGroup,propGroup};

    dlg.LayoutGrid=[2,3];
    dlg.RowStretch=[0,1];
    dlg.ColStretch=[0,0,0];

    dlg.AlwaysOnTop=true;
    dlg.ExplicitShow=1;
    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.HelpMethod='asbhmihelp';
    dlg.HelpArgs={helparg};
end
