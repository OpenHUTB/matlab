






























classdef ReqIFImportOptions<slreq.internal.callback.ImportOptions


    properties(SetObservable)
MappingFile
Attr2ReqProp
        SingleSpec='';
        AsMultipleReqSets=false;
        ImportLinks=true;
AutoDetectMapping
    end

    properties(SetAccess=private,GetAccess=public,Hidden)
UsingLegacyReqIF
    end

    methods(Access=protected)

        function setOptions(this,opts)
            setOptions@slreq.internal.callback.ImportOptions(this,opts);
            if isfield(opts,'mappingFile')
                this.MappingFile=opts.mappingFile;
            end

            if isfield(opts,'attr2reqprop')
                this.Attr2ReqProp=opts.attr2reqprop;
            end

            if isfield(opts,'singleSpec')
                this.SingleSpec=opts.singleSpec;
            end

            if isfield(opts,'asMultiple')
                this.AsMultipleReqSets=opts.asMultiple;
            end

            if isfield(opts,'importLinks')
                this.ImportLinks=opts.importLinks;
            end

            if isfield(opts,'UseLegacyReqIF')
                this.UseLegacyReqIF=opts.UseLegacyReqIF;
            end

            if isfield(opts,'autoDetectMapping')
                this.AutoDetectMapping=opts.autoDetectMapping;
            end
        end
    end
    methods(Access=public,Hidden)

        function result=exportOptions(this)
            result=exportOptions@slreq.internal.callback.ImportOptions(this);

            if~isempty(this.MappingFile)
                result.mappingFile=this.MappingFile;
            end

            if~isempty(this.Attr2ReqProp)
                result.attr2reqprop=this.Attr2ReqProp;
            end

            result.singleSpec=this.SingleSpec;
            result.asMultiple=this.AsMultipleReqSets;
            result.importLinks=this.ImportLinks;

            if~isempty(this.AutoDetectMapping)
                result.autoDetectMappingReqIF=this.AutoDetectMapping;
            end
        end

    end
end
