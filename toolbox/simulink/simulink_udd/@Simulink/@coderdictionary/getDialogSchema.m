function dlgstruct=getDialogSchema(this,~)



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
    DictScopeButton.MatlabMethod='initializeAndStart';
    DictScopeButton.MatlabArgs={this};
    DictScopeButton.RowSpan=[3,3];
    DictScopeButton.ColSpan=[1,1];
    DictScopeButton.Alignment=1;

    DictScopeContainer.Type='panel';
    DictScopeContainer.LayoutGrid=[3,1];
    DictScopeContainer.Alignment=2;
    DictScopeContainer.Items={DictScopeText,DictScopeButton};





    dlgstruct.DialogTitle=message('SLDD:sldd:CodeDefinitions').getString;
    dlgstruct.Items={DictScopeContainer};
    dlgstruct.HelpMethod='helpview([docroot ''/toolbox/rtw/helptargets.map''],''code_browser_doc'')';
