





























































































































































classdef Requirement<slreq.BaseEditableItem

    properties(Dependent)
Type
    end

    methods


        function this=Requirement(dataObject)
            this@slreq.BaseEditableItem(dataObject);
        end






        function value=get.Type(this)
            this.errorIfVectorOperation();
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

        function childReq=add(this,varargin)
            this.errorIfVectorOperation();

            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','add',this.reqSet.getParentModel));
            end

            if isempty(varargin)
                reqInfo=[];
            else
                [varargin{:}]=convertStringsToChars(varargin{:});
                reqInfo=slreq.utils.apiArgsToReqStruct(varargin{:});
                slreq.BaseItem.ensureWriteableProps(reqInfo);
            end
            if any(strcmpi(varargin,'artifact'))

                error(message('Slvnv:slreq:APIErrorOnAddingRefUnderReq'));
            else

                req=this.dataObject.addChildRequirement(reqInfo);
                childReq=slreq.utils.wrapDataObjects(req);
            end
        end

        function success=promote(this)
            this.errorIfVectorOperation();

            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','promote',this.reqSet.getParentModel));
            end

            try
                success=this.dataObject.promote();
            catch ex
                throw(ex);
            end
        end

        function success=demote(this)
            this.errorIfVectorOperation();

            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','demote',this.reqSet.getParentModel));
            end

            try
                success=this.dataObject.demote();
            catch ex
                throw(ex);
            end
        end

        function link=justifyImplementation(this,justification)
            this.errorIfVectorOperation();
            if~isa(justification,'slreq.Justification')
                error(message('Slvnv:slreq:InvalidTypeForJustifiation'));
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
                error(message('Slvnv:slreq:InvalidTypeForJustifiation'));
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
    end
    methods(Hidden)

        function link=addLink(this,srcData)
            this.errorIfVectorOperation();
            if isa(srcData,'slreq.BaseItem')

                srcData=srcData.dataObject;
            end
            linkData=this.dataObject.addLink(srcData);
            if isempty(linkData)
                link=slreq.Link.empty;
            else
                link=slreq.utils.dataToApiObject(linkData);
            end
        end
    end
end

