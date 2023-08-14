classdef LinkSet<slreq.das.ReqLinkBase





    properties(Access=private)
eventListener
    end

    properties(Dependent)
        Domain;
        Artifact;
Dirty
        Label;
        Filepath;
        Description;
MATLABVersion
    end

    properties(Dependent,GetAccess=public)


        NumberOfChangedSource;
        NumberOfChangedDestination;

        ChangedSource;
        ChangedDestination;

        LinksWithChangedSource;
        LinksWithChangedDestination;
    end

    properties
        selectedCustomAttribute='';
    end

    methods
        function this=LinkSet(linkSet,parent,view,eventListener)
            this@slreq.das.ReqLinkBase(linkSet,parent);

            this.view=view;
            this.eventListener=eventListener;

            this.traverseLinks();
        end

        function update(this)
            this.traverseLinks();
        end

        function traverseLinks(this)



            wasEmpty=isempty(this.children);
            dataLinks=this.dataModelObj.getAllLinks();



            if isempty(this.view.viewManager)
                dispMode=slreq.gui.View.FULL;
            else
                dispMode=this.view.viewManager.getCurrentView.displayMode;
            end

            switch dispMode
            case slreq.gui.View.FULL
                for i=1:numel(dataLinks)
                    link=dataLinks(i);
                    dasLink=link.getDasObject();
                    if isempty(dasLink)
                        dasLink=slreq.das.Link(link,...
                        this,this.view,this.eventListener);
                        this.addChildObject(dasLink);
                    elseif wasEmpty
                        this.addChildObject(dasLink);
                    end
                end
            case{slreq.gui.View.FILTERED_ONLY,slreq.gui.View.FLAT_FILTERED_ONLY}
                for i=1:numel(dataLinks)
                    link=dataLinks(i);
                    dasLink=link.getDasObject();
                    if link.isFilteredIn()
                        if isempty(dasLink)
                            dasLink=slreq.das.Link(link,...
                            this,this.view,this.eventListener);
                            this.addChildObject(dasLink);
                        elseif wasEmpty
                            this.addChildObject(dasLink);
                        end
                    else
                        if~isempty(dasLink)&&numel(this.children)>=i...
                            &&this.children(i)==dasLink
                            this.children(i)=[];
                        else
                            if~isempty(dasLink)
                                delete(dasLink);
                                dataLinks(i).clearDasObject();
                            end
                        end
                    end
                end
            end
        end

        function linkDasObj=addLink(this,src,dst)


            if isa(dst,'slreq.das.Requirement')
                dst=dst.dataModelObj;
            elseif isa(dst,'slreq.data.Requirement')

            else
                error(message('Slvnv:slreq:InvalidLinkDst'));
            end
            this.eventListener.Enabled=false;
            linkObj=this.dataModelObj.addLink(src,dst);
            this.eventListener.Enabled=true;

            linkDasObj=slreq.das.Link(linkObj,this,this.view,this.eventListener);
            this.addChildObject(linkDasObj);
            mgr=slreq.app.MainManager.getInstance;
            mgr.updateRollupStatusLocally(dst);

            this.notifyViewChange(true);
        end

        function saveLinkSet(this,filepath)
            dataLinkSet=this.dataModelObj;
            if nargin>1




                slreq.saveLinks(dataLinkSet.artifact,filepath);
            else




                success=dataLinkSet.save();
                if success





                end
            end


            this.notifyViewChange(true);
        end

        function dirty=get.Dirty(this)
            dirty=this.dataModelObj.dirty;
        end

        function name=get.Domain(this)
            name=this.dataModelObj.domain;
        end

        function set.Domain(this,value)
            this.dataModelObj.domain=value;
        end

        function name=get.Artifact(this)
            name=this.dataModelObj.artifact;
        end

        function set.Artifact(this,value)
            this.dataModelObj.artifact=value;
        end

        function name=get.Description(this)
            name=this.dataModelObj.description;
        end

        function name=get.Filepath(this)
            name=this.dataModelObj.filepath;
        end

        function set.Description(this,value)
            this.dataModelObj.description=value;
        end

        function value=get.MATLABVersion(this)
            value=this.dataModelObj.MATLABVersion;
        end

        function value=get.NumberOfChangedSource(this)
            value=this.dataModelObj.numberOfChangedSource;
        end

        function value=get.NumberOfChangedDestination(this)
            value=this.dataModelObj.numberOfChangedDestination;
        end

        function value=get.ChangedSource(this)
            value=this.dataModelObj.changedSource;
        end

        function value=get.ChangedDestination(this)
            value=this.dataModelObj.changedDestination;
        end

        function addRegisteredRequirementSet(this,reqSetDas)
            rSet=reqSetDas.dataModelObj;
            this.dataModelObj.addRegisteredRequirementSet(rSet);
        end

        function rSets=getRegisteredRequirementSets(this)
            rSets=this.dataModelObj.getRegisteredRequirementSets();
        end

        function removeGhostIfNeeded(this)


            if strcmp(this.Domain,'linktype_rmi_simulink')&&dig.isProductInstalled('Simulink')
                [~,modelName]=fileparts(this.Artifact);
                if bdIsLoaded(modelName)
                    this.view.markupManager.removePendingGhost(modelName);
                end
            end
        end


        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.linkSet;
        end

        function label=getDisplayLabel(this)



            if slreq.utils.isEmbeddedLinkSet(this.Filepath)
                label=slreq.uri.getShortNameExt(this.Artifact);
            else
                label=slreq.uri.getShortNameExt(this.dataModelObj.filepath);
            end

            if this.Dirty
                label(end+1)='*';
            end
        end

        function items=getContextMenuItems(this,caller)
            cntxtMenuBuilder=slreq.gui.ContextMenuBuilder(caller);

            save.name=getString(message('Slvnv:slreq:Save'));
            save.tag='LinkSet:Save';
            save.enabled='on';
            save.callback='slreq.das.LinkSet.onSave()';
            items={save};

            mgr=slreq.app.MainManager.getInstance;
            cView=mgr.getCurrentView;
            isValidView=slreq.utils.isValidView(cView);
            if isValidView&&cView.displayChangeInformation
                item2.name=getString(message('Slvnv:slreq:ContextMenuLinkSetClearAllChangeIssues'));
                item2.tag='LinkSet:ContextMenuLinkSetClearAllChangeIssues';
                item2.callback='slreq.das.LinkSet.onClearOnChangeIssues';
                item2.enabled='on';
                items={save,item2};
            end

            if ishandle(caller)
                spObj=this.view.getCurrentSpreadSheetObject(caller);
                if~isempty(spObj)
                    if~spObj.isInspectorVisible

                        spInspectorMenu.name=getString(message('Slvnv:slreq:Inspect'));
                        spInspectorMenu.tag='LinkSet:Inspect';
                        spInspectorMenu.enabled='on';
                        spInspectorMenu.callback='slreq.gui.ReqSpreadSheet.openPropertyInspector';
                        items=[{spInspectorMenu},items];
                    end
                end
            end

            baseItems=this.getBaseContextMenuItems(caller);
            items=[items,baseItems];

            backlinksMenu.name=getString(message('Slvnv:slreq_backlinks:UpdateBacklinks'));
            backlinksMenu.tag='LinkSet:UpdateBacklinks';
            backlinksMenu.enabled='on';
            backlinksMenu.callback='slreq.das.LinkSet.onUpdateBacklinks()';
            items=[items,backlinksMenu];

            tracediagramMenu.name=getString(message('Slvnv:slreq_tracediagram:ContextMenu'));
            tracediagramMenu.tag='LinkSet:TraceDiagram';
            tracediagramMenu.enabled='on';
            tracediagramMenu.callback='slreq.internal.tracediagram.utils.generateTraceDiagram';
            items=[items,{tracediagramMenu}];

            enabledTagsOnMultiSelection={save.tag};
            items=cntxtMenuBuilder.adjustMenuEnabledStateBySelection(items,enabledTagsOnMultiSelection);
        end

        function menu=getContextMenu(this,nodes)%#ok<INUSD>
            items=this.getContextMenuItems('standalone');
            menu=this.view.requirementsEditor.createContextMenu(items);
        end

        function addChild(this,link)
            linkDasObj=slreq.das.Link(link,this,this.view,this.eventListener);
            this.addChildObject(linkDasObj);
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case 'Label'
                propValue=this.getDisplayLabel();
            case 'Description'
                propValue=this.Description;
            case 'Source'
                mgr=slreq.app.MainManager.getInstance;
                cView=mgr.getCurrentView;
                isViewValid=slreq.utils.isValidView(cView);
                if isViewValid&&cView.displayChangeInformation&&~mgr.isAnalysisDeferred
                    propValue=getString(message('Slvnv:slreq:ChangeInfoChangedSourceInLinkSet',...
                    this.NumberOfChangedSource,length(this.children)));
                else
                    propValue='';
                end
            case 'Destination'
                mgr=slreq.app.MainManager.getInstance;
                cView=mgr.getCurrentView;
                isViewValid=slreq.utils.isValidView(cView);
                if isViewValid&&cView.displayChangeInformation&&~mgr.isAnalysisDeferred
                    propValue=getString(message('Slvnv:slreq:ChangeInfoChangedDestinationInLinkSet',...
                    this.NumberOfChangedDestination,length(this.children)));
                else
                    propValue='';
                end
            otherwise
                propValue='';
            end
        end

        function setPropValue(this,propName,value)
            switch propName
            case 'Description'
                this.Description=value;
            end
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent',this);
            this.view.getCurrentView.updateToolbar();
        end

        function propValue=get.Label(this)
            propValue=this.getDisplayLabel();
        end

        function dlgstruct=getDialogSchema(this,dlg)

            displayProps={'Artifact','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','Description'};
            viewInfo=slreq.internal.gui.ViewForDDGDlg(this.view);

            if isempty(viewInfo.tag)
                dlgstruct=getDialogSchema@slreq.das.BaseObject(this,dlg);
                return;
            end

            if~slreq.utils.isEmbeddedLinkSet(this.Filepath)

                displayProps=[{'Filepath'},displayProps];
            end
            propGroup=slreq.gui.generateDDGStructForProperties(this,...
            displayProps,'togglepanel','LinkSetProperties',getString(message('Slvnv:slreq:Properties')));

            propGroup.Expand=slreq.gui.togglePanelHandler('get',propGroup.Tag,true);
            propGroup.ExpandCallback=@slreq.gui.togglePanelHandler;
            propGroup.RowSpan=[1,1];


            if viewInfo.displayChangeInformation
                changeInfoPanel=slreq.gui.ChangeInformationPanel.getDialogSchema(this);
                changeInfoPanel.RowSpan=[2,2];
                changeInfoPanel.ColSpan=[1,1];
            end
            customAttrPanel=slreq.gui.CustomAttributeRegistryPanel.getDialogSchema(this);
            customAttrPanel.RowSpan=[3,3];
            customAttrPanel.ColSpan=[1,1];

            spacer=struct('Type','text','Name','','RowSpan',[3,3]);

            dlgstruct.DialogTitle='';
            dlgstruct.EmbeddedButtonSet={''};

            enableOuterPanel=viewInfo.enableOuterPanel;
            outerPanel=struct('Type','panel','Tag','LinkSetOuterPanel','Enabled',enableOuterPanel);

            if viewInfo.displayChangeInformation
                outerPanel.Items={propGroup,customAttrPanel,changeInfoPanel,spacer};
                outerPanel.RowStretch=[0,0,0,1];
                outerPanel.LayoutGrid=[4,1];
            else
                outerPanel.Items={propGroup,customAttrPanel,spacer};
                outerPanel.RowStretch=[0,0,1];
                outerPanel.LayoutGrid=[3,1];
            end

            dlgstruct.Items={outerPanel};
            dlgstruct.DialogTag=viewInfo.tag;

            dlgstruct.DialogMode='Slim';


        end



        function getPropertyStyle(this,propname,propertyStyle)
            switch propname
            case 'Source'
                mgr=slreq.app.MainManager.getInstance;
                cView=mgr.getCurrentView;
                isViewValid=slreq.utils.isValidView(cView);
                propertyStyle.BackgroundColor=[1,1,1,1];
                if isViewValid&&cView.displayChangeInformation&&~mgr.isAnalysisDeferred
                    if this.NumberOfChangedSource>0
                        propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
                    end
                end

            case 'Destination'
                mgr=slreq.app.MainManager.getInstance;
                cView=mgr.getCurrentView;
                isViewValid=slreq.utils.isValidView(cView);
                propertyStyle.BackgroundColor=[1,1,1,1];
                if isViewValid&&cView.displayChangeInformation
                    if this.NumberOfChangedDestination>0
                        propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
                    end
                end
            end
        end


        function yesno=isEditablePropertyInInspector(this,propName)%#ok<INUSL>
            if strcmp(propName,'Description')
                yesno=true;
            else
                yesno=false;
            end
        end

        function clearAllChangeIssues(this,comments)%#ok<INUSL>

            appmgr=slreq.app.MainManager.getInstance();
            appmgr.notify('SleepUI');
            cleanup=onCleanup(@()appmgr.notify('WakeUI'));
            currentDasObj=appmgr.getCurrentObject();
            if~isempty(currentDasObj)&&isa(currentDasObj,'slreq.das.LinkSet')
                ctobj=appmgr.changeTracker;
                ctobj.clearAllChangeIssues(currentDasObj,comments);
                ctobj.updateViews();
            end
        end

        function stereotypes=getAllStereotypes(this)
            stereotypes=this.dataModelObj.getAllStereotypes();
        end

        function profProps=getAllProfileProperties(this)



            bUsePropertyName=true;
            stereotypes=this.dataModelObj.getAllStereotypes(bUsePropertyName);
            profProps=slreq.internal.ProfileTypeBase.getAllProperties(stereotypes);
        end
    end

    methods(Static)
        function onAddLink()
            uiMgr=slreq.app.MainManager.getInstance();
            reqEditor=uiMgr.requirementsEditor;
            currentDasObj=reqEditor.getCurrentSelection();
            if isa(currentDasObj,'slreq.das.RequirementSet')
                currentDasObj.addRequirement();
            end
        end


        function onSave()
            appmgr=slreq.app.MainManager.getInstance();
            currentDasObj=appmgr.getCurrentObject();
            appmgr.callbackHandler.saveReqLinkSet(currentDasObj);
        end

        function onUpdateBacklinks()
            appmgr=slreq.app.MainManager.getInstance();
            currentLinkSet=appmgr.getCurrentObject();
            dataLinkSet=currentLinkSet.dataModelObj;
            [numChecked,numAdded,numRemoved]=dataLinkSet.updateBacklinks();
            sourceName=slreq.uri.getShortNameExt(dataLinkSet.artifact);
            msgbox({...
            getString(message('Slvnv:slreq_backlinks:CheckedNLinksFromDoc',num2str(numChecked),sourceName)),...
            '',...
            getString(message('Slvnv:slreq_backlinks:NMissingLinksAdded',num2str(numAdded))),...
            getString(message('Slvnv:slreq_backlinks:NUnmatchedLinksRemoved',num2str(numRemoved)))},...
            getString(message('Slvnv:slreq_backlinks:BacklinksCheckedTitle')));
        end


        function onClearOnChangeIssues()

            appmgr=slreq.app.MainManager.getInstance();
            currentLinkSet=appmgr.getCurrentObject();
            slreq.gui.ChangeInformationPanel.clearAllChangeIssuesCallBack(currentLinkSet);
        end
    end

end
