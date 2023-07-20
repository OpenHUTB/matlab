










classdef Requirement<slreq.data.AttributeOwner&slreq.data.ReqLinkBase&slreq.analysis.BaseRollupAnalysis




    properties(Dependent)
customId
summary
description
parent
keywords
rationale
attributeItems
stereotypeAttributes
typeName
preImportFcn
postImportFcn
    end

    properties(Dependent,GetAccess=public,SetAccess=?slreq.data.ReqData)
sid
    end



    properties




















        changedLinkAsSrc;
        changedLinkAsDst;
        tableData;
    end

    properties(Access=private)
        pendingUpdateStatus;
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
id
index
children
external
synchronizedOn
comments
locked
externalTypeName
hIdxEnabled
fixedHIdx
    end

    properties(Dependent,GetAccess=public)
artifactUri
artifactId
domain
isHierarchicalJustification
        descriptionEditorType;
        rationaleEditorType;
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
        dirty;

UUID
    end

    properties(Constant,Hidden)
        REQIF_DOMAIN_PREFIX='ReqIF:';
        REQIF_DOMAIN_PREFIX_LENGTH=6;
        OSLC_DOMAIN_PREFIX='OSLC:';
        OSLC_DOMAIN_PREFIX_LENGTH=5;
    end

    methods(Access=?slreq.data.ReqData)






        function this=Requirement(varargin)
            if nargin==1
                this.modelObject=varargin{1};
            end
            this.changedLinkAsSrc=containers.Map('KeyType','char','ValueType','logical');
            this.changedLinkAsDst=containers.Map('KeyType','char','ValueType','logical');
            this.filterState='';
        end

    end

    methods(Static)


        function out=stripNewline(in)







            out=regexprep(in,'[\f\n\r\t\v]+',' ');
        end

        function tf=isExternallySourcedReqIF(domainLabel)
            tf=strncmp(domainLabel,slreq.data.Requirement.REQIF_DOMAIN_PREFIX,slreq.data.Requirement.REQIF_DOMAIN_PREFIX_LENGTH);
        end
    end

    methods
        function setFilterState(this,fState,thisOnly)
            parent=this.parent;
            doParent=~thisOnly&&~isempty(parent);
            switch fState
            case 'in'
                this.filterState='in';
                if doParent
                    parent.setFilterState('childIn',thisOnly);
                end
            case 'childIn'
                switch this.filterState
                case{'out',''}
                    this.filterState='parent';
                    if doParent
                        parent.setFilterState('childIn',thisOnly);
                    end
                end
            case 'out'
                switch this.filterState
                case{'','in'}
                    this.filterState='out';
                    if doParent
                        parent.setFilterState('childOut',thisOnly);
                    end
                end
            case 'childOut'
                switch this.filterState
                case 'parent'
                    allOut=true;
                    children=this.children;
                    for i=1:length(children)
                        if~strcmp(children(i).filterState,'out')
                            allOut=false;
                            break;
                        end
                    end
                    if allOut
                        this.filterState='out';
                        if doParent
                            parent.setFilterState('childOut',thisOnly);
                        end
                    end
                end
            case ''
                this.filterState='';
                if doParent
                    parent.setFilterState('',thisOnly);
                end
            end
        end

        function reqSet=getReqSet(this)
            reqSet=slreq.data.ReqData.getInstance.getParentReqSet(this);
        end

        function reqSet=getSet(this)


            reqSet=slreq.data.ReqData.getInstance.getParentReqSet(this);
        end

        function id=get.id(this)
            if isa(this.modelObject,'slreq.datamodel.ExternalRequirement')
                id=this.modelObject.uniqueCustomId;
            else
                id=this.modelObject.customId;
                if isempty(id)
                    id=sprintf('#%d',this.modelObject.sid);
                end
            end
        end


        function idx=get.index(this)
            if this.modelObject.hIdxEnabled
                idx=this.modelObject.hIdx;
                if isempty(idx)



                    reqSet=slreq.data.ReqData.getInstance.getParentReqSet(this);
                    reqSet.updateHIdx();
                    idx=this.modelObject.hIdx;
                end
            else
                idx='';
            end
        end

        function customId=get.customId(this)
            customId=this.modelObject.customId;
        end

        function set.customId(this,customId)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end


            if~isempty(customId)&&customId(1)=='#'
                error(message('Slvnv:slreq:BadCustomID',customId));
            end


            if isequal(this.modelObject.customId,customId)
                return;
            end
            changedInfo.propName='customId';
            changedInfo.oldValue=this.modelObject.customId;
            changedInfo.newValue=customId;


            this.modelObject.customId=customId;
            this.setDirty(true);
            this.notifyObservers(changedInfo);
        end

        function sid=get.sid(this)
            sid=this.modelObject.sid;
        end

        function set.sid(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.sid=value;
            this.setDirty(true);
            this.notifyObservers();
        end


        function value=get.descriptionEditorType(this)
            value=this.modelObject.descriptionEditorType;
        end

        function set.descriptionEditorType(this,value)
            oldvalue=this.modelObject.descriptionEditorType;

            this.modelObject.descriptionEditorType=value;
            if strcmpi(oldvalue,'word')&&isempty(value)
                this.updateImagesSource('Description');
            end
        end

        function accept(this,visitor)
            visitor.visitRequirement(this);
        end


        function value=get.rationaleEditorType(this)
            value=this.modelObject.rationaleEditorType;
        end

        function set.rationaleEditorType(this,value)
            oldvalue=this.modelObject.rationaleEditorType;
            this.modelObject.rationaleEditorType=value;
            if strcmpi(oldvalue,'word')&&isempty(value)
                this.updateImagesSource('Rationale');
            end
        end

        function set.summary(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if this.modelObject.isLocked
                error(message('Slvnv:slreq:MustUnlockBeforeEditing'));
            end


            value=slreq.data.Requirement.stripNewline(value);


            if isequal(this.modelObject.summary,value)
                return;
            end

            changedInfo.propName='summary';
            changedInfo.oldValue=this.modelObject.summary;
            changedInfo.newValue=value;

            this.modelObject.summary=value;
            this.setDirty(true);
            this.notifyObservers(changedInfo);
        end

        function set.keywords(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if this.modelObject.isLocked
                error(message('Slvnv:slreq:MustUnlockBeforeEditing'));
            end





            reqData=slreq.data.ReqData.getInstance();
            reqData.setKeywords(this,value);
            this.setDirty(true);
            this.notifyObservers();
        end

        function value=get.summary(this)
            value=this.modelObject.summary;
        end

        function value=getModifiedPTime(this)


            value=this.modelObject.getModifiedOnPTime();
        end

        function set.description(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if this.modelObject.isLocked&&~this.isOslcQueryTopNode()
                error(message('Slvnv:slreq:MustUnlockBeforeEditing'));
            end


            if isequal(this.description,value)
                return;
            end

            dataReqSet=this.getReqSet();

            if strcmpi(this.descriptionEditorType,'word')
                useReqSetMacro=true;
                resourceFolder=slreq.opc.getReqSetTempDir(dataReqSet.name);
            else
                useReqSetMacro=false;
                resourceFolder=slreq.opc.getUsrTempDir;

            end
            [newValue,imageList]=slreq.utils.HTMLProcessor.packingImage(value,resourceFolder,useReqSetMacro);


            this.modelObject.description=newValue;

            dataReqSet.collectImagesForPacking(imageList);

            this.setDirty(true);
            this.notifyObservers();

        end

        function callbackText=get.preImportFcn(this)






            callbackText='';

            if this.isImportRootItem&&~isempty(this.modelObject.preImport)
                callbackText=this.modelObject.preImport.text;
            end
        end

        function callbackText=get.postImportFcn(this)
            callbackText='';
            if this.isImportRootItem&&~isempty(this.modelObject.postImport)
                callbackText=this.modelObject.postImport.text;
            end
        end

        function set.preImportFcn(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if~this.isImportRootItem
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            if slreq.data.ReqData.getInstance.setCallback(this,'preImport',value)
                this.setDirty(true);
            end
        end

        function set.postImportFcn(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if~this.isImportRootItem
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            if slreq.data.ReqData.getInstance.setCallback(this,'postImport',value)
                this.setDirty(true);
            end
        end


        function tf=isOslcQueryTopNode(this)
            tf=this.isOSLC()&&this.sid==1;
        end

        function out=getRawDescription(this)


            out=this.modelObject.description;

        end


        function setRawDescription(this,value)











            if~isequal(value,this.modelObject.description)
                this.modelObject.description=value;
                this.setDirty(true);
                this.notifyObservers();
            end
        end

        function out=getRawRationale(this)
            out=this.modelObject.rationale;
        end

        function out=getNumOfDescendants(this)


            out=double(this.modelObject.getNumOfDescendants());
        end

        function setRawRationale(this,value)
            if~isequal(value,this.modelObject.rationale)
                this.modelObject.rationale=value;
                this.setDirty(true);
                this.notifyObservers();
            end
        end

        function value=get.rationale(this)
            reqSet=this.getReqSet();
            value=reqSet.unpackImages(this.modelObject.rationale);

        end

        function set.rationale(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if this.modelObject.isLocked
                error(message('Slvnv:slreq:MustUnlockBeforeEditing'));
            end


            if isequal(this.rationale,value)
                return;
            end

            dataReqSet=this.getReqSet();

            if strcmpi(this.rationaleEditorType,'word')
                useReqSetMacro=true;
                resourceFolder=slreq.opc.getReqSetTempDir(dataReqSet.name);
            else
                useReqSetMacro=false;
                resourceFolder=slreq.opc.getUsrTempDir;
            end
            [newValue,imageList]=slreq.utils.HTMLProcessor.packingImage(value,resourceFolder,useReqSetMacro);



            this.modelObject.rationale=newValue;

            dataReqSet.collectImagesForPacking(imageList);

            this.setDirty(true);
            this.notifyObservers();

        end

        function value=get.description(this)
            reqSet=this.getReqSet();
            value=reqSet.unpackImages(this.modelObject.description);
        end

        function value=get.keywords(this)
            if this.modelObject.keywords.Size>0
                value=this.modelObject.keywords.toArray;
            else
                value={};
            end
        end

        function value=get.external(this)
            value=isa(this.modelObject,'slreq.datamodel.ExternalRequirement');
        end

        function value=get.externalTypeName(this)
            value=this.modelObject.getExternalTypeName();
        end



        function count=updateMappedTypes(this,typeNameMap)
            count=0;

            externalName=this.modelObject.getExternalTypeName();
            if isKey(typeNameMap,externalName)
                wantedInternalTypeName=typeNameMap(externalName);
                if~strcmp(this.getDisplayTypeName(),wantedInternalTypeName)
                    this.setReqTypeByDisplayName(wantedInternalTypeName);
                    count=count+1;
                end
            end

            childReqs=this.children;
            for i=1:numel(childReqs)
                count=count+childReqs(i).updateMappedTypes(typeNameMap);
            end
        end

        function out=isOSLC(this)
            if this.external
                out=startsWith(this.modelObject.group.domain,this.OSLC_DOMAIN_PREFIX);
            else
                out=false;
            end
        end

        function value=get.locked(this)
            value=this.modelObject.isLocked;
        end

        function unlock(this,hasSideEffects)



            if~this.modelObject.isLocked
                return;
            end
            if nargin<2
                hasSideEffects=true;
            end

            this.modelObject.isLocked=false;

            if hasSideEffects

                this.setDirty(true);
                changedInfo.propName='Unlocked';
                changedInfo.oldValue=true;
                changedInfo.newValue=false;
                this.notifyObservers(changedInfo);
            end
        end

        function unlockAll(this,varargin)
            this.unlock(varargin{:});

            childReqs=this.children;
            for n=1:length(childReqs)
                childReq=childReqs(n);
                childReq.unlockAll(varargin{:});
            end
        end

        function lock(this)


            this.modelObject.isLocked=true;
        end

        function lockAll(this)
            this.lock();

            childReqs=this.children;
            for n=1:length(childReqs)
                childReq=childReqs(n);
                childReq.lockAll();
            end
        end



        function updateOSLCRequirement(this)
            if this.isOSLC()
                reqData=slreq.data.ReqData.getInstance();
                reqData.updateOSLCRequirement(this.modelObject);


                this.setDirty(true);
                this.notifyObservers();
            else

                ME=MException('Slvnv:slreq:productError','Requirement %s is not OSLC proxy',this.id);
                throwAsCaller(ME);
            end
        end

        function value=get.synchronizedOn(this)
            if isa(this.modelObject,'slreq.datamodel.ExternalRequirement')
                value=slreq.utils.getDateTime(this.modelObject.synchronizedOn,'Read');
            else
                value=NaT;
            end
        end

        function setSynchronizedOn(this)
            if isa(this.modelObject,'slreq.datamodel.ExternalRequirement')
                this.modelObject.synchronizedOn=datetime();
            end
        end

        function value=getSynchronizedOnPTime(this)


            if isa(this.modelObject,'slreq.datamodel.ExternalRequirement')
                value=this.modelObject.getSynchronizedOnPTime;
            else
                value=0;
            end
        end

        function out=get.dirty(this)
            out=this.modelObject.dirty;
        end

        function set.dirty(this,value)
            this.modelObject.dirty=value;
        end

        function value=get.artifactUri(this)
            value='';
            if this.external
                value=this.modelObject.group.artifactUri;
            end
        end

        function value=get.artifactId(this)
            value='';
            if this.external
                value=this.modelObject.artifactId;
            end
        end

        function parent=get.parent(this)
            parent=slreq.data.Requirement.empty;


            parentModelObj=this.modelObject.parent;
            if~isempty(parentModelObj)
                parent=slreq.data.ReqData.getWrappedObj(parentModelObj);
            end
        end

        function attributeItems=get.attributeItems(this)
            attributeItems=this.modelObject.attributeItems;
        end

        function stereotypeAttributes=get.stereotypeAttributes(this)
            stereotypeAttributes=this.modelObject.customAttributes;
        end

        function value=get.comments(this)
            value=slreq.data.Comment.empty;

            if this.modelObject.comments.Size>0
                revObj=this.modelObject.comments.toArray;
                for n=1:length(revObj)


                    value(n)=slreq.data.ReqData.getWrappedObj(revObj(n));
                end
            end
        end

        function comment=addComment(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            reqData=slreq.data.ReqData.getInstance();
            comment=reqData.addComment(this);
        end

        function removeComment(this,idx)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            toRemove=this.comments(idx);
            reqData=slreq.data.ReqData.getInstance();
            reqData.removeComment(toRemove);
            this.comments(idx)=[];
        end

        function set.parent(this,parentInfo)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            reqData=slreq.data.ReqData.getInstance();
            if isa(parentInfo,'slreq.data.DataModelObj')
                parentObj=parentInfo;
            else



                dataReqSet=this.getReqSet();
                parentObj=dataReqSet.getRequirementById(parentInfo);
                if isempty(parentObj)
                    if isnumeric(parentInfo)
                        parentInfo=sprintf('#%d',parentInfo);
                    end
                    rmiut.warnNoBacktrace('Slvnv:reqmgt:NotFoundIn',parentInfo,dataReqSet.name);
                    return;
                end
                if parentObj.external~=this.external

                    rmiut.warnNoBaktrace('Slvnv:slreq_import:CannotParentUnder',this.id,parentObj.id);
                    return;
                end
                if this.external&&~strcmp(this.artifactUri,parentObj.artifactUri)

                    rmiut.warnNoBaktrace('Slvnv:slreq_import:CannotParentUnder',this.id,parentObj.id);
                    return;
                end
            end
            reqData.setParentRequirement(this,parentObj);
            this.setDirty(true);


        end



        function children=get.children(this)






            childModelObjs=this.modelObject.children.toArray;
            if~isempty(childModelObjs)

                children(size(childModelObjs))=slreq.data.Requirement();
                for i=1:length(childModelObjs)
                    childObj=slreq.data.ReqData.getWrappedObj(childModelObjs(i));
                    children(i)=childObj;
                end


            else
                children=slreq.data.Requirement.empty;
            end
        end

        function firstChild=getFirstChild(this)
            if this.modelObject.children.Size>0
                mfChild=this.modelObject.children.at(1);
                firstChild=slreq.data.ReqData.getWrappedObj(mfChild);
            else
                firstChild=slreq.data.Requirement.empty;
            end
        end

        function success=promote(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            success=slreq.data.ReqData.getInstance.promote(this);


        end

        function success=demote(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            success=slreq.data.ReqData.getInstance.demote(this);


        end

        function success=moveUp(this)
            success=slreq.data.ReqData.getInstance.move(this,-1);
            this.setDirty(true);


        end

        function success=moveDown(this)
            success=slreq.data.ReqData.getInstance.move(this,1);
            this.setDirty(true);


        end

        function[success,pendingUpdateStruct]=moveTo(this,location,dstReq,pendingUpdateStruct)



            if nargin<4
                pendingUpdateStruct=[];
            end
            [success,pendingUpdateStruct]=slreq.data.ReqData.getInstance.moveRequirement(...
            this,location,dstReq,pendingUpdateStruct);
            this.setDirty(true);


        end

        function value=get.domain(this)
            if this.external&&~isempty(this.modelObject.group)
                value=this.modelObject.group.domain;
            else
                value='linktype_rmi_slreq';
            end
        end

        function set.domain(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if this.external&&~isempty(this.modelObject.group)
                this.modelObject.group.domain=value;
                this.setDirty(true);
                this.notifyObservers();
            end
        end

        function set.artifactId(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.artifactId=value;
            this.setDirty(true);
            this.notifyObservers();
        end

        function set.artifactUri(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if this.external&&~isempty(this.modelObject.group)
                this.modelObject.group.artifactUri=value;
                this.setDirty(true);
                this.notifyObservers();
            end
        end

        function tf=isDirectLink(this)



            tf=strcmp(this.modelObject.requirementSet.name,'default');
        end

        function req=addChildRequirement(this,varargin)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if this.external
                error(message('Slvnv:slreq:FailedToAddInternalInExternalReq'))
            elseif this.isJustification
                error(message('Slvnv:slreq:FailedToAddInternalInJustification'))
            end
            reqData=slreq.data.ReqData.getInstance();
            req=reqData.addRequirement(this,varargin{:});
        end

        function req=addChildExternalRequirement(this,varargin)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            reqData=slreq.data.ReqData.getInstance();
            req=reqData.addExternalRequirement(this,varargin{:});
        end

        function req=addRequirementAfter(this)
            if~isempty(this.parent)...
                &&isa(this.parent,'slreq.data.Requirement')...
                &&this.parent.external
                error(message('Slvnv:slreq:FailedToAddInternalInExternalReq'))
            end

            if this.isJustification&&...
                ~isempty(this.parent)




                error(message('Slvnv:slreq:FailedToAddInternalInJustification'));
            end

            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            reqData=slreq.data.ReqData.getInstance();
            req=reqData.addRequirementAfter(this);
        end


        function updateImplementationStatus(this)








            preVisitor=slreq.analysis.PreprocessVisitor;
            preVisitor.setAnalysisForImplementation;

            if this.isChildOfInformationalType||...
                slreq.app.RequirementTypeManager.isa(this.typeName,...
                slreq.custom.RequirementType.Informational,this.getReqSet)



                preVisitor.isInInformational=true;
            end

            [~,isHierarchical]=this.isHierarchicallyJustified(slreq.custom.LinkType.Implement);
            if isHierarchical
                preVisitor.isHierarchicallyJustifiedForImplementation=true;
            end

            postVisitor=slreq.analysis.ImplementationVisitor;

            this.acceptVisitor(preVisitor,postVisitor);


            postVisitor.visitRequirementAncestors(this);
        end


        function updateImplementationStatusForStatsOnly(this)




            if this.isChildOfInformationalType||...
                slreq.app.RequirementTypeManager.isa(this.typeName,...
                slreq.custom.RequirementType.Informational,this.getReqSet)



                return;
            end

            this.initImplementationStatus()
            postVisitor=slreq.analysis.ImplementationVisitor;


            if~isempty(this.children)

                postVisitor.visitRequirementAncestors(this.children(1));
            else

                postVisitor.visitRequirement(this);

                postVisitor.visitRequirementAncestors(this);
            end
        end


        function updateVerificationStatus(this)








            preVisitor=slreq.analysis.PreprocessVisitor;
            preVisitor.setAnalysisForVerification;

            if this.isChildOfInformationalType||...
                slreq.app.RequirementTypeManager.isa(this.typeName,...
                slreq.custom.RequirementType.Informational,this.getReqSet)

                preVisitor.isInInformational=true;
            end

            [~,isHierarchical]=this.isHierarchicallyJustified(slreq.custom.LinkType.Verify);
            if isHierarchical
                preVisitor.isHierarchicallyJustifiedForVerification=true;
            end

            postVisitor=slreq.analysis.VerificationVisitor;

            this.acceptVisitor(preVisitor,postVisitor);


            postVisitor.visitRequirementAncestors(this);
        end


        function updateVerificationStatusForStatsOnly(this)



            if this.isChildOfInformationalType||...
                slreq.app.RequirementTypeManager.isa(this.typeName,...
                slreq.custom.RequirementType.Informational,this.getReqSet)



                return;
            end

            this.initVerificationStatus()
            postVisitor=slreq.analysis.VerificationVisitor;


            if~isempty(this.children)

                postVisitor.visitRequirementAncestors(this.children(1));
            else

                postVisitor.visitRequirement(this);

                postVisitor.visitRequirementAncestors(this);
            end
        end


        function justObj=addChildJustification(this,reqInfo)
            if nargin<2
                reqInfo=[];
            end
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            reqData=slreq.data.ReqData.getInstance();
            justObj=reqData.addJustification(this,'child',reqInfo);
        end

        function justObj=addJustificationAfter(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            reqData=slreq.data.ReqData.getInstance();

            reqInfo=struct('id','','summary','','description','');
            justObj=reqData.addJustification(this,'after',reqInfo);
        end

        function tf=isJustification(this)
            tf=isa(this.modelObject,'slreq.datamodel.Justification');
        end

        function[tf,isHierarchical]=isJustifiedFor(this,justificationType)









            tf=false;
            isHierarchical=false;
            reqData=slreq.data.ReqData.getInstance();
            inLinks=reqData.getIncomingLinks(this);
            for n=1:length(inLinks)
                link=inLinks(n);
                if slreq.app.LinkTypeManager.isa(inLinks(n).type,...
                    justificationType,link.getLinkSet())
                    src=inLinks(n).source;
                    if strcmp(src.domain,'linktype_rmi_slreq')
                        srcReq=slreq.utils.getReqObjFromSourceItem(src);
                        if~isempty(srcReq)&&srcReq.isJustification
                            tf=true;
                            isHierarchical=isHierarchical||srcReq.isHierarchicalJustification;
                            if tf&&(nargout==1||isHierarchical)



                                return;
                            end
                        end
                    end
                end
            end
        end

        function tf=get.isHierarchicalJustification(this)
            tf=false;
            if this.isJustification
                tf=this.modelObject.isHierarchical;
            end
        end

        function set.isHierarchicalJustification(this,tf)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if this.isJustification
                changedInfo.propName='isHierarchicalJustification';
                changedInfo.oldValue=this.modelObject.isHierarchical;
                changedInfo.newValue=tf;
                this.modelObject.isHierarchical=tf;
                this.setDirty(true);

                this.notifyObservers(changedInfo);

            end
        end

        function[isJustified,isHierarchical]=isHierarchicallyJustified(this,justificationType)






            [isJustified,isHierarchical]=this.isJustifiedFor(justificationType);
            if isJustified&&(nargout==1||isHierarchical)




                return;
            end





            parentNode=this.parent;
            if~isempty(parentNode)
                isJustified=recIsHierarchicallyJustified(parentNode,justificationType);



                isHierarchical=isHierarchical||isJustified;

            end


            function yesno=recIsHierarchicallyJustified(thisReq,justificationType)




                [~,yesno]=thisReq.isJustifiedFor(justificationType);
                if yesno

                    return;
                end
                thisParent=thisReq.parent;
                if~isempty(thisParent)

                    yesno=recIsHierarchicallyJustified(thisParent,justificationType);
                end
            end
        end

        function tf=isChildOfInformationalType(this)


            tf=false;
            parentReq=this.parent;
            if~isempty(parentReq)
                tf=recCheckInformationalType(parentReq,this.getReqSet);
            end

            function tf=recCheckInformationalType(node,reqSet)

                tf=slreq.app.RequirementTypeManager.isa(node.typeName,...
                slreq.custom.RequirementType.Informational,reqSet);
                if~tf
                    parentNode=node.parent;
                    if~isempty(parentNode)
                        tf=recCheckInformationalType(parentNode,reqSet);
                    end
                end
            end
        end

        function tf=isSelfInformational(this)
            tf=slreq.app.RequirementTypeManager.isa(this.typeName,...
            slreq.custom.RequirementType.Informational,this.getReqSet);
        end

        function tf=isInformational(this)
            tf=this.isChildOfInformationalType||this.isSelfInformational;

        end

        function tf=isImportRootItem(this)

            tf=this.external&&isempty(this.parent);
        end

        function link=addLink(this,source,linkType)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            if nargin<3
                linkType='';
            end
            reqData=slreq.data.ReqData.getInstance();
            if isstruct(source)
                if~isfield(source,'artifact')||~isfield(source,'id')
                    error(message('Slvnv:slreq:StructureMissingRequiredFields','.artifact','.id'));
                end
            else
                if isa(source,'slreq.data.Requirement')&&isequal(this,source)
                    error(message('Slvnv:slreq:CannotLinkToSelf'));
                end
                source=slreq.utils.getRmiStruct(source);
            end
            linkSet=reqData.getLinkSet(source.artifact,source.domain);
            if isempty(linkSet)
                linkSet=reqData.createLinkSet(source.artifact,source.domain);
            end
            link=linkSet.addLink(source,this,linkType);
        end

        function out=getFullID(this)


            reqSet=this.getReqSet;
            [~,artifact]=fileparts(reqSet.filepath);
            out=[artifact,':#',num2str(this.sid)];
        end

        function[incomingLinks,outgoingLinks]=getLinks(this,varargin)
            reqData=slreq.data.ReqData.getInstance();
            if nargin==1

                incomingLinks=reqData.getIncomingLinks(this);
            else

                allIncomingLinks=reqData.getIncomingLinks(this);
                incomingLinks=slreq.data.Link.empty();
                filterLinkType=varargin{1};
                for n=1:length(allIncomingLinks)
                    eachIncomingLink=allIncomingLinks(n);

                    isFilterType=slreq.app.LinkTypeManager.isa(...
                    eachIncomingLink.type,filterLinkType,...
                    eachIncomingLink.getLinkSet());

                    if isFilterType
                        incomingLinks(end+1)=eachIncomingLink;%#ok<AGROW>
                    end
                end
            end
            if nargout>1


                outgoingLinks=this.getOutgoingLinks(varargin{:});
            end
        end


        function incomingLinks=getIncomingLinksWithType(this,type,isStrict)

            reqData=slreq.data.ReqData.getInstance();
            allIncomingLinks=reqData.getIncomingLinks(this);
            incomingLinks=slreq.app.LinkTypeManager.filterLinksByType(type,isStrict,allIncomingLinks);
        end


        function outGoingLinks=getOutgoingLinksWithType(this,type,isStrict)

            reqData=slreq.data.ReqData.getInstance();
            allOutgoingLinks=reqData.getOutgoingLinks(this);
            outGoingLinks=slreq.app.LinkTypeManager.filterLinksByType(type,isStrict,allOutgoingLinks);
        end


        function outgoingLinks=getOutgoingLinks(this,type)
            reqData=slreq.data.ReqData.getInstance();
            if nargin==1

                outgoingLinks=reqData.getOutgoingLinks(this);
            else

                allOutgoingLinks=reqData.getOutgoingLinks(this);
                outgoingLinks=slreq.data.Link.empty();
                for n=1:length(allOutgoingLinks)
                    eachOutgoingLink=allOutgoingLinks(n);

                    isFilterType=slreq.app.LinkTypeManager.isa(...
                    eachOutgoingLink.type,type,...
                    eachOutgoingLink.getLinkSet());
                    if isFilterType
                        outgoingLinks(end+1)=eachOutgoingLink;%#ok<AGROW>
                    end
                end
            end
        end


        function clearCache(this)%#ok<MANU>


        end


        function dataObjs=destroyContentsAndChildren(this)

            dataObjs={};



            if~isempty(this.modelObject)





                dataObjs=this.modelObject.destroyContentsRecursively(true,true);

                for i=1:length(dataObjs)
                    dataObjs{i}.clearModelObj();
                end



                this.modelObject=[];
            end
        end

        function typeName=get.typeName(this)
            typeName=this.modelObject.typeName;
        end

        function set.typeName(this,typeNameOrEnum)

            reqData=slreq.data.ReqData.getInstance;
            if isenum(typeNameOrEnum)
                thisTypeName=char(typeNameOrEnum);
            else
                thisTypeName=typeNameOrEnum;
            end
            isStereotype=slreq.internal.ProfileReqType.isProfileStereotype(this.getReqSet(),thisTypeName);
            if~isStereotype




                reqData.getRequirementType(typeNameOrEnum);
            end

            if isequal(this.modelObject.typeName,thisTypeName)
                return;
            end

            changedInfo.propName='typeName';
            changedInfo.oldValue=this.typeName;
            this.modelObject.typeName=thisTypeName;
            changedInfo.newValue=this.typeName;


            if~isStereotype
                reqData.resolveRequirementType(this.modelObject);
            else


            end
            this.setDirty(true);
            this.notifyObservers(changedInfo);
        end

        function setReqTypeByDisplayName(this,displayName)


            if slreq.internal.ProfileReqType.isProfileStereotype(this.getReqSet,this.typeName)
                slreq.data.ReqData.getInstance.deleteStereotypeAttributes(this);
            end

            allMFReqTypes=slreq.data.ReqData.getInstance.getAllRequirementTypes();
            for n=1:length(allMFReqTypes)
                mfReqType=allMFReqTypes(n);

                thisForwardName=slreq.app.RequirementTypeManager.getDisplayName(mfReqType.name);
                if strcmp(thisForwardName,displayName)
                    this.typeName=mfReqType.name;
                    return;
                end
            end


            dataReqSet=this.getReqSet();
            stereotypes=dataReqSet.getAllStereotypes();
            if any(strcmp(stereotypes,displayName))
                this.typeName=displayName;
            end
        end

        function displayName=getDisplayTypeName(this)
            if isempty(this.modelObject.typeName)
                displayName='';
            else
                dataReqSet=slreq.data.ReqData.getInstance().getParentReqSet(this);
                if slreq.internal.ProfileReqType.isProfileStereotype(dataReqSet,this.modelObject.typeName)
                    displayName=this.modelObject.typeName;
                else
                    displayName=slreq.app.RequirementTypeManager.getDisplayName(this.modelObject.typeName);
                end
            end
        end


        function updateImagesSource(this,propertyName)


            setMacro=slreq.uri.ImageSourceConstants.SET_RESOURCE_MACRO_VAR;
            reqMacro=slreq.uri.ImageSourceConstants.RESOURCE_MACRO_VAR;
            dataReqSet=this.getReqSet;
            reqSetName=dataReqSet.name;
            md5BaseName=slreq.opc.getReqSetDirBaseName(reqSetName);
            newSource=[reqMacro,'/',md5BaseName];
            if strcmpi(propertyName,'description')
                this.setRawDescription(strrep(this.getRawDescription(),setMacro,newSource));
            else
                this.setRawRationale(strrep(this.getRawRationale(),setMacro,newSource));
            end




            allImageOldResourcePath=dataReqSet.getImageListForReq(this.sid,propertyName);
            allImageNewResourcePath=strrep(allImageOldResourcePath,setMacro,newSource);

            dataReqSet.removeImages(allImageOldResourcePath);
            dataReqSet.collectImagesForPacking(allImageNewResourcePath);
        end

        function addChangedLinkAsSrc(this,linkUuid)
            if~isKey(this.changedLinkAsSrc,linkUuid)
                this.changedLinkAsSrc(linkUuid)=true;
            end
        end

        function addChangedLinkAsDst(this,linkUuid)
            if~isKey(this.changedLinkAsDst,linkUuid)
                this.changedLinkAsDst(linkUuid)=true;
            end
        end

        function removeChangedLinkAsSrc(this,linkUuid)
            if isKey(this.changedLinkAsSrc,linkUuid)
                this.changedLinkAsSrc.remove(linkUuid);
            end
        end

        function removeChangedLinkAsDst(this,linkUuid)
            if isKey(this.changedLinkAsDst,linkUuid)
                this.changedLinkAsDst.remove(linkUuid);
            end
        end

        function tf=isReqIF(this)
            tf=this.external...
            &&slreq.data.Requirement.isExternallySourcedReqIF(this.domain);
        end

        function idx=indexOf(this,chDataReq)
            mfChildReq=chDataReq.modelObject;
            if this.modelObject.children.Size>0
                idx=this.modelObject.children.indexOf(mfChildReq);
            else
                idx=0;
            end
        end

        function[adapter,artifactUri,artifactId]=getAdapter(this)
            if~this.isDirectLink
                dom='linktype_rmi_slreq';
            else
                dom=this.domain;
            end
            adapter=slreq.adapters.AdapterManager.getInstance().getAdapterByDomain(dom);
            artifactUri=adapter.getArtifactUri(this);
            artifactId=adapter.getArtifactId(this);
        end

        function status=getPendingUpdateStatus(this)
            if isempty(this.pendingUpdateStatus)
                this.pendingUpdateStatus=slreq.dataexchange.UpdateDetectionStatus.Unknown;
            end
            status=this.pendingUpdateStatus;
        end

        function setPendingUpdateStatus(this,status)

            changedInfo.propName='pendingDetectionStatus';
            changedInfo.oldValue=this.pendingUpdateStatus;
            changedInfo.newValue=status;
            this.pendingUpdateStatus=status;
            this.notifyObservers(changedInfo);
        end

        function out=getReqSetArtifactUri(this)
            out=this.modelObject.requirementSet.filepath;
        end



        function[affectImplementationStatus,affectVerificationStatus]=doesChangeImpactRollupStatus(this,changedEvent)%#ok<INUSL>
            affectImplementationStatus=false;
            affectVerificationStatus=false;













            switch changedEvent.PropName
            case 'typeName'



                affectImplementationStatus=true;
                affectVerificationStatus=true;
                return;
            case 'isHierarchicalJustification'
                affectImplementationStatus=true;
                affectVerificationStatus=true;
                return;
            otherwise
                return;
            end
        end

        function[affectImplementationStatus,affectVerificationStatus,...
            affectedObjects,affectedObjectsForStats]=doesChangeImpactRollupStatusWhenMoving(this,changedEvent)





























            affectImplementationStatus=false;
            affectVerificationStatus=false;
            affectedObjects={this};
            affectedObjectsForStats={};

            if~strcmp(changedEvent.PropName,'moving')
                return;
            end

            if this.isSelfInformational
                affectImplementationStatus=false;
                affectVerificationStatus=false;
                return
            end

            oldParent=changedEvent.OldValue.dst;
            if strcmp(changedEvent.NewValue.location,'on')
                newParent=changedEvent.NewValue.dst;
            else
                newParent=changedEvent.NewValue.dst.parent;
                if isempty(newParent)
                    newParent=changedEvent.NewValue.dst.getReqSet;
                end
            end

            if newParent==oldParent

                return;
            end





            if~isa(newParent,'slreq.data.RequirementSet')&&newParent.isInformational
                if~isa(oldParent,'slreq.data.RequirementSet')&&oldParent.isInformational()
                    affectImplementationStatus=false;
                    affectVerificationStatus=false;
                    return
                else
                    affectImplementationStatus=true;
                    affectVerificationStatus=true;
                    affectedObjectsForStats={oldParent};


                    affectedObjects={this};
                    return
                end
            else
                affectImplementationStatus=true;
                affectVerificationStatus=true;
                if~isa(oldParent,'slreq.data.RequirementSet')&&oldParent.isInformational
                    affectedObjects={this};

                    affectedObjectsForStats={};
                    return
                else


                    affectedObjectsForStats={oldParent,newParent};


                    affectedObjects={};
                    return;
                end
            end
        end







        function propsStruct=toStruct(this)
            propsStruct=struct('domain','','artifact','','id',this.id,...
            'summary','','reqSet','','sid','','embeddedReq',false);
            reqSet=this.getReqSet();
            if this.isDirectLink()
                propsStruct.domain=this.domain;
                propsStruct.artifact=this.artifactUri;
                propsStruct.id=this.artifactId;
            else

                if~isempty(reqSet.parent)
                    propsStruct.domain='linktype_rmi_simulink';



                    fPath=fileparts(reqSet.filepath);
                    propsStruct.artifact=fullfile(fPath,reqSet.parent);
                    propsStruct.embeddedReq=true;
                else
                    propsStruct.domain='linktype_rmi_slreq';
                    propsStruct.artifact=reqSet.filepath;
                end
                propsStruct.reqSet=[reqSet.name,'.slreqx'];
                propsStruct.sid=this.sid;
                propsStruct.summary=this.summary;
            end
        end

        function uuid=get.UUID(this)
            uuid=this.modelObject.UUID;
        end

        function tf=get.hIdxEnabled(this)
            tf=this.modelObject.hIdxEnabled;
        end

        function number=get.fixedHIdx(this)
            number=this.modelObject.fixedHIdx;
        end

        function enableHIdx(this,state)
            hasOutline=this.modelObject.hIdxEnabled;
            if(state~=hasOutline)
                this.modelObject.enableHIdx(state);
                this.setDirty(true);
                this.refreshUI();
            end
        end

        function setHIdx(this,number)
            currentNumber=this.modelObject.fixedHIdx;
            if(currentNumber~=number)
                this.modelObject.fixHIdx(number);
                this.setDirty(true);
                this.refreshUI();
            end
        end

    end

    methods(Hidden)

        function relock(this)

            if~this.external
                return;
            end
            if this.modelObject.isLocked
                return;
            end
            this.modelObject.isLocked=true;
        end

        function setPostImportFcn(this,value)


            slreq.data.ReqData.getInstance.setCallback(this,'postImport',value);
        end

        function setPreImportFcn(this,value)


            slreq.data.ReqData.getInstance.setCallback(this,'preImport',value);
        end
    end

    methods(Access={?slreq.data.RequirementSet,?slreq.data.ReqData,?slreq.data.ReqLinkBase,?slreq.data.SLService})

        function setDirty(this,value)


            if value&&~this.locked
                this.updateModificationInfo();
            end
            if this.dirty~=value
                this.dirty=value;
                if value
                    reqSet=this.getReqSet();

                    assert(~isempty(reqSet));
                    reqSet.setDirty(true);
                end
            end

            if this.dirty
                this.getReqSet().dirtySlxModel();
            end
        end

        function refreshUI(~)
            if slreq.app.MainManager.hasEditor()
                appMgr=slreq.app.MainManager.getInstance();
                appMgr.refreshUI();
            end
        end
    end
end
