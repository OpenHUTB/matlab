
















































































































































































classdef Reference<slreq.BaseItem



    properties(Dependent,GetAccess=public,SetAccess=private)
Id
CustomId
Artifact
ArtifactId
Domain
UpdatedOn
CreatedOn
CreatedBy

ModifiedBy
IsLocked
    end

    properties(Dependent)
Summary
Description
Rationale
Keywords
Type
    end

    properties(Dependent,Hidden,GetAccess=public,SetAccess=private)



SynchronizedOn
    end

    methods(Access=private)
        function tf=isAllowedToChangeHierarchy(this)
            cbInfo=slreq.internal.callback.CurrentInformation.getInstance;

            tf=cbInfo.isCallbackRunning;

            if tf


                rootImportNode=this.getRootImportNode();
                currentRootItemsForCallback=cbInfo.getCurrentImportNodes();
                for callbackRootItem=currentRootItemsForCallback
                    if isequal(rootImportNode,callbackRootItem)
                        return
                    end
                end
            end
            tf=false;
        end

        function rootImportNode=getRootImportNode(this)
            rootImportNode=this;
            while~rootImportNode.dataObject.isImportRootItem
                rootImportNode=rootImportNode.parent;
            end

        end
    end

    methods
        function out=getPreImportFcn(this)


            this.errorIfVectorOperation();
            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            out=dataReq.preImportFcn;

        end

        function out=getPostImportFcn(this)



            this.errorIfVectorOperation();
            dataReq=this.dataObject;

            if~dataReq.isImportRootItem()
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            out=dataReq.postImportFcn;
        end

        function setPreImportFcn(this,value)
            this.errorIfVectorOperation();
            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            value=convertStringsToChars(value);
            dataReq.preImportFcn=value;
        end

        function count=remove(this,varargin)





            if isa(this.parent,'slreq.ReqSet')||this.isAllowedToChangeHierarchy()
                count=remove@slreq.BaseItem(this,varargin{:});
                return
            end

            error(message('Slvnv:slreq:APIRemoveNonRootReference'))
        end

        function success=moveUp(this)
            this.errorIfVectorOperation();

            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()&&this.isAllowedToChangeHierarchy()
                success=moveUp@slreq.BaseItem(this);
                return;
            end

            error(message('Slvnv:slreq:PropertyIsNotSettable','moveUp'))
        end

        function success=moveDown(this)
            this.errorIfVectorOperation();
            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()&&this.isAllowedToChangeHierarchy()
                success=moveDown@slreq.BaseItem(this);
                return;
            end

            error(message('Slvnv:slreq:PropertyIsNotSettable','moveDown'))
        end


        function setParent(this,value)
            if this.isAllowedToChangeHierarchy()
                callbackType=slreq.internal.callback.CurrentInformation.getCallbackType;
                if callbackType==slreq.internal.callback.Types.PostImportFcn
                    value=convertStringsToChars(value);
                    this.dataObject.parent=value;
                    return;
                end
            end
            error(message('Slvnv:slreq:PropertyIsNotSettable','parent'));
        end

        function setPostImportFcn(this,value)
            this.errorIfVectorOperation();
            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()
                error(message('Slvnv:slreq:CallbackErrorNotForNonRootImport'));
            end

            value=convertStringsToChars(value);
            dataReq.postImportFcn=value;
        end




        function this=Reference(dataObject)
            this@slreq.BaseItem(dataObject);
        end

        function artifact=get.Artifact(this)
            artifact=this.dataObject.artifactUri;
        end

        function artifact=get.ArtifactId(this)
            artifact=this.dataObject.artifactId;
        end



        function id=get.Id(this)
            id=this.dataObject.id;
        end


        function id=get.CustomId(this)
            id=this.dataObject.customId;
        end

        function out=get.IsLocked(this)
            out=this.dataObject.locked;
        end

        function value=get.Summary(this)
            value=this.dataObject.summary;
        end

        function set.Summary(this,value)
            try
                this.dataObject.summary=value;
            catch ex
                throwAsCaller(ex);
            end
        end

        function value=get.Description(this)
            value=this.dataObject.description;
        end

        function set.Description(this,value)
            try
                this.dataObject.description=value;
            catch ex
                throwAsCaller(ex);
            end
        end

        function value=get.Rationale(this)
            value=this.dataObject.rationale;
        end

        function set.Rationale(this,value)
            try
                this.dataObject.rationale=value;
            catch ex
                throwAsCaller(ex);
            end
        end

        function domain=get.Domain(this)
            domain=this.dataObject.domain;

            if strncmp(domain,this.dataObject.REQIF_DOMAIN_PREFIX,this.dataObject.REQIF_DOMAIN_PREFIX_LENGTH)
                domain(1:this.dataObject.REQIF_DOMAIN_PREFIX_LENGTH)=[];
            end
        end

        function timestamp=get.CreatedOn(this)
            timestamp=this.dataObject.createdOn;
        end

        function timestamp=get.CreatedBy(this)
            timestamp=this.dataObject.createdBy;
        end

        function timestamp=get.ModifiedBy(this)
            timestamp=this.dataObject.modifiedBy;
        end

        function timestamp=get.UpdatedOn(this)
            timestamp=this.dataObject.synchronizedOn;
        end

        function timestamp=get.SynchronizedOn(this)

            timestamp=this.dataObject.synchronizedOn;
        end

        function value=get.Keywords(this)
            value=this.dataObject.keywords;
        end

        function set.Keywords(this,value)
            try
                this.dataObject.keywords=value;
            catch ex
                throwAsCaller(ex);
            end
        end

        function value=get.Type(this)
            value=this.dataObject.typeName;
        end

        function set.Type(this,value)
            try
                value=convertStringsToChars(value);
                this.dataObject.typeName=value;
            catch ex
                throwAsCaller(ex);
            end
        end


        function setAttribute(this,name,value)
            this.errorIfVectorOperation();
            if this.dataObject.locked
                error(message('Slvnv:slreq:CustomAttributeLocked'));
            else
                try
                    setAttribute@slreq.BaseItem(this,name,value);
                catch ex
                    throwAsCaller(ex);
                end
            end
        end



        function childItem=add(this,varargin)
            this.errorIfVectorOperation();
            if isempty(varargin)
                reqInfo=[];
            else
                [varargin{:}]=convertStringsToChars(varargin{:});
                reqInfo=slreq.utils.apiArgsToReqStruct(varargin{:});
                slreq.BaseItem.ensureWriteableProps(reqInfo);
            end
            if any(strcmpi(varargin,'artifact'))

                addedItem=this.dataObject.addChildExternalRequirement(reqInfo);
            else

                addedItem=this.dataObject.addChildRequirement(reqInfo);
            end
            childItem=slreq.utils.dataToApiObject(addedItem);
        end

        function unlock(this)
            this.errorIfVectorOperation();
            this.dataObject.unlock();
        end

        function unlockAll(this)
            this.errorIfVectorOperation();
            parent=this.parent;
            if~isa(parent,'slreq.ReqSet')
                error(message('Slvnv:slreq:TopLevelReferenceOnly','unlockAll()'));
            end
            this.dataObject.unlockAll();
        end

        function[status,changelog]=updateFromDocument(this)
            this.errorIfVectorOperation();
            parent=this.parent;
            if~isa(parent,'slreq.ReqSet')
                error(message('Slvnv:slreq:TopLevelReferenceOnly','updateFromDocument()'));
            end

            try
                dasReq=this.dataObject.getDasObject();
                if~isempty(dasReq)





                    [status,changelog]=dasReq.synchronize(false);
                else


                    [statusData,changelog]=slreq.internal.synchronize(this.dataObject);

                    status=statusData.message;
                end
            catch ex
                error(message('Slvnv:slreq_import:UnableToSyncronizeDoc',...
                [this.dataObject.artifactUri,': ',newline,ex.message]));
            end
        end

        function link=justifyImplementation(this,justification)
            this.errorIfVectorOperation();
            if~isa(justification,'slreq.Justification')
                error(mesage('Slvnv:slreq:InvalidTypeForJustifiation'));
            end
            try
                link=slreq.createLink(justification,this);
                link.Type=slreq.custom.LinkType.Implement;

            catch ex
                throwAsCaller(ex);
            end
        end

        function link=justifyVerification(this,justification)
            this.errorIfVectorOperation();
            if~isa(justification,'slreq.Justification')
                error(mesage('Slvnv:slreq:InvalidTypeForJustifiation'));
            end
            try
                link=slreq.createLink(justification,this);
                link.Type=slreq.custom.LinkType.Verify;

            catch ex
                throwAsCaller(ex);
            end
        end

        function tf=isJustifiedFor(this,linkType)
            this.errorIfVectorOperation();
            if nargin<2
                error(message('Slvnv:slreq:JustificationMissingLinkTypeInput'))
            end
            linkType=convertStringsToChars(linkType);
            try


                tf=this.dataObject.isHierarchicallyJustified(linkType);
            catch ex
                throwAsCaller(ex);
            end
        end

        function status=getImplementationStatus(this,varargin)
            this.errorIfVectorOperation();
            rollupTypeName=slreq.analysis.ImplementationVisitor.getName();
            try


                status=this.dataObject.handlePublicAPICall(rollupTypeName,varargin{:});
            catch ex
                throwAsCaller(ex);
            end
        end

        function status=getVerificationStatus(this,varargin)
            this.errorIfVectorOperation();
            rollupTypeName=slreq.analysis.VerificationVisitor.getName();
            try


                status=this.dataObject.handlePublicAPICall(rollupTypeName,varargin{:});
            catch ex
                throwAsCaller(ex);
            end
        end

        function navigateToExternalArtifact(this)
            this.errorIfVectorOperation();
            if rmi.isInstalled
                if this.isReqIF()||this.isOSLC()




                    slreq.internal.navigateToExternalSource(this.dataObject);
                else




                    domainType=rmi.linktype_mgr('resolveByRegName',this.Domain);
                    if isempty(domainType)
                        error(message('Slvnv:rmi:navigate:TargetTypeNotRegistered',this.Domain));
                    end
                    if isempty(domainType.NavigateFcn)
                        error(message('Slvnv:slreq_import:MethodNotDefined',...
                        'NavigateFcn',this.Domain));
                    end

                    try
                        domainType.NavigateFcn(this.Artifact,this.ArtifactId);
                    catch ex







                        if domainType.IsFile&&~rmiut.isCompletePath(this.Artifact)
                            resolvedFilePath=rmi.locateFile(this.Artifact,this.reqSet.Filename);
                            if~isempty(resolvedFilePath)
                                domainType.NavigateFcn(resolvedFilePath,this.ArtifactId);
                            end
                        else
                            rethrow(ex);
                        end
                    end
                end
            else
                error(message('Slvnv:reqmgt:setReqs:NoLicense'));
            end
        end

        function tf=hasNewUpdate(this)
            this.errorIfVectorOperation();
            dataReq=this.dataObject;
            if~dataReq.isImportRootItem()
                error(message('Slvnv:slreq:TopLevelReferenceOnly','hasNewUpdate()'));
            end
            detectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
            detectionMgr.checkUpdatesForAllArtifacts();
            tf=dataReq.getPendingUpdateStatus()==slreq.dataexchange.UpdateDetectionStatus.Detected;
        end
    end

    methods(Hidden)

        function link=addLink(this,srcData)
            this.errorIfVectorOperation();
            if isa(srcData,'slreq.BaseItem')

                srcData=srcData.dataObject;
            end
            linkData=this.dataObject.addLink(srcData);
            if isempty(linkData)
                link=slreq.Link.empty();
            else
                link=slreq.utils.dataToApiObject(linkData);
            end
        end

        function tf=isReqIF(this)
            this.errorIfVectorOperation();
            tf=this.dataObject.isReqIF();
        end

        function tf=isOSLC(this)
            this.errorIfVectorOperation();
            tf=this.dataObject.isOSLC();
        end
    end
end

