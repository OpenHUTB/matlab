
























classdef MSWordImportOptions<slreq.internal.callback.MSDocImportOptions

    properties(SetObservable)
        IgnoreOutlineNumbers=false;
    end

    methods(Access=protected)

        function setOptions(this,opts)

            this.Bookmarks=true;
            this.RichText=true;
            setOptions@slreq.internal.callback.MSDocImportOptions(this,opts);
            if isfield(opts,'ignoreOutlineNumbers')
                this.IgnoreOutlineNumbers=opts.ignoreOutlineNumbers;
            end
        end

    end
    methods(Access=public,Hidden)


        function result=exportOptions(this)
            result=exportOptions@slreq.internal.callback.MSDocImportOptions(this);
            result.ignoreOutlineNumbers=this.IgnoreOutlineNumbers;
        end
    end
end
