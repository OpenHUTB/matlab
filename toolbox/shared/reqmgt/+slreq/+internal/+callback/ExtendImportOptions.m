classdef ExtendImportOptions<slreq.internal.callback.ImportOptions





    properties
Rationale
Keywords
Attributes
Filter
    end

    methods(Access=protected)

        function setOptions(this,opts)
            setOptions@slreq.internal.callback.ImportOptions(this,opts);
            if isfield(opts,'rationale')
                this.Rationale=opts.rationale;
            end

            if isfield(opts,'keywords')
                this.Keywords=opts.keywords;
            end

            if isfield(opts,'attributes')
                this.Attributes=opts.attributes;
            elseif isfield(opts,'attrNames')
                this.Attributes=opts.attrNames;
            end

            if isfield(opts,'filterString')
                this.Filter=opts.filterString;
            end
        end
    end
    methods(Access=public,Hidden)

        function result=exportOptions(this)
            result=exportOptions@slreq.internal.callback.ImportOptions(this);
            if~isempty(this.Rationale)
                result.rationale=this.Rationale;
            end

            if~isempty(this.Keywords)
                result.keywords=this.Keywords;
            end

            if~isempty(this.Attributes)
                result.attributes=this.Attributes;
            end

            if~isempty(this.Filter)
                result.filterString=this.Filter;
            end
        end
    end
end
