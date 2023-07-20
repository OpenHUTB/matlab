




































classdef MSExcelImportOptions<slreq.internal.callback.MSDocImportOptions




    properties
Worksheet
        SubDocPrefix=false;
Rows
Columns
        Attributes={};
IdColumn
SummaryColumn
DescriptionColumn
RationaleColumn
KeywordsColumn
AttributeColumn
CreatedByColumn
ModifiedByColumn
        USDM='';
    end

    properties(Hidden)
        Headers={};
    end

    properties(Access=private)
Mapping
USDM_Internal
    end

    methods(Access=protected)

        function setOptions(this,opts)

            this.Bookmarks=false;
            setOptions@slreq.internal.callback.MSDocImportOptions(this,opts);

            opts=slreq.import.convertAttributesToHeaders(opts);

            if isfield(opts,'headers')
                this.Headers=opts.headers;
            end

            if isfield(opts,'attributes')
                this.Attributes=opts.attributes;
            end


            if isfield(opts,'sheet')
                this.Worksheet=opts.sheet;
            end

            if isfield(opts,'Worksheet')
                this.Worksheet=opts.worksheet;
            end

            if isfield(opts,'subDoc')
                this.Worksheet=opts.subDoc;
            end

            if isfield(opts,'subDocPrefix')
                this.SubDocPrefix=opts.subDocPrefix;
            end

            if isfield(opts,'rows')
                this.Rows=opts.rows;
            end

            if isfield(opts,'columns')
                this.Columns=opts.columns;
            end

            if isfield(opts,'idColumn')
                this.IdColumn=opts.idColumn;
            end

            if isfield(opts,'summaryColumn')
                this.SummaryColumn=opts.summaryColumn;
            end

            if isfield(opts,'descriptionColumn')
                this.DescriptionColumn=opts.descriptionColumn;
            end

            if isfield(opts,'rationaleColumn')
                this.RationaleColumn=opts.rationaleColumn;
            end

            if isfield(opts,'keywordsColumn')
                this.KeywordsColumn=opts.keywordsColumn;
            end

            if isfield(opts,'attributeColumn')
                this.AttributeColumn=opts.attributeColumn;
            end

            if isfield(opts,'USDM')
                this.USDM=opts.USDM;
            end

            if isfield(opts,'usdm')
                if islogical(opts.usdm)
                    this.USDM_Internal=opts.usdm;
                else
                    this.USDM=opts.usdm;
                end
            end



            if isempty(this.Columns)
                this.Columns=1:max(this.AttributeColumn);
            end

            if isfield(opts,'mapping')
                this.Mapping=opts.mapping;
            end

            if isfield(opts,'createdByColumn')
                this.CreatedByColumn=opts.createdByColumn;
            end
            if isfield(opts,'modifiedByColumn')
                this.ModifiedByColumn=opts.modifiedByColumn;
            end
        end
    end
    methods(Access=public,Hidden)

        function result=exportOptions(this)
            result=exportOptions@slreq.internal.callback.MSDocImportOptions(this);
            if~isempty(this.Worksheet)
                result.subDoc=this.Worksheet;
            end

            if~isempty(this.Rows)
                result.rows=this.Rows;
            end

            if~isempty(this.Columns)
                result.columns=this.Columns;
            end

            if~isempty(this.Attributes)
                result.attributes=this.Attributes;
            end

            if~isempty(this.Headers)
                result.headers=this.Headers;
            end

            if~isempty(this.Mapping)

                result.mapping=this.Mapping;
            end

            result.idColumn=this.IdColumn;
            result.summaryColumn=this.SummaryColumn;
            result.descriptionColumn=this.DescriptionColumn;
            result.keywordsColumn=this.KeywordsColumn;
            result.rationaleColumn=this.RationaleColumn;
            if~isempty(this.CreatedByColumn)
                result.createdByColumn=this.CreatedByColumn;
            end
            if~isempty(this.ModifiedByColumn)
                result.modifiedByColumn=this.ModifiedByColumn;
            end
            result.attributeColumn=this.AttributeColumn;
            if~isempty(result.attributeColumn)&&...
                isfield(result,'attributes')&&numel(result.attributeColumn)==numel(result.attributes)
                for i=1:numel(result.attributeColumn)


                    columnIdx=result.attributeColumn(i);
                    headerIdx=find(result.columns==columnIdx);
                    if numel(headerIdx)==1
                        result.headers{headerIdx}=result.attributes{i};
                    end
                end
            end
            result.subDocPrefix=this.SubDocPrefix;
            if~isempty(this.USDM)
                result.match=slreq.import.usdmParamsToPattern(this.USDM);
                result.usdm=true;
            elseif~isempty(this.USDM_Internal)
                result.usdm=this.USDM_Internal;
            end
        end
    end
end
