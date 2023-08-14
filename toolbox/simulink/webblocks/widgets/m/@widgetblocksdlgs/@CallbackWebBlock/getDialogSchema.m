function dlgStruct=getDialogSchema(obj,~)
    h=obj.getBlock;


    descTxt.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockDesc');
    descTxt.Type='text';
    descTxt.WordWrap=true;


    descGrp.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlock');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,2];

    btnText.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockButtonText');
    btnText.Type='edit';
    btnText.RowSpan=[1,1];
    btnText.ColSpan=[1,1];
    btnText.ObjectProperty='ButtonText';
    btnText.Tag=btnText.ObjectProperty;

    callbackPopup.Name='';
    callbackPopup.Type='combobox';
    callbackPopup.Tag='callbackSwitch';
    callbackPopup.ObjectProperty='';

    callbackPopup.Value=obj.editingFcn;
    callbackPopup.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackPopup.RowSpan=[2,2];
    callbackPopup.ColSpan=[1,2];

    callbackPopup.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackPopup.MatlabArgs={'%dialog',obj,'%value'};

    clickFcnEditor.Name='';
    clickFcnEditor.Type='matlabeditor';
    clickFcnEditor.PreferredSize=[150,200];
    clickFcnEditor.Tag='ClickFcn';
    clickFcnEditor.ObjectProperty='ClickFcn';
    clickFcnEditor.Visible=~obj.editingFcn;
    clickFcnEditor.MatlabMethod='slDialogUtil';
    clickFcnEditor.MatlabArgs={obj,'sync','%dialog','edit','ClickFcn'};
    clickFcnEditor.RowSpan=[3,3];
    clickFcnEditor.ColSpan=[1,2];

    pressFcnEditor.Name='';
    pressFcnEditor.Type='matlabeditor';
    pressFcnEditor.PreferredSize=[150,200];
    pressFcnEditor.Tag='PressFcn';
    pressFcnEditor.ObjectProperty='PressFcn';
    pressFcnEditor.MatlabMethod='slDialogUtil';
    pressFcnEditor.MatlabArgs={obj,'sync','%dialog','edit','PressFcn'};
    pressFcnEditor.Visible=obj.editingFcn;
    pressFcnEditor.RowSpan=[3,3];
    pressFcnEditor.ColSpan=[1,2];

    pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
    pressDelay.Type='edit';
    pressDelay.RowSpan=[4,4];
    pressDelay.ColSpan=[1,1];
    pressDelay.ObjectProperty='PressDelay';
    pressDelay.Tag=pressDelay.ObjectProperty;
    pressDelay.MatlabMethod='slDialogUtil';
    pressDelay.MatlabArgs={obj,'sync','%dialog','edit','PressDelay'};
    pressDelay.Visible=obj.editingFcn;

    repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
    repeatInterval.Type='edit';
    repeatInterval.RowSpan=[4,4];
    repeatInterval.ColSpan=[2,2];
    repeatInterval.ObjectProperty='RepeatInterval';
    repeatInterval.Tag=repeatInterval.ObjectProperty;
    repeatInterval.MatlabMethod='slDialogUtil';
    repeatInterval.MatlabArgs={obj,'sync','%dialog','edit','RepeatInterval'};
    repeatInterval.Visible=obj.editingFcn;


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,2];
    paramGrp.Source=h;
    paramGrp.Items={btnText,callbackPopup,clickFcnEditor,pressFcnEditor,pressDelay,repeatInterval};




    dlgStruct.DialogTitle='';
    dlgStruct.DialogTag=h.BlockType;
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,2];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.ColStretch=[0,1];
    dlgStruct.StandaloneButtonSet={'Ok','Cancel','Help','Apply'};
    dlgStruct.ExplicitShow=1;

    dlgStruct.PreApplyMethod='preApplyCB';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'callback'};



    [~,isLocked]=obj.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end