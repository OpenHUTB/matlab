function saveData(obj,tablename,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database SaveData',true);

    obj.reconnect;
    tablename=ModelAdvisor.Repository.convertTablename(tablename);
    ObjectIndex=obj.DatabaseHandle.createObject(tablename);
    if~isempty(obj.SID)
        obj.DatabaseHandle.setProperty(ObjectIndex,'SID',obj.SID);
    end
    obj.modifyData(ObjectIndex,varargin{:});
    obj.disconnect;

    PerfTools.Tracer.logMATLABData('MAGroup','Database SaveData',false);
end
