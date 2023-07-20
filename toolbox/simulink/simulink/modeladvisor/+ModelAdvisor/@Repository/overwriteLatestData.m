
function overwriteLatestData(obj,tablename,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database OverwriteLatestData',true);

    if~exist(obj.FileLocation,'file')
        obj.MAObj.getWorkDir;
    end
    [~,indexes]=obj.loadData(tablename);
    if isempty(indexes)
        obj.saveData(tablename,varargin{:});
    else
        obj.modifyData(indexes(end),varargin{:});
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Database OverwriteLatestData',false);
end
