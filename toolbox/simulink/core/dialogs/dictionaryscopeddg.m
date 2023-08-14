function dlgstruct=dictionaryscopeddg(hObj)















    hParentModel=hObj;
    while~isempty(hParentModel)&&~isa(hParentModel,'Simulink.BlockDiagram')
        hParentModel=hParentModel.getParent;
    end

    if~isempty(hParentModel)&&isequal(hObj.getNodeName,'Design')

        dlgstruct=workspaceddg(hObj);
    else
        DictScopeDesc.Type='textbrowser';
        scopeDescName=['Simulink:dialog:DataDictScopeDesc_',hObj.getNodeName];
        try
            DictScopeDesc.Text=DAStudio.message(scopeDescName);
        catch me
            DictScopeDesc.Text=[hObj.getNodeName,' section description coming soon'];
        end
        DictScopeDesc.Tag='DictScopeDesc';

        if slfeature('ShowMECmdWindow')>0
            DictScopeDesc.MaximumSize=[-1,110];
            cmdWindow=cmdWindowDDG(hObj);
            dlgstruct.Items={DictScopeDesc,cmdWindow};
        else
            dlgstruct.Items={DictScopeDesc};
        end

        dlgstruct.DialogTitle=[DAStudio.message('Simulink:dialog:DataDictDialogTitle'),': ',hObj.getDisplayLabel];
        dlgstruct.HelpMethod='helpview';
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
    end


