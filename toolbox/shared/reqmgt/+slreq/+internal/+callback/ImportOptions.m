classdef ImportOptions<handle




    properties
        AsReference=true;
        RichText=false;
DocUri
    end

    properties(Access=private)
        HasDocID=false;
    end

    methods
        function set.AsReference(this,value)
            if~value
                currentObj=slreq.getCurrentObject;
                if isa(currentObj,'slreq.Reference')


                    error(message('Slvnv:slreq:CallbackErrorOptionChangeIsNotAllowedForUpdate','AsReference'));
                end
            end

            this.AsReference=value;

        end
    end
    properties(SetAccess=private)

DocType
ReqSet
    end
    properties(Hidden)




        PreImportFcn='';
        PostImportFcn='';
    end

    methods(Access=protected)

        function this=ImportOptions(docType,options)
            if nargin>1
                this.setOptions(options)
            end
            this.DocType=docType;
        end
    end

    methods(Access=protected)

        function setOptions(this,options)
            if isfield(options,'preImportFcn')
                this.PreImportFcn=options.preImportFcn;
            end

            if isfield(options,'postImportFcn')
                this.PostImportFcn=options.postImportFcn;
            end

            if isfield(options,'ReqSet')
                this.ReqSet=options.ReqSet;
            end

            if isfield(options,'AsReference')
                this.AsReference=options.AsReference;
            end

            if isfield(options,'richText')
                this.RichText=options.richText;
            end

            if isfield(options,'DocID')
                this.DocUri=options.DocID;
                this.HasDocID=true;
            elseif isfield(options,'docPath')
                this.DocUri=options.docPath;
            end

        end
    end

    methods(Access=public,Hidden)

        function options=exportOptions(this)
            options=struct;
            options.ReqSet=this.ReqSet;
            options.AsReference=this.AsReference;
            options.richText=this.RichText;
            options.preImportFcn=this.PreImportFcn;
            options.postImportFcn=this.PostImportFcn;
            options.docPath=this.DocUri;
            if this.HasDocID
                options.DocID=this.DocUri;
            end
        end
    end
end

