function value=loadLatestData(obj,tablename,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database LoadLatestData',true);
    value=obj.loadData(tablename,varargin{:});
    if length(value)>1
        value=value(end);
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Database LoadLatestData',false);
end
