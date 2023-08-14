classdef Requirement<slreq.das.ReqLinkBase&slreq.das.RollupStatus





    properties
        readOnlyProperties={'Index','SID','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','SynchronizedOn'};
        readOnly=false;
        RequirementSet=slreq.das.RequirementSet.empty;
    end
    properties(Hidden)
        LastRatiEditorType;
        LastDescEditorType;

    end

    properties(Access=public)
eventListener
    end

    properties(Dependent)
CustomID
Summary
Description
Rationale
Keywords
Domain
isExternal
Markups
isHierarchicalJustification
Type
        PreImportFcn;
        PostImportFcn;
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
Index
Id
SID
SynchronizedOn
IsLocked
Comments
    end

    properties(Access={?slreq.das.RollupStatus})
        iconPath char;
    end

    properties(Access={?slreq.gui.ReqSpreadSheet,?slreq.gui.RequirementsEditor,?slreq.internal.gui.Editor})
        mimeData;
    end

    properties(Access=?slreq.gui.RequirementDetails)
        DescriptionEditorType;
        RationaleEditorType;
    end

    properties(Dependent)
propsTop
propsBot
    end

    properties(Constant,Hidden)
        BuiltinProperties={'Type','Index','CustomID','SID','Summary','Description','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn','SynchronizedOn','isHierarchicalJustification'};
        builtinTypes={'double','single','int8','int16','int32','uint8','uint16','uint32','logical','char','string'};
        mimeTypes=containers.Map({'web','glue'},{'application/mw-web','application/mw-glue-markup'});
    end

    methods(Access=public)

        function createChildren(this)
            children=this.getChildren();
            for i=1:numel(children)
                children(i).createChildren;
            end
        end

    end

    methods
        function this=Requirement()
            this@slreq.das.ReqLinkBase();
            this.childrenCreated=false;
        end

        function ch=getChildren(this,~)
            if~this.childrenCreated
                this.childrenCreated=true;
                if isempty(this.children)
                    childReqs=this.dataModelObj.children;
                    switch this.view.viewManager.getCurrentView.displayMode
                    case slreq.gui.View.FULL
                        for i=1:numel(childReqs)
                            reqDasObj=slreq.das.Requirement();
                            reqDasObj.postConstructorProcess(childReqs(i),this,this.view,this.eventListener);
                            this.addChildObject(reqDasObj);
                        end
                    case slreq.gui.View.FULL_FLAT

                    case slreq.gui.View.FILTERED_ONLY
                        for i=1:numel(childReqs)
                            if childReqs(i).isFilteredIn()||childReqs(i).isFilteredParent()
                                reqDasObj=slreq.das.Requirement();
                                reqDasObj.postConstructorProcess(childReqs(i),this,this.view,this.eventListener);
                                this.addChildObject(reqDasObj);
                            end
                        end
                    case slreq.gui.View.FLAT_FILTERED_ONLY
                    end
                end
            end

            ch=this.children;
        end

        function ch=getHierarchicalChildren(this)
            ch=this.getChildren(this);
        end

        function delete(this)

        end
        postConstructorProcess(this,req,parent,view,eventListener)

        reqDasObj=addRequirementAfter(this)

        reqDasObj=addChildRequirement(this)

        justifObj=addChildJustification(this)

        justifObj=addJustificationAfter(this)

        tf=isJustification(this)

        [tf,isHierarchical]=isJustifiedFor(this,justificationType)

        function tf=isImportRootItem(this)
            tf=this.dataModelObj.isImportRootItem();
        end

        function tf=get.isHierarchicalJustification(this)
            tf=this.dataModelObj.isHierarchicalJustification();
        end

        function set.isHierarchicalJustification(this,tf)
            this.dataModelObj.isHierarchicalJustification=tf;
        end

        function typeName=get.Type(this)
            if isempty(this.dataModelObj)
                typeName='';
            else
                typeName=this.dataModelObj.getDisplayTypeName;
            end
        end

        function set.Type(this,displayName)


            this.dataModelObj.setReqTypeByDisplayName(displayName);

            isStereotype=slreq.internal.ProfileReqType.isProfileStereotype(...
            this.RequirementSet.dataModelObj,this.Type);

            if isStereotype
                isInformational=slreq.internal.ProfileReqType.isa(this.Type,slreq.custom.RequirementType.Informational);
            else
                isInformational=slreq.app.RequirementTypeManager.isa(this.dataModelObj.typeName,slreq.custom.RequirementType.Informational);
            end
            if~isempty(this.children)&&isInformational
                slreq.app.RequirementTypeManager.showNotificationOnInformationalTypeChange();
            end
        end

        function out=get.PreImportFcn(this)
            out=this.dataModelObj.preImportFcn;
            if isempty(out)
                out=getPreFillCallbackInfo('PreImportFcn');
            end
        end

        function out=get.PostImportFcn(this)
            out=this.dataModelObj.postImportFcn;
            if isempty(out)
                out=getPreFillCallbackInfo('PostImportFcn');
            end
        end

        function set.PreImportFcn(this,value)
            this.dataModelObj.preImportFcn=value;
        end

        function set.PostImportFcn(this,value)
            this.dataModelObj.postImportFcn=value;
        end

        copy(this,destObj)

        result=promote(this)

        result=canPromote(this,view)

        result=demote(this)

        result=canDemote(this,view)

        result=canMoveUp(this,view);
        result=canMoveDown(this,view);
        result=canMoveTo(this,view,offset);

        updateParent(this)

        index=findChildIndex(this)

        link=addLink(this,source)

        commentDas=addComment(this)

        [incomingLinks,outgoingLinks]=getLinks(this,varargin)

        links=getOutgoingLinks(this,varargin)

        function id=get.Id(this)
            if isempty(this.dataModelObj)
                id='';
            else
                id=this.dataModelObj.id;
            end
        end

        function idx=get.Index(this)
            if isempty(this.dataModelObj)
                idx='';
            else
                idx=this.dataModelObj.index;
            end
        end

        function id=get.CustomID(this)
            if isempty(this.dataModelObj)
                id='';
            else
                id=this.dataModelObj.customId;
            end
        end

        function set.CustomID(this,value)
            this.dataModelObj.customId=value;
            this.updateMarkups();
        end

        function id=get.SID(this)
            if isempty(this.dataModelObj)
                id='';
            else

                id=num2str(this.dataModelObj.sid);
            end
        end

        function set.Summary(this,value)
            this.dataModelObj.summary=value;
            this.updateMarkups();
        end

        function value=get.Summary(this)
            if isempty(this.dataModelObj)
                value='';
            else
                value=this.dataModelObj.summary;
            end
        end

        function set.Description(this,value)
            this.dataModelObj.description=value;
            this.LastDescEditorType='';
            this.updateMarkups();
        end

        function value=get.DescriptionEditorType(this)
            value=this.dataModelObj.descriptionEditorType;
        end

        function set.DescriptionEditorType(this,value)
            this.dataModelObj.descriptionEditorType=value;
        end


        function value=get.RationaleEditorType(this)
            value=this.dataModelObj.rationaleEditorType;
        end

        function set.RationaleEditorType(this,value)
            this.dataModelObj.rationaleEditorType=value;
        end







        function value=get.Description(this)
            if isempty(this.dataModelObj)
                value='';
            else
                value=this.dataModelObj.description;
            end
        end

        function set.Rationale(this,value)
            this.dataModelObj.rationale=value;
            this.updateMarkups();
            this.LastRatiEditorType='';
        end

        function value=get.Rationale(this)
            if isempty(this.dataModelObj)
                value='';
            else
                value=this.dataModelObj.rationale;
            end
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

        function value=get.Domain(this)
            value=this.dataModelObj.domain;
        end

        function value=get.Comments(this)
            value=slreq.das.Comment.empty;

            if isempty(this.dataModelObj)
                return;
            end

            comments=this.dataModelObj.comments;
            for n=1:length(comments)

                dataComment=comments(n);
                dasComment=dataComment.getDasObject();
                if~isempty(dasComment)
                    value(n)=dasComment;
                else


                    dasComment=slreq.das.Comment(comments(n));
                    value(n)=dasComment;
                end
            end
        end

        function set.Domain(this,value)
            if~isempty(this.dataModelObj)
                this.dataModelObj.domain=value;
            end
        end

        function value=get.SynchronizedOn(this)
            value=this.dataModelObj.synchronizedOn;
        end

        function value=get.IsLocked(this)
            value=this.dataModelObj.locked;
        end

        function value=get.isExternal(this)
            if isempty(this.dataModelObj)
                value=false;
            else
                value=this.dataModelObj.external;
            end
        end

        remove(this)

        reparentObjectUnder(this,newParent)

        onDataReqMove(this)

        function markups=get.Markups(this)
            markups=this.view.markupManager.getMarkupsByReqUuid(this.dataUuid);
        end

        updateMarkups(this)

        markup=getExistingMarkupOnSystem(this,sys)

        function value=get.propsBot(this)
            if isempty(this.dataModelObj)||this.dataModelObj.external


                value={'SID','Revision','SynchronizedOn','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn'};
            else
                value={'SID','Revision','CreatedBy','CreatedOn','ModifiedBy','ModifiedOn'};
            end
        end

        function propsTop=get.propsTop(this)
            if~this.isJustification
                propsTop={'Type','Index','CustomID','Summary'};
            else
                propsTop={'Index','CustomID','Summary','isHierarchicalJustification'};
            end
        end


        icon=getDisplayIcon(this)

        label=getDisplayLabel(this)

        selections=resolveComponentSelection(this)

        items=getContextMenuItems(this,caller)

        menu=getContextMenu(this,nodes)

        propValue=getPropValue(this,propName)


        [bIsValid]=isValidProperty(this,propName)

        setPropValue(this,propName,propValue)

        tf=isDragAllowed(this)


        tf=isDropAllowed(this)

        tf=isDropAllowedFor(this,dstDas,location,action);

        dialog=getDialogSchema(this,dlg)

        yesno=isEditablePropertyInInspector(this,propName)

        name=getDisplayName(this,propName)

        name=getObjectType(this)

        dtype=getPropDataType(this,propName)

        [status,changelog]=synchronize(this,syncOptions)

        mimedata=getMimeData(this);

        function status=getStatus(this,name)
            status=this.dataModelObj.status.(name);
        end

        function status=getSelfStatus(this,name)
            status=this.dataModelObj.selfStatus.(name);
        end

        function rootNode=getRootNode(this)

            rootNode=this;
            while~isa(rootNode.parent,'slreq.das.RequirementSet')
                rootNode=rootNode.parent;
            end
        end

        unlock(this);

        unlockAll(this);

        updateOSLCRequirement(this);

        setDisplayIcon(this,sourceChangeDetected)

        function updatePropertyInspector(this,changedEvent)
            if nargin<2
                changedEvent=[];
            end













            mgr=slreq.app.MainManager.getInstance;
            if~isempty(changedEvent)&&...
                (strcmp(changedEvent.PropName,'summary')||strcmp(changedEvent.PropName,'customId'))



                uUIDToDasObjects=containers.Map('KeyType','char','ValueType','any');
                [inLinks,outLinks]=this.getLinks;

                for inLinkIndex=1:length(inLinks)

                    cLink=inLinks(inLinkIndex);
                    cDasLink=cLink.getDasObject();
                    if~isempty(cDasLink)
                        uUIDToDasObjects(cDasLink.dataUuid)=cDasLink;


                        mgr.refreshUI(cDasLink);
                    end
                    if strcmpi(cLink.source.domain,'linktype_rmi_slreq')&&cLink.source.isValid
                        srcData=slreq.utils.getReqObjFromSourceItem(cLink.source);
                        dasReq=srcData.getDasObject();
                        if~isempty(dasReq)
                            uUIDToDasObjects(dasReq.dataUuid)=dasReq;
                        end
                    end
                end

                for outLinkIndex=1:length(outLinks)

                    cLink=outLinks(outLinkIndex);

                    cDasLink=cLink.getDasObject();
                    if~isempty(cDasLink)
                        uUIDToDasObjects(cDasLink.dataUuid)=cDasLink;


                        mgr.refreshUI(cDasLink);
                    end

                    if~isempty(cLink.dest)&&strcmp(cLink.dest.domain,'linktype_rmi_slreq')
                        dstDataReq=cLink.dest;
                        dasReq=dstDataReq.getDasObject();
                        if~isempty(dasReq)
                            uUIDToDasObjects(dasReq.dataUuid)=dasReq;
                        end
                    end
                end

                allInvolvdedDasObjects=uUIDToDasObjects.values;
                for reqIndex=1:length(allInvolvdedDasObjects)
                    cDasObj=allInvolvdedDasObjects{reqIndex};


                    dlgs=DAStudio.ToolRoot.getOpenDialogs(cDasObj);
                    slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);
                end
            end

            updatePropertyInspector@slreq.das.BaseObject(this);
        end
    end

    methods(Access={?slreq.gui.ReqSpreadSheet,?slreq.gui.RequirementsEditor,?slreq.internal.gui.Editor})
        updateMimeData(this,dasObjs)
    end

    methods(Access=private)

        detach(this)

        resyncAfterDetach(this)
    end

    methods(Access=protected)
        reparentWrappedMFObjectUnder(this,parentDasObj)
    end

    methods(Static)
        onCutItem()

        onCopyItem()

        onPasteItem()

        onAddChildRequirement()

        onAddRequirementAfter()

        onDeleteRequirement()

        onLinkToSelectedBlock()

        onLinkToSelectedZCElement()

        onLinkToSelectedFaultElement()

        onLinkToSelectedSafetyManagerElement()

        onLinkToSelectedTest()

        onLinkToSelectedML()

        onLinkToSelectedDD()

        onCompleteSelectionLinking()

        onStartLinking()

        onNewInmplementationJustification()

        onNewVerificationJustification()

        onOpenLinkEditor()

        onSelectionJustificationLinkingForImplementation();

        onSelectionJustificationLinkingForVerification();

        onCopyUrl()

        onSuppressNumber()

        onSetSectionNumber(varargin)

        onMoveUpRequirement();

        onMoveDownRequirement();

        onUpdateSrcLocation();

        onExpandAll();

        onCollapseAll();

        sortedReqs=sortByIndex(dasObjs);

        mimeType=getMimeType(studio);

        mimeTypes=getMimeTypes();
    end

    methods
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
    end

end

function out=getPreFillCallbackInfo(callbackName)

    out=['% ',getString(message(['Slvnv:slreq:CallbackTooltip',callbackName]))];
end
