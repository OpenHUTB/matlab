classdef RequirementDetails<handle





    methods(Static)

        function group=getDialogSchema(this,caller)
            import slreq.gui.* %#ok<NSTIMP>

            propsTop=this.propsTop;
            propsBot=this.propsBot;
            group.LayoutGrid=[4,1];
            group.RowStretch=[0,1,0,0];
            group.ColStretch=1;
            group.Type='togglepanel';
            group.Name=getString(message('Slvnv:slreq:Properties'));
            if this.isImportRootItem()


                group.Tag='TopNodePropertyPane';
                initialToggleState=false;
            else
                group.Tag='RequirementsDetailsPane';
                initialToggleState=true;
            end
            group.Expand=slreq.gui.togglePanelHandler('get',group.Tag,initialToggleState);
            group.ExpandCallback=@slreq.gui.togglePanelHandler;

            if isempty(this.dataModelObj)
                return;
            end

            attrPanelTop=generateDDGStructForProperties(this,propsTop,'panel','ReqTopPanel','topPanel');
            attrPanelTop.RowSpan=[1,1];
            attrPanelTop.ColSpan=[1,1];

            if~this.dataModelObj.external&&~isa(this,'slreq.das.ReqSpecTableRow')
                if this.isJustification
                    customIdIdx=4;
                else
                    customIdIdx=6;
                end

                if~strcmp(attrPanelTop.Items{customIdIdx}.Type,'text')
                    attrPanelTop.Items{customIdIdx}.PlaceholderText=this.Id;
                end


            end

            if~this.isJustification

                if isa(this,'slreq.das.Requirement')
                    reqTypeNames=slreq.app.RequirementTypeManager.getAllDisplayNames(this.RequirementSet);
                else
                    reqTypeNames=slreq.app.RequirementTypeManager.getAllDisplayNames();
                end
                if~isempty(reqTypeNames)&&~this.RequirementSet.isBackingModelLocked()
                    rSpan=attrPanelTop.Items{2}.RowSpan;
                    reqTypeCombobox=struct('Type','combobox','RowSpan',rSpan,'ColSpan',[2,2]);
                    reqTypeCombobox.Tag='Type';
                    entries=cell(1,numel(reqTypeNames));
                    for n=1:length(reqTypeNames)
                        entries{n}=reqTypeNames{n};
                    end
                    reqTypeCombobox.Entries=entries;
                    reqTypeCombobox.Mode=true;
                    reqTypeCombobox.ObjectProperty='Type';
                    reqTypeCombobox.Enabled=~this.dataModelObj.isChildOfInformationalType();
                    if~reqTypeCombobox.Enabled




                        reqTypeCombobox.ToolTip=getString(message('Slvnv:slreq:NotificationOnInformationalTypeTooltip'));
                    end



                    attrPanelTop.Items{2}=reqTypeCombobox;
                end
            end

            tabcontainer=struct('Type','tab','Name','tab','RowSpan',[2,2],'ColSpan',[1,1]);









            if this.dataModelObj.locked||this.RequirementSet.isBackingModelLocked()


                richEditor=struct('Type','webbrowser',...
                'RowSpan',[1,1],'ColSpan',[1,4],...
                'Tag','Description',...
                'WebKit',true,...
                'Enabled',true);
                richEditor.HTML=this.Description;
                richEditor.FontPointSize=8;

                rationaleEditor=struct('Type','webbrowser',...
                'RowSpan',[1,1],'ColSpan',[1,4],...
                'Tag','Rationale',...
                'WebKit',true,...
                'Enabled',true);
                rationaleEditor.HTML=this.Rationale;
                rationaleEditor.FontPointSize=8;

                attrPanel=generateDDGStructForProperties(this,propsBot,'togglepanel',...
                'ReqBottomPanel',getString(message('Slvnv:slreq:RevisionInfoColon')),'',true);

                keywordsEdit=struct('Type','edit','Name',getString(message('Slvnv:slreq:KeywordsColon')),...
                'Tag','KeyWords','Value',this.Keywords,'Enabled',false,'RowSpan',[3,3],'ColSpan',[1,1]);
                tab1.Items={richEditor};
                tab2.Items={rationaleEditor};
            else


                mgr=slreq.app.MainManager.getInstance;
                usingExternal=false;
                if mgr.UseExternalEditor
                    usingExternal=true;
                end
                if usingExternal
                    try










                        switchDescEditorButton=struct('Type','pushbutton',...
                        'Tag','switchDescriptionEditorBackToBuiltIn',...
                        'RowSpan',[1,1],'ColSpan',[2,2],...
                        'ToolTip',getString(message('Slvnv:slreq:ExternalEditorSwitchToBuiltInToolTip')));




                        switchDescEditorButton.FilePath=fullfile(matlabroot,...
                        'toolbox','shared','reqmgt','icons','switchbacktobuiltin.png');
                        switchDescEditorButton.MatlabMethod='slreq.gui.RequirementDetails.backToBuiltInDescCB';
                        switchDescEditorButton.MatlabArgs={'%dialog','%source'};




                        switchRatiEditorButton=struct('Type','pushbutton',...
                        'Tag','switchRationaleEditorBackToBuiltIn',...
                        'RowSpan',[1,1],'ColSpan',[2,2],...
                        'ToolTip',getString(message('Slvnv:slreq:ExternalEditorSwitchToBuiltInToolTip')));

                        switchRatiEditorButton.FilePath=fullfile(matlabroot,...
                        'toolbox','shared','reqmgt','icons','switchbacktobuiltin.png');
                        switchRatiEditorButton.MatlabMethod='slreq.gui.RequirementDetails.backToBuiltInRatiCB';
                        switchRatiEditorButton.MatlabArgs={'%dialog','%source'};


                        invokeDescEditorButton=struct('Type','pushbutton',...
                        'Tag','editDescExternal',...
                        'RowSpan',[1,1],'ColSpan',[1,1],...
                        'ToolTip',getString(message('Slvnv:slreq:ExternalEditorInvokeWord')));

                        invokeDescEditorButton.FilePath=fullfile(matlabroot,...
                        'toolbox','shared','reqmgt','icons','invokeword.png');

                        invokeDescEditorButton.MatlabMethod='slreq.gui.RequirementDetails.externalDescEditCB';
                        invokeDescEditorButton.MatlabArgs={this.dataModelObj.getUuid};


                        invokeRatiEditorButton=struct('Type','pushbutton',...
                        'Tag','editRatiExternal',...
                        'RowSpan',[1,1],'ColSpan',[1,1],...
                        'ToolTip',getString(message('Slvnv:slreq:ExternalEditorInvokeWord')));

                        invokeRatiEditorButton.FilePath=fullfile(matlabroot,...
                        'toolbox','shared','reqmgt','icons','invokeword.png');
                        invokeRatiEditorButton.MatlabMethod='slreq.gui.RequirementDetails.externalRatiEditCB';
                        invokeRatiEditorButton.MatlabArgs={this.dataModelObj.getUuid};
                        spacer=struct('Type','text','Name','  ','RowSpan',[1,1],'ColSpan',[3,4]);

                        if strcmpi(this.DescriptionEditorType,'word')


                            switchDescEditorButton.Visible=true;
                            invokeDescEditorButton.Visible=true;
                            spacer=struct('Type','text','Name','  ','RowSpan',[1,1],'ColSpan',[3,4]);
                            richEditor=struct('Type','webbrowser',...
                            'RowSpan',[2,4],'ColSpan',[1,4],...
                            'Tag','Description',...
                            'WebKit',true,...
                            'Enabled',true);
                            richEditor.HTML=this.Description;
                            richEditor.FontPointSize=8;
                        else

                            switchDescEditorButton.Visible=false;
                            invokeDescEditorButton.Visible=false;
                            richEditor=struct('Type','editarea',...
                            'RowSpan',[1,4],'ColSpan',[1,4],...
                            'Mode',true,'ObjectProperty','Description',...
                            'Tag','Description',...
                            'Enabled',true);
                            richEditor.Visible=true;
                            richEditor.Enabled=true;
                            richEditor.AutoFormatting=true;
                            richEditor.EnableCustomToolBarButton=true;
                            richEditor.CustomToolBarButtonMATLABMethod='slreq.gui.RequirementDetails.externalDescEditCB';
                            richEditor.CustomToolBarButtonMATLABArgs=this.dataModelObj.getUuid;
                            richEditor.CustomToolBarButtonIcon=fullfile(matlabroot,...
                            'toolbox','shared','reqmgt','icons','invokeword.png');
                            richEditor.CustomToolBarButtonToolTip=getString(message('Slvnv:slreq:ExternalEditorInvokeWordToolTip'));
                            richEditor.Graphical=true;
                            richEditor.WordWrap=true;
                            richEditor.FontPointSize=10;
                        end


                        if strcmpi(this.RationaleEditorType,'word')

                            switchRatiEditorButton.Visible=true;
                            invokeRatiEditorButton.Visible=true;
                            spacer=struct('Type','text','Name','  ','RowSpan',[1,1],'ColSpan',[3,4]);
                            rationaleEditor=struct('Type','webbrowser',...
                            'RowSpan',[2,4],'ColSpan',[1,4],...
                            'Tag','Rationale',...
                            'WebKit',true,...
                            'Enabled',true);
                            rationaleEditor.HTML=this.Rationale;
                            rationaleEditor.FontPointSize=8;
                        else
                            switchRatiEditorButton.Visible=false;
                            invokeRatiEditorButton.Visible=false;
                            rationaleEditor=struct('Type','editarea',...
                            'RowSpan',[1,4],'ColSpan',[1,4],...
                            'Mode',true,'ObjectProperty','Rationale',...
                            'Tag','Rationale',...
                            'Enabled',true);
                            rationaleEditor.Visible=true;
                            rationaleEditor.AutoFormatting=true;


                            rationaleEditor.EnableCustomToolBarButton=true;
                            rationaleEditor.CustomToolBarButtonMATLABMethod='slreq.gui.RequirementDetails.externalRatiEditCB';
                            rationaleEditor.CustomToolBarButtonMATLABArgs=this.dataModelObj.getUuid;
                            rationaleEditor.CustomToolBarButtonIcon=fullfile(matlabroot,...
                            'toolbox','shared','reqmgt','icons','invokeword.png');
                            rationaleEditor.CustomToolBarButtonToolTip=getString(message('Slvnv:slreq:ExternalEditorInvokeWordToolTip'));
                            rationaleEditor.Graphical=true;
                            rationaleEditor.WordWrap=true;

                            rationaleEditor.FontPointSize=10;
                        end

                        if~ispc



                            invokeRatiEditorButton.Visible=false;
                            invokeDescEditorButton.Visible=false;
                            rationaleEditor.EnableCustomToolBarButton=false;
                            richEditor.EnableCustomToolBarButton=false;
                            if~switchDescEditorButton.Visible
                                richEditor.RowSpan=[1,4];
                            end

                            if~switchRatiEditorButton.Visible
                                rationaleEditor.RowSpan=[1,4];
                            end
                        end

                        tab1.Items={switchDescEditorButton,invokeDescEditorButton,spacer,richEditor};
                        tab1.LayoutGrid=[2,4];
                        tab1.RowStretch=[0,1];
                        tab1.ColStretch=[0,0,1,1];
                        tab2.Items={switchRatiEditorButton,invokeRatiEditorButton,spacer,rationaleEditor};
                        tab2.LayoutGrid=[2,4];
                        tab2.RowStretch=[0,1];
                        tab2.ColStretch=[0,0,1,1];
                    catch ex %#ok<NASGU>
                        usingExternal=false;
                    end
                end

                if~usingExternal
                    richEditor=struct('Type','editarea',...
                    'RowSpan',[1,1],'ColSpan',[1,1],...
                    'Mode',true,'ObjectProperty','Description',...
                    'Tag','Description',...
                    'Enabled',true);
                    richEditor.Visible=true;
                    richEditor.AutoFormatting=true;
                    richEditor.Graphical=true;
                    richEditor.WordWrap=true;
                    richEditor.FontPointSize=10;

                    rationaleEditor=struct('Type','editarea',...
                    'RowSpan',[1,1],'ColSpan',[1,1],...
                    'Mode',true,'ObjectProperty','Rationale',...
                    'Tag','Rationale',...
                    'Enabled',true);
                    rationaleEditor.Visible=true;
                    rationaleEditor.AutoFormatting=true;
                    rationaleEditor.Graphical=true;
                    rationaleEditor.WordWrap=true;
                    rationaleEditor.FontPointSize=10;

                    tab1.Items={richEditor};
                    tab2.Items={rationaleEditor};
                end

                tab1.Name=getString(message('Slvnv:slreq:Description'));
                tab2.Name=getString(message('Slvnv:slreq:Rationale'));
                tabcontainer.Tag='descriptionAndRationaleTabContainer';
                tab1.Tag='DescriptionTab';
                tab2.Tag='RationaleTab';
                tabcontainer.Tabs={tab1,tab2};


                attrPanel=generateDDGStructForProperties(this,propsBot,'togglepanel',...
                'ReqBottomPanel',getString(message('Slvnv:slreq:RevisionInfoColon')),'',false);
                attrPanel.RowSpan=[4,4];
                attrPanel.ColSpan=[1,4];

                keywordsEdit=struct('Type','edit','Name',getString(message('Slvnv:slreq:KeywordsColon')),...
                'ObjectProperty','Keywords','Mode',1,'Tag','KeyWords','Graphical',true,'RowSpan',[3,3],'ColSpan',[1,1]);
            end

            tab1.Name=getString(message('Slvnv:slreq:Description'));
            tab2.Name=getString(message('Slvnv:slreq:Rationale'));
            tabcontainer.Tabs={tab1,tab2};
            attrPanel.RowSpan=[4,4];
            attrPanel.ColSpan=[1,1];

            group.Items={tabcontainer,attrPanel,keywordsEdit,attrPanelTop};

            if this.dataModelObj.external
                isTopLevel=this.dataModelObj.isImportRootItem();
                isOSLC=this.dataModelObj.getReqSet.isOSLC();

                buttonPanel=createButtonPanelForExternalRequirement(isTopLevel,isOSLC);
                group.Items{end+1}=buttonPanel;
            end

            function dlgstruct=createButtonPanelForExternalRequirement(isTopLevel,isOSLC)
                dlgstruct=struct('Type','panel','LayoutGrid',[1,4],...
                'Alignment',10);

                navigateButton=struct('Type','pushbutton',...
                'Tag','NavigateReq',...
                'Name',getString(message('Slvnv:slreq:ShowOriginal')),...
                'RowSpan',[1,1],'ColSpan',[1,1],...
                'ToolTip',getString(message('Slvnv:slreq:ShowOriginalTooltip')));
                navigateButton.MatlabMethod='slreq.gui.RequirementDetails.navigateToSource';
                navigateButton.MatlabArgs={'%dialog','%source',caller};


                unlockButton=struct('Type','pushbutton',...
                'Tag','UnlockReq',...
                'Name',getString(message('Slvnv:slreq:Unlock')),...
                'Visible',true,...
                'Enabled',~isOSLC&&this.dataModelObj.locked,...
                'RowSpan',[1,1],'ColSpan',[3,3],...
                'ToolTip',getString(message('Slvnv:slreq:UnlockTooltip')));
                unlockButton.MatlabMethod='slreq.gui.RequirementDetails.unlock';
                unlockButton.MatlabArgs={'%dialog','%source'};

                dlgstruct.Items={navigateButton,unlockButton};





                if isOSLC&&~isTopLevel
                    updateFromServerButton=struct('Type','pushbutton',...
                    'Tag','RefreshReq',...
                    'Name',getString(message('Slvnv:slreq:UpdateFromServer')),...
                    'Visible',true,...
                    'Enabled',true,...
                    'RowSpan',[1,1],'ColSpan',[4,4],...
                    'ToolTip',getString(message('Slvnv:slreq:UpdateFromServerTooltip')));
                    updateFromServerButton.MatlabMethod='slreq.gui.RequirementDetails.updateItemFromServer';
                    updateFromServerButton.MatlabArgs={'%dialog','%source'};

                    dlgstruct.Items{end+1}=updateFromServerButton;
                end
            end
        end

        function navigateToSource(dlg,src,caller)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end
            slreq.gui.LinkTargetUIProvider.navigate(src.dataModelObj,caller,true);
        end

        function updateItemFromServer(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end

            src.updateOSLCRequirement();
        end

        function unlock(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end

            src.unlock();
        end

        function externalDescEditCB(reqUuid)





            dasReq=locGetDasObj(reqUuid);




            updatePropValueIfNecessary(dasReq,'Description');


            eemgr=slreq.app.MainManager.getInstance.externalEditorManager;

            try
                editorObj=eemgr.getExternalEditor(dasReq,'Description',true);
                editorObj.invokeEditor();
                dasReq.DescriptionEditorType='word';
                locUpdateDialogs(dasReq);
                dasReq.LastDescEditorType='word';
            catch ex

                throwAsCaller(ex);
            end
        end

        function externalRatiEditCB(reqUuid)
            dasReq=locGetDasObj(reqUuid);




            updatePropValueIfNecessary(dasReq,'Rationale');

            eemgr=slreq.app.MainManager.getInstance.externalEditorManager;
            try
                editorObj=eemgr.getExternalEditor(dasReq,'Rationale',true);
                editorObj.invokeEditor();

                dasReq.RationaleEditorType='word';
                locUpdateDialogs(dasReq);
                dasReq.LastRatiEditorType='word';
            catch ex

                throwAsCaller(ex);
            end
        end


        function backToBuiltInDescCB(dlg,src)
            if strcmpi(src.DescriptionEditorType,'word')
                if isUserWantToSwitchToBuiltIn

                    closeEditor(src,'Description');
                    src.DescriptionEditorType='';
                    dlg.refresh;
                else

                end
            end
        end


        function backToBuiltInRatiCB(dlg,src)
            if strcmpi(src.RationaleEditorType,'word')
                if isUserWantToSwitchToBuiltIn

                    closeEditor(src,'Rationale');
                    src.RationaleEditorType='';
                    dlg.refresh;
                else

                end
            end
        end
    end
end


function out=isUserWantToSwitchToBuiltIn()

    reply=questdlg(getString(message('Slvnv:slreq:ExternalEditorSwitchToBuiltInWarningDlgWarningMsg')),...
    getString(message('Slvnv:slreq:WarningDlgTitle')),...
    getString(message('Slvnv:slreq:Continue')),...
    getString(message('Slvnv:slreq:Cancel')),...
    getString(message('Slvnv:slreq:Cancel')));
    if isempty(reply)||strcmp(reply,getString(message('Slvnv:slreq:Cancel')))
        out=false;
    else
        out=true;
    end

end


function out=getUserActionForUnsavedChange()

    out=questdlg(getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgMsg')),...
    getString(message('Slvnv:slreq:WarningDlgTitle')),...
    getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgDiscardExternalChange')),...
    getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgCancel')),...
    getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgCancel')));

end


function dasReq=locGetDasObj(reqUuid)
    dasReq=slreq.utils.findDASbyUUID(reqUuid);
end



function locUpdateDialogs(dasReq)
    dlgs=DAStudio.ToolRoot.getOpenDialogs(dasReq);
    slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);

end


function updatePropValueIfNecessary(dasReq,fieldName)




    if strcmpi(fieldName,'Description')
        currentEditorType=dasReq.DescriptionEditorType;
    else
        currentEditorType=dasReq.RationaleEditorType;
    end



    if isempty(currentEditorType)







        dlg=DAStudio.ToolRoot.getOpenDialogs(dasReq);
        for index=1:length(dlg)
            cDlg=dlg(index);
            propValueInEditor=cDlg.getWidgetValue(fieldName);
            currentContent=dasReq.(fieldName);
            if~strcmp(currentContent,propValueInEditor)
                dasReq.(fieldName)=propValueInEditor;
                return;
            end
        end
    end
end



function closeEditor(dasReq,fieldName)
    eemgr=slreq.app.MainManager.getInstance.externalEditorManager;


    editorObj=eemgr.getExternalEditor(dasReq,fieldName,false);
    if~isempty(editorObj)



        editorObj.disableListener();
        if editorObj.hasUnsavedChange()
            switch getUserActionForUnsavedChange()
            case getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgDiscardExternalChange'))
                editorObj.closeDoc();
            case getString(message('Slvnv:slreq:ExternalEditorHasUnsavedChangeWarningDlgCancel'))
                editorObj.enableListener();
                return;
            otherwise

                assert(false,'Unexpected branch reached.');
                return;
            end
        else
            editorObj.closeDoc();
        end
    else

    end
end