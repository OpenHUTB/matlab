function deleteData(obj,tablename,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Database DeleteData',true);
    obj.reconnect;
    tablename=ModelAdvisor.Repository.convertTablename(tablename);
    ObjectIndex=obj.DatabaseHandle.findObjects(tablename,varargin{:});
    Simulink.sdi.Instance.engine.safeTransaction(@bulkremove,obj.DatabaseHandle,ObjectIndex);
    obj.disconnect;
    PerfTools.Tracer.logMATLABData('MAGroup','Database DeleteData',false);
end

function bulkremove(db_handle,ObjectIndex)
    for i=1:length(ObjectIndex)
        db_handle.removeObject(ObjectIndex(i));
    end
end