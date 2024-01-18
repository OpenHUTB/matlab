classdef BaseEditableItem<slreq.BaseItem

    properties(Dependent)
Id
Summary
Description
Keywords
Rationale
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
CreatedOn
CreatedBy
ModifiedBy
    end


    properties(Constant,GetAccess=private)
        supportedDestMap=containers.Map({'under','before','after'},{'on','before','after'});
    end


    methods(Access=protected)
        function this=BaseEditableItem(dataObject)
            this@slreq.BaseItem(dataObject);
        end
    end


    methods
        function id=get.Id(this)
            id=this.dataObject.id;
        end


        function set.Id(this,value)
            value=convertStringsToChars(value);
            this.dataObject.customId=value;
        end


        function value=get.Summary(this)
            value=this.dataObject.summary;
        end


        function set.Summary(this,value)
            value=convertStringsToChars(value);
            this.dataObject.summary=value;
        end


        function value=get.Description(this)
            value=this.dataObject.description;
        end


        function set.Description(this,value)
            if isempty(this.dataObject.descriptionEditorType)
                value=convertStringsToChars(value);
                this.dataObject.description=value;
                if~slreq.cpputils.hasHtmlTags(value)&&contains(value,'<')

                    rmiut.warnNoBacktrace('Slvnv:slreq:IncompatibleCharForRichEditor')
                end
            else
                throw(MException(message('Slvnv:slreq:ExternalEditorErrorChangeFromAPI')));
            end
        end


        function value=get.Rationale(this)
            value=this.dataObject.rationale;
        end


        function set.Rationale(this,value)
            if isempty(this.dataObject.rationaleEditorType)
                value=convertStringsToChars(value);
                this.dataObject.rationale=value;
                if~slreq.cpputils.hasHtmlTags(value)&&contains(value,'<')
                    rmiut.warnNoBacktrace('Slvnv:slreq:IncompatibleCharForRichEditor')
                end
            else
                throw(MException(message('Slvnv:slreq:ExternalEditorErrorChangeFromAPI')));
            end
        end


        function value=get.Keywords(this)
            value=this.dataObject.keywords;
        end


        function set.Keywords(this,value)
            value=convertStringsToChars(value);
            this.dataObject.keywords=value;
        end


        function value=get.CreatedOn(this)
            value=this.dataObject.createdOn;
        end


        function value=get.CreatedBy(this)
            value=this.dataObject.createdBy;
        end


        function value=get.ModifiedBy(this)
            value=this.dataObject.modifiedBy;
        end


        function success=promote(this)
            this.errorIfVectorOperation();
            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','promote',this.reqSet.getParentModel));
            end
            try
                success=this.dataObject.promote();
            catch ex
                throwAsCaller(ex);
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
                throwAsCaller(ex);
            end
        end


        function success=move(this,location,dstReq)
            this.errorIfVectorOperation();
            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','move',this.reqSet.getParentModel));
            end

            if numel(dstReq)>1
                error(message('Slvnv:slreq:DestinationShallBeScalar'));
            end
            if~isempty(dstReq.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','move',dstReq.reqSet.getParentModel));
            end
            if this==dstReq
                error(message('Slvnv:slreq:InvalidRequirementMoveDest'));
            end

            if isa(this,'slreq.Justification')
                if~isa(dstReq,'slreq.Justification')
                    error(message('Slvnv:slreq:JustificationMoveError'));
                end
            end
            if isa(this,'slreq.Requirement')
                if~isa(dstReq,'slreq.Requirement')
                    error(message('Slvnv:slreq:RequirementMoveError'));
                end
            end
            try
                charInput=convertStringsToChars(location);
                if isKey(this.supportedDestMap,charInput)
                    success=this.dataObject.moveTo(this.supportedDestMap(charInput),dstReq.dataObject);
                else
                    error(message('Slvnv:slreq:InputValueOutOfRange','location','{''under'', ''before'', ''after''}'));
                end
            catch ex
                throwAsCaller(ex);
            end
        end


        function success=copy(this,location,dstReq)
            this.errorIfVectorOperation();
            if numel(dstReq)>1
                error(message('Slvnv:slreq:DestinationShallBeScalar'));
            end

            if isa(this,'slreq.Justification')
                if~isa(dstReq,'slreq.Justification')
                    error(message('Slvnv:slreq:JustificationCopyError'));
                end
            end
            if isa(this,'slreq.Requirement')
                if~isa(dstReq,'slreq.Requirement')
                    error(message('Slvnv:slreq:RequirementCopyError'));
                end
            end
            if~isempty(dstReq.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','copy',dstReq.reqSet.getParentModel));
            end

            try
                charInput=convertStringsToChars(location);
                if isKey(this.supportedDestMap,charInput)
                    reqData=slreq.data.ReqData.getInstance();
                    reqData.copyRequirement(this.dataObject,this.supportedDestMap(charInput),dstReq.dataObject);
                    success=true;
                else
                    error(message('Slvnv:slreq:InputValueOutOfRange','location','{''under'', ''before'', ''after''}'));
                end
            catch ex
                throwAsCaller(ex);
            end
        end
    end
end