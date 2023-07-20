classdef Link<slreq.das.ReqLinkBase




    properties(Access=private)
eventListener
    end

    properties(Dependent)
Description
Type
Source
Destination
Keywords
Rationale
SID
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
Comments
DestinationStruct
    end

    properties(GetAccess=public,SetAccess=private)
        Connector=slreq.das.Connector.empty;
        DiagramConnector=slreq.das.Connector.empty;
    end

    properties(Dependent)
Status
    end

    properties(Constant,Hidden)
        BuiltinProperties={'Label','Type','SID','Rationale','Description',...
        'Source','Destination','Keywords','Revision','CreatedBy','CreatedOn',...
        'ModifiedBy','ModifiedOn'};
        MAX_LABEL=50;
    end


    properties(Dependent,GetAccess=public)





        LinkedSourceRevision;
        LinkedSourceTimeStamp;
        LinkedDestinationRevision;
        LinkedDestinationTimeStamp;
        SourceChangeStatus;
        DestinationChangeStatus;
        CurrentSourceRevision;
        CurrentSourceTimeStamp;
        CurrentDestinationRevision;
        CurrentDestinationTimeStamp;
    end

    methods
        function tf=hasChangedSource(this)
            tf=this.SourceChangeStatus.isFail;
        end

        function tf=hasChangedDestination(this)
            tf=this.DestinationChangeStatus.isFail;
        end

        function tf=hasChangedIssue(this)
            tf=this.hasChangedSource||this.hasChangedDestination;
        end

        function getPropertyStyle(this,propname,propertyStyle)
            appmgr=this.view;
            cView=appmgr.getCurrentView;
            isViewValid=slreq.utils.isValidView(cView);
            switch propname
            case 'Source'



                if isViewValid&&cView.displayChangeInformation&&~appmgr.isAnalysisDeferred
                    propertyStyle.BackgroundColor=[1,1,1,1];
                    if this.hasChangedSource()
                        propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
                    end
                else
                    propertyStyle.BackgroundColor=[1,1,1,1];
                end
            case 'Destination'


                if isViewValid&&cView.displayChangeInformation
                    propertyStyle.BackgroundColor=[1,1,1,1];
                    if this.hasChangedDestination()
                        propertyStyle.BackgroundColor=slreq.app.ChangeTracker.BACKGROUND_COLOR_WITH_CHANGE_ISSUE;
                    end
                else
                    propertyStyle.BackgroundColor=[1,1,1,1];
                end

            otherwise

                propertyStyle.ForegroundColor=[0,0,0,1];
                propertyStyle.BackgroundColor=[1,1,1,1];
                if isViewValid
                    if~this.dataModelObj.isDestResolved||~this.dataModelObj.isSrcResolved
                        propertyStyle.ForegroundColor=[0.5,0.5,0.5,1];
                    end
                end
            end
        end

        function this=Link(link,parent,view,eventListener)
            this@slreq.das.ReqLinkBase(link,parent);

            this.view=view;
            this.eventListener=eventListener;
        end

        function lSet=getLinkSet(this)

            lSet=this.parent;
        end

        function id=get.Description(this)
            id=this.dataModelObj.description;
        end

        function id=get.Rationale(this)
            id=this.dataModelObj.rationale;
        end

        function set.Rationale(this,value)
            this.dataModelObj.rationale=value;
        end

        function set.Description(this,value)
            this.dataModelObj.description=value;
        end

        function set.Type(this,value)
            this.dataModelObj.setLinkTypeByForwardName(value);
            this.updateConnectors();
        end

        function value=get.Type(this)
            value=this.dataModelObj.getForwardTypeName();
        end

        function set.Source(this,value)
            this.dataModelObj.source=value;
        end

        function value=get.Source(this)
            value=this.dataModelObj.source;
        end

        function set.Destination(this,value)
            this.dataModelObj.dest=value;
        end

        function value=get.Destination(this)
            value=this.dataModelObj.dest;
        end

        function value=get.DestinationStruct(this)
            value=this.dataModelObj.destStruct;
        end

        function id=get.SID(this)

            id=num2str(this.dataModelObj.sid);
        end

        function set.Keywords(this,value)
            this.dataModelObj.keywords=value;
        end

        function value=get.Keywords(this)
            value='';
            list=this.dataModelObj.keywords;
            for m=1:length(list)
                if m==1
                    value=list{m};
                else
                    value=sprintf('%s, %s',value,list{m});
                end
            end
        end

        function remove(this)

            this.Connector.delete;
            this.DiagramConnector.delete;
            this.getLinkSet().removeGhostIfNeeded();


            remove@slreq.das.BaseObject(this);





        end

        function commentDas=addComment(this)
            commentData=this.dataModelObj.addComment();

            commentDas=slreq.das.Comment(commentData);
        end

        function value=get.Comments(this)
            value=slreq.das.Comment.empty;
            comments=this.dataModelObj.comments;
            for n=1:length(comments)

                dataComment=comments(n);

                dasComment=dataComment.getDasObject();
                if~isempty(dasComment)
                    value(n)=dasComment;
                else




                    value(n)=slreq.das.Comment(dataComment);

                end
            end
        end

        function dasConnector=showConnector(this,isDiagram)
            dasConnector=this.view.markupManager.showConnector(this,isDiagram);
            if isDiagram&&~isempty(dasConnector)
                this.DiagramConnector=dasConnector;
            else
                this.Connector=dasConnector;
            end
        end

        function hideConnectors(this,isDiagram)
            if isDiagram
                if~isempty(this.DiagramConnector)
                    this.DiagramConnector.delete;
                    this.DiagramConnector=slreq.das.Connector.empty;
                end
            else
                if~isempty(this.Connector)
                    this.Connector.delete;
                    this.Connector=slreq.das.Connector.empty;
                end
            end
        end

        function destoryConnectorFromSystem(this,ownerH)
            if~isempty(this.Connector)
                if this.Connector.isInSystem(ownerH)
                    this.Connector.isVisible=false;
                    this.Connector.delete;
                    this.Connector=slreq.das.Connector.empty;
                end
            end
            if~isempty(this.DiagramConnector)
                if this.DiagramConnector.isInSystem(ownerH)
                    this.DiagramConnector.isVisible=false;
                    this.DiagramConnector.delete;
                    this.DiagramConnector=slreq.das.Connector.empty;
                end
            end
        end

        function destroyConnector(this,isDiagram)
            if isDiagram
                if~isempty(this.DiagramConnector)
                    this.DiagramConnector.isVisible=false;
                    this.DiagramConnector.delete;
                    this.DiagramConnector=slreq.das.Connector.empty;
                end
            else
                if~isempty(this.Connector)
                    this.Connector.isVisible=false;
                    this.Connector.delete;
                    this.Connector=slreq.das.Connector.empty;
                end
            end
        end

        function restoreConnectors(this)
            [this.Connector,this.DiagramConnector]=this.view.markupManager.restoreConnectors(this);
        end

        function updateConnectors(this)
            if~isempty(this.Connector)
                this.Connector.update();
            end
            if~isempty(this.DiagramConnector)
                this.DiagramConnector.update();
            end
        end

        function addConnector(this,conn,isDiagram)
            if isDiagram
                this.DiagramConnector=conn;
            else
                this.Connector=conn;
            end
        end


        function icon=getDisplayIcon(this)
            iconRegistry=slreq.gui.IconRegistry.instance;
            icon=iconRegistry.invalidLink;

            if~this.dataModelObj.isDestResolved()
                return;
            end
            if~this.dataModelObj.isSrcResolved()
                return;
            end
            icon=iconRegistry.validLink;
        end

        function label=getDisplayLabel(this)
            label=this.dataModelObj.getDisplayLabel(slreq.das.Link.MAX_LABEL);
        end

        function propValue=getPropValue(this,propName)
            switch propName
            case 'Label'
                propValue=this.getDisplayLabel();
            case 'Description'
                propValue=this.Description;
            case 'Rationale'
                propValue=this.Rationale;
            case 'Type'

                propValue=this.dataModelObj.getForwardTypeName();
            case 'Source'

                [srcAdapter,artifactUri,artifactId]=this.dataModelObj.getSrcAdapter();
                propValue=rmiut.plainToHtml(srcAdapter.getSummary(artifactUri,artifactId));
            case 'Destination'
                [dstAdapter,artifactUri,artifactId]=this.dataModelObj.getDestAdapter();
                propValue=rmiut.plainToHtml(dstAdapter.getSummary(artifactUri,artifactId));
            case 'SID'
                propValue=num2str(this.SID);
            case 'CreatedOn'

                propValue=slreq.utils.getDateStr(this.dataModelObj.createdOn);
            case 'CreatedBy'
                propValue=this.dataModelObj.createdBy;
            case 'ModifiedOn'

                propValue=slreq.utils.getDateStr(this.dataModelObj.modifiedOn);
            case 'ModifiedBy'
                propValue=this.dataModelObj.modifiedBy;
            case 'Revision'
                propValue=num2str(this.dataModelObj.revision);
            case 'Keywords'
                propValue=this.Keywords;
            otherwise

                propName=slreq.utils.customAttributeNamesHash('lookup',propName);

                isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
                this.getLinkSet.dataModelObj,propName);
                if isStereotype
                    attrValue=this.dataModelObj.getStereotypeAttr(propName,false);
                else
                    attrValue=this.dataModelObj.getAttribute(propName,false);
                end

                if ischar(attrValue)
                    propValue=attrValue;
                elseif isdatetime(attrValue)

                    propValue=slreq.utils.getDateStr(attrValue);
                elseif isnumeric(attrValue)||islogical(attrValue)
                    propValue=num2str(attrValue);
                end
            end
        end

        function setPropValue(this,propName,propValue)
            switch propName
            case 'Description'
                this.Description=propValue;
            case 'Type'

                this.Type=propValue;
            case 'Source'
                this.Source=propValue;
            case 'Destination'
                this.Destination=propValue;
            case 'Rationale'
                this.Rationale=propValue;
            case 'Keywords'
                this.Keywords=propValue;
            otherwise


                propName=slreq.utils.customAttributeNamesHash('lookup',propName);
                isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
                this.getLinkSet.dataModelObj,propName);
                if isStereotype
                    this.dataModelObj.setStereotypeAttr(propName,propValue);
                else
                    this.dataModelObj.setAttributeByChar(propName,propValue);
                end
            end
            mgr=slreq.app.MainManager.getInstance;
            mgr.refreshUI(this);
            this.view.getCurrentView.updateToolbar();

        end


        function dtype=getPropDataType(this,propName)
            dtype='string';
            if any(strcmp(this.BuiltinProperties,propName))
                dtype='ustring';
                return;
            end

            attrRegistries=slreq.data.ReqData.getInstance.getCustomAttributeRegistries(this.dataModelObj.getSet);


            propName=slreq.utils.customAttributeNamesHash('lookup',propName);

            if slreq.internal.ProfileLinkType.isProfileStereotype(this.getLinkSet.dataModelObj,propName)
                type=slreq.internal.ProfileReqType.getStereotypeAttrType(propName);

                MAP_TO_SAME_TYPE={'double','int32','uint32','uint64'};
                switch type
                case MAP_TO_SAME_TYPE
                    dtype=type;
                case 'boolean'
                    dtype='bool';
                otherwise
                    dtype='ustring';
                end
            else
                attrReg=attrRegistries.getByKey(propName);
                if~isempty(attrReg)
                    switch attrReg.typeName
                    case slreq.datamodel.AttributeRegType.Combobox
                        dtype='string';
                    case slreq.datamodel.AttributeRegType.Checkbox
                        dtype='bool';

                    case{slreq.datamodel.AttributeRegType.Edit,slreq.datamodel.AttributeRegType.DateTime}
                        dtype='ustring';
                    end
                end
            end
        end

        function dlgstruct=getDialogSchema(this,dlg)
            viewInfo=slreq.internal.gui.ViewForDDGDlg(this.view);

            if isempty(viewInfo.tag)
                dlgstruct=getDialogSchema@slreq.das.BaseObject(this,dlg);
                return;
            end

            caller=viewInfo.caller;
            linkPanel=struct('Type','togglepanel','Name',getString(message('Slvnv:slreq:Properties')),'LayoutGrid',[4,4]);
            linkPanel.Tag='LinkDetails';
            linkPanel.Expand=slreq.gui.togglePanelHandler('get',linkPanel.Tag,true);
            linkPanel.ExpandCallback=@slreq.gui.togglePanelHandler;

            srcTypeDstGroup.LayoutGrid=[6,5];
            srcTypeDstGroup.ColSpan=[1,3];
            srcTypeDstGroup.ColStretch=[0,0,0,0,1];
            srcTypeDstGroup.RowSpan=[1,1];
            srcTypeDstGroup.Type='panel';

            srcTitle=struct('Type','text',...
            'RowSpan',[1,1],'ColSpan',[1,1],...
            'Tag','srcTitle','Name',getString(message('Slvnv:slreq:SourceColon')));


            dataLink=this.dataModelObj;
            linkSource=this.Source;
            [srcIconPath,srcStr,srcTooltip]=dataLink.getSrcIconSummaryTooltip();
            srcIcon=struct('Type','image',...
            'RowSpan',[1,1],'ColSpan',[2,2],...
            'Tag','srcImage','FilePath',srcIconPath);

            srcString=rmiut.plainToHtml(srcStr);
            srcHyperlink=struct('Type','hyperlink',...
            'RowSpan',[1,1],'ColSpan',[3,4],...
            'Tag','srcHyperlink','Name',srcString,'ToolTip',srcTooltip);
            srcHyperlink.MatlabMethod='slreq.gui.LinkTargetUIProvider.clickAction';
            srcHyperlink.MatlabArgs={linkSource,caller};

            typeTitle=struct('Type','text',...
            'RowSpan',[2,2],'ColSpan',[1,1],...
            'Tag','relTitle','Name',getString(message('Slvnv:slreq:TypeColon')));


            typeStr=struct('Type','combobox',...
            'RowSpan',[2,2],...
            'Tag','Type',...
            'ColSpan',[2,3]);
            typeStr.Entries=slreq.app.LinkTypeManager.getAllForwardDisplayNames(this.parent);
            typeStr.Mode=true;
            typeStr.ObjectProperty='Type';

            dstTitle=struct('Type','text',...
            'RowSpan',[3,3],'ColSpan',[1,1],...
            'Tag','dstTitle','Name',getString(message('Slvnv:slreq:DestinationColon')));

            [dstIconPath,dstStr,dstTooltip]=dataLink.getDestIconSummaryTooltip();

            dstIcon=struct('Type','image',...
            'RowSpan',[3,3],'ColSpan',[2,2],...
            'Tag','dstImage','FilePath',dstIconPath);

            dstHyperlink=struct('Type','hyperlink',...
            'RowSpan',[3,3],'ColSpan',[3,4],...
            'Tag','dstHyperlink','Name',dstStr,'ToolTip',dstTooltip);
            dstHyperlink.MatlabMethod='slreq.gui.LinkTargetUIProvider.clickAction';

            if isempty(this.Destination)
                dstHyperlink.MatlabArgs={this.DestinationStruct,caller,linkSource.artifactUri};
            else
                dstHyperlink.MatlabArgs={this.Destination,caller,linkSource.artifactUri};
            end

            descEdit=struct('Type','editarea',...
            'Mode',true,'ObjectProperty','Description',...
            'Tag','Description');

            srcTypeDstGroup.Items={srcTitle,srcIcon,srcHyperlink...
            ,typeTitle,typeStr...
            ,dstTitle,dstIcon,dstHyperlink};

            tabcontainer=struct('Type','tab','Name','tab','RowSpan',[2,2],'ColSpan',[1,3]);

            rationaleEditor=struct('Type','editarea',...
            'Mode',true,'ObjectProperty','Rationale',...
            'Tag','Rationale');
            rationaleEditor.Visible=true;
            rationaleEditor.AutoFormatting=true;
            rationaleEditor.Graphical=true;
            rationaleEditor.WordWrap=true;
            rationaleEditor.FontPointSize=10;

            tab1.Name=getString(message('Slvnv:slreq:Description'));
            tab1.Items={descEdit};
            tab2.Name=getString(message('Slvnv:slreq:Rationale'));
            tab2.Items={rationaleEditor};
            tabcontainer.Tabs={tab1,tab2};

            keywordsEdit=struct('Type','edit','Name',getString(message('Slvnv:slreq:KeywordsColon')),...
            'ObjectProperty','Keywords','Mode',1,'Tag','KeyWords','Graphical',true,'RowSpan',[3,3],'ColSpan',[1,1]);

            modifiedInfo=slreq.gui.generateDDGStructForProperties(this,...
            {'SID','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn'},...
            'togglepanel','LinkAttributes',getString(message('Slvnv:slreq:RevisionInfoColon')),'',false);
            modifiedInfo.RowSpan=[4,4];
            modifiedInfo.ColSpan=[1,3];

            linkPanel.Items={...
            srcTypeDstGroup,tabcontainer,keywordsEdit,modifiedInfo};

            nRow=1;
            linkPanel.RowSpan=[nRow,nRow];
            nRow=nRow+1;
            linkPanel.ColSpan=[1,1];

            enableOuterPanel=viewInfo.enableOuterPanel;
            outerPanel=struct('Type','panel','Tag','LinkOuterPanel','Enabled',enableOuterPanel);
            outerPanel.Items={linkPanel};

            rdata=slreq.data.ReqData.getInstance();
            attrRegistries=rdata.getCustomAttributeRegistries(this.dataModelObj.getLinkSet);
            if attrRegistries.Size>0
                customAttrPanel=slreq.gui.CustomAttributeItemPanel.getDialogSchema(this,attrRegistries,nRow,'LinkCustomAttrRegs');
                nRow=nRow+1;
                outerPanel.Items{end+1}=customAttrPanel;
            end

            stereotypeAttPanel=slreq.gui.StereotypeAttributeItemPanel.getDialogSchema(this,nRow,'LinkStereoType');
            if~isempty(stereotypeAttPanel)
                nRow=nRow+1;
                outerPanel.Items{end+1}=stereotypeAttPanel;
            end

            if viewInfo.displayComment
                commentPanel=slreq.gui.CommentDetails.getDialogSchema(this);
                commentPanel.RowSpan=[nRow,nRow];
                commentPanel.ColSpan=[1,1];
                outerPanel.Items{end+1}=commentPanel;
                nRow=nRow+1;
            end

            if viewInfo.displayChangeInformation
                changeInfoPanel=slreq.gui.ChangeInformationPanel.getDialogSchema(this);
                changeInfoPanel.RowSpan=[nRow,nRow];
                changeInfoPanel.ColSpan=[1,1];
                outerPanel.Items{end+1}=changeInfoPanel;
                nRow=nRow+1;
            end

            blankArea=struct('Type','text','RowSpan',[nRow,nRow],'ColSpan',[1,1],'Name','');

            dlgstruct.DialogTag=viewInfo.tag;

            outerPanel.LayoutGrid=[nRow,1];
            outerPanel.RowStretch=zeros(1,nRow);
            outerPanel.RowStretch(end)=1;

            dlgstruct.DialogTitle='';
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.DialogMode='Slim';

            outerPanel.Items{end+1}=blankArea;
            dlgstruct.Items={outerPanel};




        end

        function name=getObjectType(this)

            labelToShow=this.Description;
            name=getString(message('Slvnv:slreq:LinkColon',labelToShow));
        end

        function items=getContextMenuItems(this,caller)
            cntxtMenuBuilder=slreq.gui.ContextMenuBuilder(caller);
            del.name=getString(message('Slvnv:slreq:Delete'));
            del.tag='Link:Delete';

            cView=slreq.utils.getCallerView(caller,true);

            editorSelection=cView.getCurrentSelection;
            isMultiSelection=numel(editorSelection)>1;
            if isMultiSelection
                isSiblings=editorSelection.isSiblings();
            else
                isSiblings=true;
            end

            del.enabled='on';
            if~isSiblings
                del.enabled='off';
            else
                del.enabled='on';
            end
            del.callback='slreq.das.Link.onDeleteLink()';
            items={del};

            clearIssue.name=getString(message('Slvnv:slreq:ChangeInfoPanelClear'));
            clearIssue.tag='Link:ClearIssues';
            clearIssue.callback='slreq.das.Link.onClearingChangeIssue()';
            hasChangeIssue=false;
            for n=1:length(editorSelection)
                if editorSelection(n).hasChangedIssue
                    hasChangeIssue=true;
                    break;
                end
            end
            if hasChangeIssue
                clearIssue.enabled='on';
            else
                clearIssue.enabled='off';
            end
            items{end+1}=clearIssue;



            if ishandle(caller)
                spObj=this.view.getCurrentSpreadSheetObject(caller);
                if~isempty(spObj)
                    if~spObj.isInspectorVisible

                        spInspectorMenu.name=getString(message('Slvnv:slreq:Inspect'));
                        spInspectorMenu.tag='Link:Inspect';
                        spInspectorMenu.enabled='on';
                        spInspectorMenu.callback='slreq.gui.ReqSpreadSheet.openPropertyInspector';
                        items=[{spInspectorMenu},items];
                    end
                end
            end

            baseItems=this.getBaseContextMenuItems(caller);
            items=[items,baseItems];

            tracediagramMenu.name=getString(message('Slvnv:slreq_tracediagram:ContextMenu'));
            tracediagramMenu.tag='ReqLink:TraceDiagram';
            tracediagramMenu.enabled='on';
            tracediagramMenu.callback='slreq.internal.tracediagram.utils.generateTraceDiagram';
            items=[items,{tracediagramMenu}];

            enabledTagsOnMultiSelection={del.tag,clearIssue.tag};
            items=cntxtMenuBuilder.adjustMenuEnabledStateBySelection(items,enabledTagsOnMultiSelection);
        end

        function menu=getContextMenu(this,nodes)%#ok<INUSD>
            items=this.getContextMenuItems('standalone');
            menu=this.view.requirementsEditor.createContextMenu(items);
        end

        function selections=resolveComponentSelection(this)












            selections={};
            dataLink=this.dataModelObj;

            try

                linkSource=dataLink.source;
                if strcmp(linkSource.domain,'linktype_rmi_simulink')
                    srcObj=resolveSimulinkObjBySID(linkSource.getSID);
                    if~isempty(srcObj)
                        selections{end+1}=srcObj;
                    elseif sysarch.isZCElement(linkSource.id)
                        [~,~,modelHandle]=slreq.utils.DAStudioHelper.getCurrentBDHandle();
                        modelName=get_param(modelHandle,'Name');
                        portHandles=sysarch.getPortHandleForReqHighlighting(linkSource.id,modelName);
                        for i=1:numel(portHandles)
                            selections=[selections,{get_param(portHandles(i),'Object')}];
                        end
                    end
                end
            catch ex %#ok<NASGU>


            end

            dest=dataLink.dest;
            if~isempty(dest)
                try
                    if strcmp(dest.domain,'linktype_rmi_slreq')
                        dasReq=dest.getDasObject();
                        if~isempty(dasReq)
                            selections{end+1}=dasReq;
                        end
                        if~isempty(this.Connector)
                            selections{end+1}=this.Connector.connectorItem;
                            selections{end+1}=this.Connector.Markup.markupItem;
                        end
                        if~isempty(this.DiagramConnector)
                            selections{end+1}=this.DiagramConnector.connectorItem;
                            selections{end+1}=this.DiagramConnector.Markup.markupItem;
                        end
                    end
                catch ex %#ok<NASGU>


                end
            end
            function item=resolveSimulinkObjBySID(sid)
                item=[];
                try
                    if rmisl.isHarnessIdString(sid)
                        [~,srcHandle]=rmisl.resolveObjInHarness(sid);
                    else
                        srcHandle=Simulink.ID.getHandle(sid);
                    end
                    if isa(srcHandle,'Stateflow.Object')
                        item=srcHandle;
                    else
                        item=get_param(sid,'Object');
                    end
                catch ME %#ok<NASGU>


                end
            end
        end




        function out=get.LinkedSourceRevision(this)
            out=this.dataModelObj.linkedSourceRevision;
        end


        function out=get.LinkedSourceTimeStamp(this)
            out=this.dataModelObj.linkedSourceTimeStamp;
        end


        function out=get.CurrentSourceRevision(this)
            out=this.dataModelObj.currentSourceRevision;
        end


        function out=get.CurrentSourceTimeStamp(this)
            out=this.dataModelObj.currentSourceTimeStamp;
        end


        function out=get.CurrentDestinationRevision(this)
            out=this.dataModelObj.currentDestinationRevision;
        end


        function out=get.CurrentDestinationTimeStamp(this)
            out=this.dataModelObj.currentDestinationTimeStamp;
        end


        function out=get.LinkedDestinationRevision(this)
            out=this.dataModelObj.linkedDestinationRevision;
        end


        function out=get.LinkedDestinationTimeStamp(this)
            out=this.dataModelObj.linkedDestinationTimeStamp;
        end


        function out=get.SourceChangeStatus(this)
            out=this.dataModelObj.sourceChangeStatus;
        end


        function out=get.DestinationChangeStatus(this)
            out=this.dataModelObj.destinationChangeStatus;
        end



        function clearLinkedSourceIssue(this,comment)




            appmgr=slreq.app.MainManager.getInstance();
            ctmgr=appmgr.changeTracker;
            ctmgr.clearLinkedSourceIssue(this,comment);



            ctmgr.updateViews();
        end


        function clearLinkedDestinationIssue(this,comment)







            appmgr=slreq.app.MainManager.getInstance();
            ctmgr=appmgr.changeTracker;
            ctmgr.clearLinkedDestinationIssue(this,comment);



            ctmgr.updateViews();
        end
    end

    methods(Access=protected)
        function objs=removeDataObject(this)
            linkSet=this.dataModelObj.getLinkSet();

            this.eventListener.Enabled=false;

            objs=linkSet.removeLink(this.dataModelObj);





            this.eventListener.Enabled=true;

        end
    end

    methods(Static)




        function onDeleteLink()
            appmgr=slreq.app.MainManager.getInstance();
            currentLink=appmgr.getCurrentObject();
            appmgr.callbackHandler.delReqLink(currentLink);
        end

        function onClearingChangeIssue()

            appmgr=slreq.app.MainManager.getInstance();
            currentLinks=appmgr.getCurrentObject();
            idx=[];
            for n=1:length(currentLinks)

                if currentLinks(n).hasChangedIssue
                    idx(end+1)=n;%#ok<AGROW>
                end
            end
            if isempty(idx)


                return;
            end
            linksWithChangeIssue=currentLinks(idx);
            if numel(linksWithChangeIssue)>1



                fieldWithChangeIssue='';
            elseif linksWithChangeIssue.hasChangedSource
                fieldWithChangeIssue='source';
            elseif linksWithChangeIssue.hasChangedDestination
                fieldWithChangeIssue='destination';
            else
                assert(false,'hasChangedSource or hasChangedDestination should be true here')
            end
            dlg=slreq.gui.ClearChangeDialog(linksWithChangeIssue,fieldWithChangeIssue);
            dlg.show();
        end
    end
end
