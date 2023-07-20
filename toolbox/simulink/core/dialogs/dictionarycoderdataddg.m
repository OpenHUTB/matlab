function dlgstruct=dictionarycoderdataddg(hObj)















    hParentModel=hObj;
    while~isempty(hParentModel)&&~isa(hParentModel,'Simulink.BlockDiagram')
        hParentModel=hParentModel.getParent;
    end

    if~isempty(hParentModel)&&isequal(hObj.getNodeName,'Design')

        dlgstruct=workspaceddg(hObj);
    else
        DictScopeText.Type='text';
        DictScopeText.Name=message('Simulink:dialog:DataDictCoderDataTitle').getString;
        DictScopeText.Tag='DictCoderDataScopeText';
        DictScopeText.RowSpan=[1,2];
        DictScopeText.ColSpan=[1,1];
        DictScopeText.MinimumSize=[400,50];
        DictScopeText.Alignment=1;
        DictScopeText.WordWrap=true;

        DictScopeButton.Type='pushbutton';
        DictScopeButton.Name=message('Simulink:dialog:DataDictCoderDataDesc').getString;
        DictScopeButton.Tag='DictCoderDataScopeDesc';
        DictScopeButton.MatlabMethod='simulinkcoder.internal.app.entryPoint';
        DictScopeButton.MatlabArgs={hObj.getParent.getFileSpec};
        DictScopeButton.RowSpan=[3,3];
        DictScopeButton.ColSpan=[1,1];
        DictScopeButton.Alignment=1;

        DictScopeContainer.Type='panel';
        DictScopeContainer.LayoutGrid=[3,1];
        DictScopeContainer.Alignment=2;
        DictScopeContainer.Items={DictScopeText,DictScopeButton};

        dlgstruct.DialogTitle=[DAStudio.message('Simulink:dialog:DataDictDialogTitle'),': ',hObj.getDisplayLabel];
        dlgstruct.Items={DictScopeContainer};
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
    end


