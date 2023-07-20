classdef Toolbar<handle



    methods(Static)
        function dlgStruct=getDialogSchema(this)






            view=this.view;
            currentObjects=view.getCurrentSelection;

            slreq.utils.assertValid(currentObjects);

            [isInternalReq,isExternal,isJustification]=slreq.app.CallbackHandler.getDasRequirementType(currentObjects);
            if~isempty(currentObjects)
                currentObj=currentObjects(1);
            else
                currentObj=slreq.das.BaseObject.empty();
            end
            isMultiSelection=numel(currentObjects)>1;
            if isMultiSelection
                isSiblings=currentObjects.isSiblings();
            else
                isSiblings=true;
            end

            isSingleRow=false;
            if isa(view,'slreq.gui.ReqSpreadSheet')
                isSingleRow=view.fitForHorizontalAlignment();
            end

            setFilePanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[1,1],'LayoutGrid',[1,3],'ContentsMargins',[0,0,0,0],'Spacing',0);
            addReqSet=struct('Type','pushbutton','Tag','addReqSetButton',...
            'ToolTip',getString(message('Slvnv:slreq:NewRequirementSet')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','addReqSet.png'),...
            'RowSpan',[1,1],'ColSpan',[1,1],'PreferredSize',[28,24]);
            addReqSet.Enabled=view.isReqView;

            addReqSet.MatlabMethod='slreq.gui.Toolbar.addReqSet';
            addReqSet.MatlabArgs={'%source'};

            openReqLinkSet=struct('Type','pushbutton','Tag','openReqLinkSetButton',...
            'ToolTip',getString(message('Slvnv:slreq:OpenReqSet')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','openReqSet.png'),...
            'RowSpan',[1,1],'ColSpan',[2,2],'PreferredSize',[28,24]);
            openReqLinkSet.Enabled=view.isReqView;
            openReqLinkSet.MatlabMethod='slreq.gui.Toolbar.openReqLinkSet';
            openReqLinkSet.MatlabArgs={'%source'};

            saveReqLinkSet=struct('Type','pushbutton','Tag','saveReqLinkSetButton',...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','saveReqSet.png'),...
            'RowSpan',[1,1],'ColSpan',[3,3],'PreferredSize',[28,24]);
            if view.isReqView
                saveReqLinkSet.ToolTip=getString(message('Slvnv:slreq:SaveReqSet'));
            else
                saveReqLinkSet.ToolTip=getString(message('Slvnv:slreq:SaveLinkSet'));
            end
            if~isempty(currentObj)&&~isMultiSelection
                saveReqLinkSet.Enabled=true;
            else
                saveReqLinkSet.Enabled=false;
            end

            saveReqLinkSet.MatlabMethod='slreq.gui.Toolbar.saveReqLinkSet';
            saveReqLinkSet.MatlabArgs={'%source'};
            setFilePanel.Items={addReqSet,openReqLinkSet,saveReqLinkSet};

            reqLinkPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[2,2],'LayoutGrid',[1,8]);

            addreq=struct('Type','pushbutton','Tag','addReqLinkButton',...
            'ToolTip',getString(message('Slvnv:slreq:AddRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','addReq.png'),...
            'RowSpan',[1,1],'ColSpan',[1,1],'PreferredSize',[28,24]);
            addreq.Enabled=~isMultiSelection...
            &&(isa(currentObj,'slreq.das.RequirementSet')...
            ||isInternalReq...
            ||(isExternal&&isa(currentObj.parent,'slreq.das.RequirementSet')));
            addreq.MatlabMethod='slreq.gui.Toolbar.addReq';
            addreq.MatlabArgs={'%source'};

            promote=struct('Type','pushbutton','Tag','promoteButton',...
            'ToolTip',getString(message('Slvnv:slreq:PromoteRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','promote.png'),...
            'RowSpan',[1,1],'ColSpan',[2,2],'PreferredSize',[28,24]);
            promote.Enabled=isa(currentObj,'slreq.das.Requirement')&&currentObj.canPromote(view)&&~isMultiSelection;
            promote.MatlabMethod='slreq.gui.Toolbar.promoteReq';
            promote.MatlabArgs={'%source'};

            demote=struct('Type','pushbutton','Tag','demoteButton',...
            'ToolTip',getString(message('Slvnv:slreq:DemoteRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','demote.png'),...
            'RowSpan',[1,1],'ColSpan',[3,3],'PreferredSize',[28,24]);
            demote.Enabled=isa(currentObj,'slreq.das.Requirement')&&currentObj.canDemote(view)&&~isMultiSelection;
            demote.MatlabMethod='slreq.gui.Toolbar.demoteReq';
            demote.MatlabArgs={'%source'};

            cutReqLink=struct('Type','pushbutton','Tag','cutReqLinkButton',...
            'ToolTip',getString(message('Slvnv:slreq:CutRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','cutReqLink.png'),...
            'RowSpan',[1,1],'ColSpan',[1,1],'PreferredSize',[28,24]);
            cutReqLink.Enabled=isSiblings&&(isInternalReq||isJustification);
            cutReqLink.MatlabMethod='slreq.gui.Toolbar.cutItem';
            cutReqLink.MatlabArgs={'%source'};

            copyReqLink=struct('Type','pushbutton','Tag','copyReqLinkButton',...
            'ToolTip',getString(message('Slvnv:slreq:CopyRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','copyReqLink.png'),...
            'RowSpan',[1,1],'ColSpan',[2,2],'PreferredSize',[28,24]);
            copyReqLink.Enabled=isSiblings&&isa(currentObj,'slreq.das.Requirement');
            copyReqLink.MatlabMethod='slreq.gui.Toolbar.copyItem';
            copyReqLink.MatlabArgs={'%source','%dialog'};

            pastReqLink=struct('Type','pushbutton','Tag','pasteReqLinkButton',...
            'ToolTip',getString(message('Slvnv:slreq:PasteRequirement')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','pasteReqLink.png'),...
            'RowSpan',[1,1],'ColSpan',[3,3],'PreferredSize',[28,24]);

            pastReqLink.Enabled=slreq.app.CallbackHandler.isPasteAllowed(currentObjects);

            pastReqLink.MatlabMethod='slreq.gui.Toolbar.pasteItem';
            pastReqLink.MatlabArgs={'%source'};

            delReqLink=struct('Type','pushbutton','Tag','delReqLinkButton',...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','deleteReqLink.png'),...
            'RowSpan',[1,1],'ColSpan',[4,4],'PreferredSize',[28,24]);
            if isa(currentObj,'slreq.das.Requirement')
                delReqLink.ToolTip=getString(message('Slvnv:slreq:DeleteRequirement'));
            elseif isa(currentObj,'slreq.das.Link')
                delReqLink.ToolTip=getString(message('Slvnv:slreq:DeleteLink'));
            end


            delReqLink.Enabled=...
            isa(currentObj,'slreq.das.Link')...
            ||isInternalReq...
            ||isJustification...
            ||(isExternal&&currentObj.dataModelObj.isImportRootItem());
            delReqLink.Enabled=delReqLink.Enabled&&isSiblings;

            delReqLink.MatlabMethod='slreq.gui.Toolbar.delReqLink';
            delReqLink.MatlabArgs={'%source'};

            justification=struct('Type','pushbutton','Tag','justificationButton',...
            'ToolTip',getString(message('Slvnv:slreq:AddJustification')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','reqmgt','icons','addJustification.png'),...
            'RowSpan',[1,1],'ColSpan',[8,8],'PreferredSize',[28,24]);
            justification.Enabled=false;
            if~isMultiSelection
                if isa(currentObj,'slreq.das.Requirement')
                    parentDas=currentObj.parent;
                    if isa(parentDas,'slreq.das.Requirement')&&parentDas.isJustification
                        justification.Enabled=true;
                    elseif isa(parentDas,'slreq.das.RequirementSet')&&isJustification
                        justification.Enabled=true;
                    end
                elseif isa(currentObj,'slreq.das.RequirementSet')
                    justification.Enabled=true;
                end
            end
            justification.MatlabMethod='slreq.gui.Toolbar.addJustification';
            justification.MatlabArgs={'%source'};

            refresh=struct('Type','pushbutton','Tag','refreshButton',...
            'ToolTip',getString(message('Slvnv:slreq:Refresh')),...
            'FilePath',fullfile(matlabroot,'toolbox','shared','dastudio','resources','webkit','Refresh_16.png'),...
            'RowSpan',[1,1],'ColSpan',[9,9],'PreferredSize',[28,24]);
            refresh.MatlabMethod='slreq.gui.Toolbar.refresh';
            refresh.MatlabArgs={'%source'};
            refresh.Enabled=true;

            noDestructivePanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[1,1],'LayoutGrid',[1,2],'ContentsMargins',[0,0,0,0],'Spacing',0);
            noDestructivePanel.Items={addreq,promote,demote};
            destructivePanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[2,2],'LayoutGrid',[1,8],'ContentsMargins',[0,0,0,0],'Spacing',0);
            destructivePanel.Items={cutReqLink,copyReqLink,pastReqLink,delReqLink};
            otherBtnPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[3,3],'LayoutGrid',[1,2],'ContentsMargins',[0,0,0,0],'Spacing',0);
            otherBtnPanel.Items={justification,refresh};

            if reqmgt('rmiFeature','FilteredView')
                viewPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[4,4],'LayoutGrid',[1,2],'ContentsMargins',[0,0,0,0],'Spacing',0);
                viewPanel.Items={this.generateFilterViewCombo};
                reqLinkPanel.Items={noDestructivePanel,destructivePanel,otherBtnPanel,viewPanel};
            else
                reqLinkPanel.Items={noDestructivePanel,destructivePanel,otherBtnPanel};
            end

            spacerWidget1st.Type='panel';
            spacerWidget1st.RowSpan=[1,1];
            spacerWidget1st.ColSpan=[3,3];

            viewChangeCombobox=struct('Type','combobox','Tag','viewChangeCombobox','Name',getString(message('Slvnv:slreq:ViewColon')),'Graphical',true);
            viewChangeCombobox.Entries={getString(message('Slvnv:slreq:Requirements')),getString(message('Slvnv:slreq:Links'))};
            if view.isReqView
                viewChangeCombobox.Value=0;
            else
                viewChangeCombobox.Value=1;
            end
            viewChangeCombobox.DialogRefresh=0;
            viewChangeCombobox.SaveState=0;
            viewChangeCombobox.MatlabMethod='slreq.gui.Toolbar.viewChangedCallback';
            viewChangeCombobox.MatlabArgs={'%source','%value'};

            filterButton.Type='spreadsheetfilter';
            filterButton.Tag='req_spreadsheet_filter_button';
            if view.isReqView
                filterButton.ToolTip=getString(message('Slvnv:slreq:SearchTooltipReq'));
            else
                filterButton.ToolTip=getString(message('Slvnv:slreq:SearchTooltipLink'));
            end
            filterButton.RowSpan=[1,1];
            filterButton.ColSpan=[4,4];
            filterButton.Clearable=true;
            filterButton.PlaceholderText=getString(message('Slvnv:slreq:Search'));


            view_suggestion_panel.Type='panel';
            view_suggestion_panel.Tag='views_suggestion_panel';
            view_suggestion_panel.Items={};


            showSuggestion=false;
            if isa(view,'slreq.gui.RequirementsEditor')
                if view.ShowSuggestion
                    showSuggestion=true;
                    suggestionreason=view.SuggestionReason;
                    suggestionId=view.SuggestionId;
                else
                    lsm=slreq.linkmgr.LinkSetManager.getInstance;


                    if lsm.hasPendingBannerMessage(view)
                        showSuggestion=true;
                        bannerMessages=lsm.getPendingBannerMessage(view);


                        suggestionId=bannerMessages{1}.Identifier;

                        suggestionreason=bannerMessages{1}.getString();
                    end
                end
            end

            view_suggestion_panel.Visible=showSuggestion;
            if showSuggestion
                currentCol=1;
                suggestion_info_icon.Type='image';
                suggestion_info_icon.Tag='suggestion_info_icon';
                suggestion_info_icon.ToolTip='';
                suggestion_info_icon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','info_suggestion.png');
                suggestion_info_icon.RowSpan=[1,1];
                suggestion_info_icon.ColSpan=[currentCol,currentCol];

                currentCol=currentCol+1;
                suggestion_content.Type='text';
                suggestion_content.Tag='views_suggestion_reason';
                suggestion_content.RowSpan=[1,1];
                suggestion_content.ColSpan=[currentCol,currentCol+1];
                suggestion_content.Name=suggestionreason;

                currentCol=currentCol+2;
                suggestion_help.Type='image';
                suggestion_help.Tag='views_suggestion_help';
                suggestion_help.MatlabMethod='slreq.gui.Toolbar.suggestionHelpLink';
                suggestion_help.MatlabArgs={'%dialog',suggestionId};
                suggestion_help.RowSpan=[1,1];
                suggestion_help.ToolTip=getString(message('Slvnv:slreq:GoToDoc'));
                suggestion_help.ColSpan=[currentCol,currentCol];
                suggestion_help.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','help.png');

                currentCol=currentCol+1;
                suggestion_spacer.Type='panel';
                suggestion_spacer.RowSpan=[1,1];
                suggestion_spacer.ColSpan=[currentCol,currentCol];

                currentCol=currentCol+1;
                suggestion_close_icon.Type='pushbutton';
                suggestion_close_icon.Tag='suggestion_close_button';
                suggestion_close_icon.MaximumSize=[15,15];
                suggestion_close_icon.BackgroundColor=[255,255,225];
                suggestion_close_icon.MatlabMethod='slreq.gui.Toolbar.closeSuggestion';
                suggestion_close_icon.MatlabArgs={'%source','%dialog',suggestionId};
                suggestion_close_icon.Name='';
                suggestion_close_icon.ToolTip='';
                suggestion_close_icon.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','CloseTabButton-Clicked.png');
                suggestion_close_icon.Flat=true;
                suggestion_close_icon.RowSpan=[1,1];
                suggestion_close_icon.ColSpan=[currentCol,currentCol];


                view_suggestion_panel.BackgroundColor=[255,255,225];
                view_suggestion_panel.LayoutGrid=[1,currentCol];
                view_suggestion_panel.ColStretch=[0,0,0,0,1,0];
                view_suggestion_panel.Enabled=~this.busy;
                view_suggestion_panel.Items={suggestion_info_icon,...
                suggestion_content,...
                suggestion_help,...
                suggestion_spacer,suggestion_close_icon};
            end

            titlePanel.Type='panel';
            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];
            titlePanel.Enabled=~this.busy;

            spacerWidget.Type='panel';
            spacerWidget.RowSpan=[1,1];

            if isSingleRow
                titlePanel.LayoutGrid=[1,4];
                titlePanel.ColStretch=[0,0,1,0];
                firstRowPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[2,2],'LayoutGrid',[1,3],'ColStretch',[0,0,1],'ContentsMargins',[0,0,0,0]);
                firstRowPanel.Items={setFilePanel,reqLinkPanel,spacerWidget};
                viewChangeCombobox.ColSpan=[1,1];
                spacerWidget.ColSpan=[3,3];
                titlePanel.Items={viewChangeCombobox,firstRowPanel,spacerWidget,filterButton};
            else
                titlePanel.LayoutGrid=[2,1];
                firstRowPanel=struct('Type','panel','RowSpan',[1,1],'ColSpan',[1,1],'LayoutGrid',[1,3],'ColStretch',[0,0,1],'ContentsMargins',[0,0,0,0]);
                firstRowPanel.Items={setFilePanel,reqLinkPanel,spacerWidget1st};

                secondRowPanel=struct('Type','panel','RowSpan',[2,2],'ColSpan',[1,1],'LayoutGrid',[1,4],'ColStretch',[0,0,1,0],'ContentsMargins',[0,0,0,0]);
                spacerWidget.Type='panel';
                spacerWidget.RowSpan=[1,1];
                spacerWidget.ColSpan=[3,3];
                secondRowPanel.Items={viewChangeCombobox,spacerWidget,filterButton};
                titlePanel.Items={firstRowPanel,secondRowPanel};
            end
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel,view_suggestion_panel};

            if isa(view,'slreq.gui.ReqSpreadSheet')

                DialogTag='req_spreadsheet_view_dlg';
            else

                DialogTag='req_editor_button_dlg';
            end
            dlgStruct.DialogTag=DialogTag;
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end


        function addReqSet(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();

            currentView=getCurrentView(dialogSrc);
            reqSetDas=appmgr.callbackHandler.addNewReqSet();

            if~isempty(reqSetDas)
                if isa(currentView,'slreq.gui.ReqSpreadSheet')
                    currentView.createAndRegisterLinkSet(reqSetDas);
                end
                appmgr.update();
                currentView.setSelectedObject(reqSetDas);
            end
        end

        function openReqLinkSet(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            appmgr.notify('SleepUI');
            cleanup=onCleanup(@()appmgr.notify('WakeUI'));

            reqSetDas=appmgr.callbackHandler.openReqSet();
            if isempty(reqSetDas)

                return;
            end

            currentView=getCurrentView(dialogSrc);
            if isa(currentView,'slreq.gui.ReqSpreadSheet')
                currentView.createAndRegisterLinkSet(reqSetDas);
                currentView.update();
            end

            appmgr.notify('WakeUI');
            currentView.setSelectedObject(reqSetDas);
        end

        function saveReqLinkSet(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            appmgr.notify('SleepUI');
            cleanup=onCleanup(@()appmgr.notify('WakeUI'));
            currentObj=getCurrentSelection(dialogSrc);
            appmgr.callbackHandler.saveReqLinkSet(currentObj);
        end

        function addReq(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            currentObj=getCurrentSelection(dialogSrc);
            if isa(currentObj,'slreq.das.Requirement')
                appmgr.callbackHandler.addRequirementAfter(currentObj);
            elseif isa(currentObj,'slreq.das.RequirementSet')
                appmgr.callbackHandler.addChildRequirement(currentObj);
            end

        end

        function delReqLink(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            currentObj=getCurrentSelection(dialogSrc);
            if isa(currentObj,'slreq.das.Requirement')...
                ||isa(currentObj,'slreq.das.Link')
                appmgr.callbackHandler.delReqLink(currentObj);
            end
        end

        function cutItem(dialogSrc)
            currentObj=getCurrentSelection(dialogSrc);
            slreq.app.CallbackHandler.cutItem(currentObj);
        end

        function copyItem(dialogSrc,dialog)
            currentObj=getCurrentSelection(dialogSrc);
            slreq.app.CallbackHandler.copyItem(currentObj);

            dialog.refresh;
        end

        function pasteItem(dialogSrc)
            currentObj=getCurrentSelection(dialogSrc);
            slreq.app.CallbackHandler.pasteItem(currentObj);
        end

        function promoteReq(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            currentObj=getCurrentSelection(dialogSrc);
            appmgr.callbackHandler.promote(currentObj);
        end

        function demoteReq(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            currentObj=getCurrentSelection(dialogSrc);
            appmgr.callbackHandler.demote(currentObj);
        end

        function addJustification(dialogSrc)
            appmgr=slreq.app.MainManager.getInstance();
            currentObj=getCurrentSelection(dialogSrc);
            appmgr.callbackHandler.addJustification(currentObj);
        end

        function switchView(dialogSrc)
            dialogSrc.view.switchView();
        end

        function viewChangedCallback(dialogSrc,value)

            cView=getCurrentView(dialogSrc);
            if cView.isReqView&&value==1
                cView.switchView();
            elseif~cView.isReqView&&value==0
                cView.switchView();
            end
            cView.update;
        end

        function closeSuggestion(dialogSrc,dlg,suggestionId)
            dlg.setVisible('views_suggestion_panel',0);
            dialogSrc.view.ShowSuggestion=false;



            if strcmp(suggestionId,'Slvnv:slreq:NoLinkDependencies')...
                ||strcmp(suggestionId,'Slvnv:slreq:NoLinkDependenciesMLPath')
                slreq.linkmgr.LinkSetManager.onBannerLinkClick('clear');
            end
        end

        function suggestionHelpLink(~,suggestionId)


            switch suggestionId
            case 'Slvnv:slreq:ChangeInfoSuggestion'
                helpview(fullfile(docroot,'slrequirements','helptargets.map'),'changeInformation');
            case{'Slvnv:slreq_import:SynchroError',...
                'Slvnv:slreq_import:SynchroSuggestionChanges',...
                'Slvnv:slreq_import:SynchroSuggestionNoChange'}
                helpview(fullfile(docroot,'slrequirements','ug','import-requirements-from-third-party-tools.html'));
            case 'Slvnv:slreq:NoLinkDependencies'
                helpview(fullfile(docroot,'slrequirements','helptargets.map'),'review_req_links');
            case 'Slvnv:slreq:NoLinkDependenciesMLPath'
                helpview(fullfile(docroot,'slrequirements','helptargets.map'),'review_req_links');
            case 'Slvnv:slreq:NotificationOnInformationalType'
                helpview(fullfile(docroot,'slrequirements','ug','requirement-types.html'));
            otherwise

                helpview(fullfile(docroot,'slrequirements','index.html'));
            end

        end


        function refresh(dialogSrc)

            cView=getCurrentView(dialogSrc);
            slreq.app.CallbackHandler.onRefreshAll(cView);
        end

    end
end


function currentObj=getCurrentSelection(dialogSrc)
    currentObj=[];
    cView=getCurrentView(dialogSrc);
    if~isempty(cView)
        currentObj=cView.getCurrentSelection;
    end
end

function cview=getCurrentView(dialogSrc)







    appmgr=slreq.app.MainManager.getInstance();
    if isa(dialogSrc,'slrequdd.viewmanager')
        cview=appmgr.requirementsEditor;
        appmgr.setLastOperatedView(cview);
    elseif isa(dialogSrc,'slreq.gui.ReqSpreadSheetMenu')

        cview=dialogSrc.view;
        appmgr.setLastOperatedView(cview);
    else

        cview=[];
    end
end

