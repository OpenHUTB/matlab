function dlgstruct=dictionaryddsddg(hObj)





    root=hObj.getParent;
    ddConn=root.getConnection;

    DictScopeText.Type='text';
    DictScopeText.Name=message('dds:ui:DDG_Description').getString;
    DictScopeText.Tag='DictScopeText';
    DictScopeText.RowSpan=[1,2];
    DictScopeText.ColSpan=[1,2];


    DictScopeText.WordWrap=true;

    DictScopeButton.Type='pushbutton';
    DictScopeButton.Name=message('dds:ui:OpenUI_Button').getString;
    DictScopeButton.Tag='DictScopeButton';
    DictScopeButton.MatlabMethod='slprivate';
    DictScopeButton.MatlabArgs={'dds.internal.simulink.ui.internal.DDSLibraryUI.openUI',hObj,ddConn};
    DictScopeButton.RowSpan=[3,3];
    DictScopeButton.ColSpan=[1,1];


    DictScopeDetails.Type='textbrowser';
    DictScopeDetails.Tag='DictScopeDetails';
    DictScopeDetails.RowSpan=[4,5];
    DictScopeDetails.ColSpan=[1,2];

    DictScopeDetails.Text=message('dds:ui:DDG_NoLibrary').getString;

    if Simulink.DDSDictionary.ModelRegistry.hasDDSPart(ddConn.filespec)||...
        Simulink.DDSDictionary.ModelRegistry.isDDSPartDirty(ddConn.filespec)
        try
            mf0Model=Simulink.DDSDictionary.ModelRegistry.getOrLoadDDSModel(ddConn.filespec);
            allElements=mf0Model.topLevelElements;
            topElements=[];
            for el=allElements
                if isa(el,'dds.datamodel.system.System')
                    topElements=el;
                    break;
                end
            end

            if~isempty(topElements)
                DictScopeDetails.Text='';


                details=[topElements.TypeLibraries.Type.name,': ',num2str(topElements.TypeLibraries.Size)];
                DictScopeDetails.Text=[DictScopeDetails.Text,details,newline];
                details=[topElements.DomainLibraries.Type.name,': ',num2str(topElements.DomainLibraries.Size)];
                DictScopeDetails.Text=[DictScopeDetails.Text,details,newline];
                details=[topElements.QosLibraries.Type.name,': ',num2str(topElements.QosLibraries.Size)];
                DictScopeDetails.Text=[DictScopeDetails.Text,details,newline];
                details=[topElements.DomainParticipantLibraries.Type.name,': ',num2str(topElements.DomainParticipantLibraries.Size)];
                DictScopeDetails.Text=[DictScopeDetails.Text,details,newline];
                details=[topElements.ApplicationLibraries.Type.name,': ',num2str(topElements.ApplicationLibraries.Size)];
                DictScopeDetails.Text=[DictScopeDetails.Text,details,newline];
            end
        catch
        end
    end

    DictScopeContainer.Type='panel';
    DictScopeContainer.LayoutGrid=[5,2];
    DictScopeContainer.RowStretch=[0,0,0,0,1];
    DictScopeContainer.ColStretch=[0,1];

    DictScopeContainer.Items={DictScopeText,DictScopeButton,DictScopeDetails};

    dlgstruct.DialogTitle=[DAStudio.message('Simulink:dialog:DataDictDialogTitle'),': ',hObj.getDisplayLabel];
    dlgstruct.Items={DictScopeContainer};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/dds/helptargets.map'],'DDS_Dictionary'};
end


