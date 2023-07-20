function dlgstruct=slimblockpropddg(h,name)



    priorityEdit.Type='edit';
    priorityEdit.Tag='Priority';
    priorityEdit.Name=DAStudio.message('Simulink:dialog:priority');
    priorityEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterIntegerValue');
    priorityEdit.ObjectProperty='Priority';
    priorityEdit.MatlabMethod='defaultBlockPropCB_ddg';
    priorityEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
    priorityEdit.SaveState=false;
    priorityEdit.Graphical=1;
    priorityEdit.NameLocation=1;
    priorityEdit.RowSpan=[1,1];
    priorityEdit.ColSpan=[1,1];

    tagEdit.Type='edit';
    tagEdit.Tag='Tag';
    tagEdit.Name=DAStudio.message('Simulink:dialog:TagPrompt');
    tagEdit.ToolTip=DAStudio.message('Simulink:dialog:EnterTextHere');
    tagEdit.ObjectProperty='Tag';
    tagEdit.MatlabMethod='defaultBlockPropCB_ddg';
    tagEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
    tagEdit.SaveState=false;
    tagEdit.Graphical=1;
    tagEdit.NameLocation=1;
    tagEdit.RowSpan=[2,2];
    tagEdit.ColSpan=[1,1];

    grpGeneral.Name='General';
    grpGeneral.Type='togglepanel';
    grpGeneral.Items={priorityEdit,tagEdit};
    grpGeneral.Expand=true;
    grpGeneral.LayoutGrid=[2,1];
    grpGeneral.RowSpan=[1,1];
    grpGeneral.ColSpan=[1,1];


    annotationEditArea.Type='editarea';
    annotationEditArea.Tag='AttributesFormatString';
    annotationEditArea.Name=DAStudio.message('Simulink:dialog:EnterTextAndTokens');
    annotationEditArea.ToolTip=DAStudio.message('Simulink:dialog:EditAnnotationStringsTooltip');
    annotationEditArea.ObjectProperty='AttributesFormatString';
    annotationEditArea.MatlabMethod='defaultBlockPropCB_ddg';
    annotationEditArea.MatlabArgs={'%dialog','%source','%tag','%value'};
    annotationEditArea.SaveState=false;
    annotationEditArea.Graphical=1;


    grpAnnotation.Name='Annotation';
    grpAnnotation.Type='togglepanel';
    grpAnnotation.Items={annotationEditArea};
    grpAnnotation.RowSpan=[2,2];
    grpAnnotation.ColSpan=[1,1];



    parametersStruct=Simulink.internal.getBlkParametersAndCallbacks(h.Handle,false);
    callbackFunctions=parametersStruct.cbk.fcns;




































    items={};

    for i=1:length(callbackFunctions)

        cbkFcnStr=callbackFunctions{i};
        cbkFcnLen=length(cbkFcnStr);
        cbkFcnName=cbkFcnStr;
        if strcmp(cbkFcnStr(cbkFcnLen),'*')
            cbkFcnName=cbkFcnStr(1:cbkFcnLen-1);
        end

        callbackText.Type='text';
        callbackText.Tag=[cbkFcnStr,'text'];
        callbackText.Name=cbkFcnStr;
        callbackEdit.RowSpan=[i,i];
        callbackEdit.ColSpan=[1,1];

        callbackEdit.Type='edit';
        callbackEdit.Tag=cbkFcnName;
        callbackEdit.ToolTip=DAStudio.message('Simulink:dialog:EditingSelectedCallback');
        callbackEdit.ObjectProperty=cbkFcnName;
        callbackEdit.MatlabMethod='defaultBlockPropCB_ddg';
        callbackEdit.MatlabArgs={'%dialog','%source','%tag','%value'};
        callbackEdit.SaveState=false;
        callbackEdit.Graphical=1;
        callbackEdit.RowSpan=[i,i];
        callbackEdit.ColSpan=[2,2];









        items=cat(2,items,callbackText);
        items=cat(2,items,callbackEdit);

    end


    grpCallback.Name='Callbacks';
    grpCallback.Type='togglepanel';
    grpCallback.Items=items;
    grpCallback.LayoutGrid=[length(callbackFunctions),2];
    grpCallback.ColStretch=[0,1];
    grpCallback.RowSpan=[3,3];
    grpCallback.ColSpan=[1,1];



    spacer.Type='panel';
    spacer.RowSpan=[4,4];
    spacer.ColSpan=[1,1];





    dlgstruct.DialogTitle='';
    dlgstruct.DialogTag=name;
    dlgstruct.DialogMode='Slim';
    dlgstruct.Items={grpGeneral,grpAnnotation,grpCallback,spacer};
    dlgstruct.LayoutGrid=[4,1];
    dlgstruct.RowStretch=[0,0,0,1];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
end

