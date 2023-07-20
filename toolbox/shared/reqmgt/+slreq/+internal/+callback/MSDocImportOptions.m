










classdef MSDocImportOptions<slreq.internal.callback.ImportOptions


    properties
Bookmarks
Match
    end

    methods(Access=protected)

        function setOptions(this,opts)
            setOptions@slreq.internal.callback.ImportOptions(this,opts);
            if isfield(opts,'bookmarks')
                this.Bookmarks=opts.bookmarks;
            end

            if isfield(opts,'match')
                this.Match=opts.match;
            end
        end
    end

    methods(Access=public,Hidden)

        function result=exportOptions(this)
            result=exportOptions@slreq.internal.callback.ImportOptions(this);
            result.bookmarks=this.Bookmarks;
            if~isempty(this.Match)
                result.match=this.Match;
            end
        end

    end
end
