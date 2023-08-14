function dlgstruct=dictionaryfunctionsectionddg(hObj)

    DictScopeDesc.Type='textbrowser';
    DictScopeDesc.Text=DAStudio.message('Simulink:dialog:DataDictScopeDesc_Function');
    DictScopeDesc.Tag='DictDASectionDesc';

    dlgstruct.Items={DictScopeDesc};
    dlgstruct.DialogTitle=[DAStudio.message('Simulink:dialog:DataDictDialogTitle'),': ',hObj.getDisplayLabel];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};



