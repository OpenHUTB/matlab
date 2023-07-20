classdef DataProxy<handle&matlab.mixin.CustomDisplay

    methods
        function usage=listDataUsage(this)
            usage=listDataUsageImpl(this);
            usage(arrayfun(@(x)isa(x.DataSource,'lutdesigner.data.source.UnknownDataSource'),usage(:)))=[];
            usedAs={usage.UsedAs};
            [~,order]=sort(usedAs);
            usage=usage(order);
        end
    end

    methods(Abstract,Access=protected)
        usage=listDataUsageImpl(this);
    end

    methods(Access=protected)
        function footer=getFooter(this)
            footer="";
            if isscalar(this)
                dataUsageStr=sprintf("Data usage\n%s",strjoin("  "+getDisplayString(this.listDataUsage()),'\n'));
                footer=sprintf('%s\n',dataUsageStr);
            end
        end
    end
end
