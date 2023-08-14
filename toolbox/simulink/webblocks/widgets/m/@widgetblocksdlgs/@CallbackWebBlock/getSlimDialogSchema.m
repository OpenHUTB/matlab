function dlgStruct=getSlimDialogSchema(obj,~)
    h=obj.getBlock;



    btnText.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockButtonText');
    btnText.Type='edit';
    btnText.RowSpan=[1,1];
    btnText.ColSpan=[1,1];
    btnText.ObjectProperty='ButtonText';
    btnText.Tag=btnText.ObjectProperty;
    btnText.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.CallbackBlockPropCB_ddg';
    btnText.MatlabArgs={obj,'%dialog','%source','%tag','%value'};


    callbackPopup.Type='combobox';
    callbackPopup.Tag='callbackSwitch';
    callbackPopup.ObjectProperty='';
    callbackPopup.Graphical=1;
    callbackPopup.Value=obj.editingFcn;
    callbackPopup.Entries={...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockClickFcn'),...
    DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressFcn')
    };
    callbackPopup.RowSpan=[2,2];
    callbackPopup.ColSpan=[1,1];
    callbackPopup.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.callbackBlockFcnSelectionChangeCB';
    callbackPopup.MatlabArgs={'%dialog',obj,'%value'};

    mainItems={btnText,callbackPopup};


    if~obj.editingFcn


        clickFcnEditor.Name='';
        clickFcnEditor.Type='matlabeditor';
        clickFcnEditor.PreferredSize=[150,200];
        clickFcnEditor.Tag='ClickFcn';
        clickFcnEditor.ObjectProperty='ClickFcn';
        clickFcnEditor.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.CallbackBlockPropCB_ddg';
        clickFcnEditor.MatlabArgs={obj,'%dialog','%source','%tag','%value'};
        clickFcnEditor.RowSpan=[3,3];
        clickFcnEditor.ColSpan=[1,1];

        mainItems=[mainItems,clickFcnEditor];

    else


        pressFcnEditor.Name='';
        pressFcnEditor.Type='matlabeditor';
        pressFcnEditor.PreferredSize=[150,200];
        pressFcnEditor.Tag='PressFcn';
        pressFcnEditor.ObjectProperty='PressFcn';
        pressFcnEditor.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.CallbackBlockPropCB_ddg';
        pressFcnEditor.MatlabArgs={obj,'%dialog','%source','%tag','%value'};
        pressFcnEditor.RowSpan=[3,3];
        pressFcnEditor.ColSpan=[1,1];


        pressDelay.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockPressDelay');
        pressDelay.Type='edit';
        pressDelay.RowSpan=[4,4];
        pressDelay.ColSpan=[1,1];
        pressDelay.ObjectProperty='PressDelay';
        pressDelay.Tag=pressDelay.ObjectProperty;
        pressDelay.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.CallbackBlockPropCB_ddg';
        pressDelay.MatlabArgs={obj,'%dialog','%source','%tag','%value'};


        repeatInterval.Name=DAStudio.message('SimulinkHMI:dialogs:CallbackWebBlockRepeatInterval');
        repeatInterval.Type='edit';
        repeatInterval.RowSpan=[5,5];
        repeatInterval.ColSpan=[1,1];
        repeatInterval.ObjectProperty='RepeatInterval';
        repeatInterval.Tag=repeatInterval.ObjectProperty;
        repeatInterval.MatlabMethod='widgetblocksdlgs.CallbackWebBlock.CallbackBlockPropCB_ddg';
        repeatInterval.MatlabArgs={obj,'%dialog','%source','%tag','%value'};

        mainItems=[mainItems,pressFcnEditor,pressDelay,repeatInterval];
    end


    mainGrp.Name=DAStudio.message('Simulink:dialog:Main');
    mainGrp.Type='togglepanel';
    mainGrp.Expand=true;
    mainGrp.RowSpan=[1,1];
    mainGrp.ColSpan=[1,1];
    mainGrp.Source=h;
    mainGrp.LayoutGrid=[numel(mainItems),1];
    mainGrp.Items=mainItems;
    mainGrp.RowStretch=cellfun(@(item)double(strcmp(item.Type,'matlabeditor')),mainItems);


    dlgStruct.DialogTitle='';
    dlgStruct.DialogTag=h.BlockType;
    dlgStruct.DialogMode='Slim';
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.Items={mainGrp};
    dlgStruct.LayoutGrid=[1,1];
    dlgStruct.RowStretch=1;
    dlgStruct.ColStretch=1;
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    [~,isLocked]=obj.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end
end