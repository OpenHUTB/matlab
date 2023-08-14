
function disconnect(obj)
    PerfTools.Tracer.logMATLABData('MAGroup','Database Disconnect',true);
    if obj.keepConnectionAlive
        PerfTools.Tracer.logMATLABData('MAGroup','Database Disconnect',false);
        return
    end

    if isa(obj.DatabaseHandle,'sdi.Repository')
        delete(obj.DatabaseHandle);
        obj.DatabaseHandle=[];
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Database Disconnect',false);
end
