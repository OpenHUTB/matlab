classdef LinkSetNotLoaded<slreq.das.ReqLinkBase






    properties(Access=private)
eventListener
    end

    properties
        Domain;
        Artifact;
        Dirty;
        Label;
        Filepath;
        Description;
        MATLABVersion;

        NumberOfChangedSource;
        NumberOfChangedDestination;
        ChangedDestination;
        ChangedSource;
    end

    methods
        function this=LinkSetNotLoaded(parent,view,eventListener)


            this@slreq.das.ReqLinkBase();
            this.parent=parent;

            this.view=view;
            this.eventListener=eventListener;
            this.NumberOfChangedDestination=0;
            this.NumberOfChangedSource=0;
            this.ChangedSource='';
            this.ChangedDestination='';
            this.Dirty=false;
            this.Domain='';
        end



        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.linkSet;
        end

        function label=getDisplayLabel(this)
            label=slreq.uri.getShortNameExt(this.Filepath);
        end


        function items=getContextMenuItems(~,~)
            items=[];
        end

        function menu=getContextMenu(this,nodes)%#ok<INUSD>
            menu=[];
        end


        function propValue=getPropValue(this,propName)
            switch propName
            case 'Label'
                propValue=this.getDisplayLabel();
            case 'Description'
                label=slreq.uri.getShortNameExt(this.Filepath);
                propValue=getString(message('Slvnv:slreq:LinksetProfileOutdated',label));
            case 'Artifact'
                propValue=this.Artifact;
            otherwise
                propValue='';
            end
        end

        function setPropValue(~,~,~)

        end

        function tf=hasChangedIssue(~)
            tf=false;
        end

        function propValue=get.Label(this)
            propValue=this.getDisplayLabel();
        end



        function dlgstruct=getDialogSchema(this,dlg)

            displayProps={'Artifact','Description'};
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

            spacer=struct('Type','text','Name','','RowSpan',[3,3]);

            dlgstruct.DialogTitle='';
            dlgstruct.EmbeddedButtonSet={''};

            enableOuterPanel=viewInfo.enableOuterPanel;
            outerPanel=struct('Type','panel','Tag','LinkSetOuterPanel','Enabled',enableOuterPanel);

            buttonPanel=struct('Type','panel','Tag','LinkSetCloseWaring','Enabled',true);
            buttonPanel.LayoutGrid=[1,4];
            buttonPanel.ColStretch=[1,0,0,0];


            detailsBtn.Type='pushbutton';
            detailsBtn.Name='Details';
            detailsBtn.Tag='';
            detailsBtn.ToolTip='Details';
            detailsBtn.MethodArgs={'%dialog'};
            detailsBtn.ArgDataTypes={'handle'};
            detailsBtn.ObjectMethod='showDetails';
            detailsBtn.ColSpan=[3,3];

            closeButton.Type='pushbutton';
            closeButton.Name='Close';
            closeButton.Tag='';
            closeButton.ToolTip='Close';
            closeButton.MethodArgs={'%dialog'};
            closeButton.ArgDataTypes={'handle'};
            closeButton.ObjectMethod='closeEmptyLinkSet';
            closeButton.ColSpan=[4,4];

            spaceField=struct('Type','text','Name','','ColSpan',[1,2]);
            buttonPanel.Items={spaceField,detailsBtn,closeButton};

            outerPanel.Items={propGroup,buttonPanel,spacer};
            outerPanel.RowStretch=[0,0,1];
            outerPanel.LayoutGrid=[3,1];

            dlgstruct.Items={outerPanel};
            dlgstruct.DialogTag=viewInfo.tag;

            dlgstruct.DialogMode='Slim';
        end

        function showDetails(this,~)
            mdl=mf.zero.Model();
            [prfChecker,nameSp]=slreq.internal.ProfileLinkType.areProfilesOutdated(this.Filepath,mdl);
            dlg=slreq.gui.OutdatedProfileDialog(this.Filepath,prfChecker,nameSp,mdl,this,[]);
            DAStudio.Dialog(dlg);
        end

        function resolveProfileLoadLinkSet(this)

            index=this.parent.findObjectIndex(this);
            if index>0
                this.parent.children(index)=[];
            end

            reqData=slreq.data.ReqData.getInstance();
            resolveProfile=true;
            reqData.loadLinkSet(this.Artifact,this.Filepath,this.Artifact,resolveProfile);

            this.parent.view.clearSelectedObjectsUponDeletion(this,true);
            localDataRefreshed=true;
            this.parent.notifyViewChange(localDataRefreshed);
        end

        function closeEmptyLinkSet(this,~)
            index=this.parent.findObjectIndex(this);
            if index>0
                this.parent.children(index)=[];
            end

            this.parent.view.clearSelectedObjectsUponDeletion(this,true);
            localDataRefreshed=true;
            this.parent.notifyViewChange(localDataRefreshed);
        end

        function getPropertyStyle(~,~,propertyStyle)


            propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
        end

        function yesno=isEditablePropertyInInspector(this,propName)%#ok<INUSL>
            yesno=false;
        end

        function clearAllChangeIssues(this,comments)%#ok<INUSL>

        end

        function stereotypes=getAllStereotypes(~)
            stereotypes=[];
        end


        function update(~)

        end

        function traverseLinks(~)

        end

        function linkDasObj=addLink(~,~,~)

            linkDasObj=[];
            return;
        end

        function saveLinkSet(~,~)

            return;
        end

        function dirty=get.Dirty(~)
            dirty=false;
        end

        function name=get.Domain(this)
            name=this.Domain;
        end

        function set.Domain(~,~)

        end

        function name=get.Artifact(this)
            name=this.Artifact;
        end

        function set.Artifact(this,artifact)
            this.Artifact=artifact;
        end

        function name=get.Description(this)
            name=this.Description;
        end

        function name=get.Filepath(this)
            name=this.Filepath;
        end

        function set.Description(~,~)

        end

        function value=get.MATLABVersion(this)
            value=this.MATLABVersion;
        end

        function value=get.NumberOfChangedSource(this)
            value=this.NumberOfChangedSource;
        end

        function value=get.NumberOfChangedDestination(this)
            value=this.NumberOfChangedDestination;
        end

        function value=get.ChangedSource(this)
            value=this.ChangedSource;
        end

        function value=get.ChangedDestination(this)
            value=this.ChangedDestination;
        end

        function addRegisteredRequirementSet(~,~)

        end

        function rSets=getRegisteredRequirementSets(~)
            rSets=[];
        end

    end
end