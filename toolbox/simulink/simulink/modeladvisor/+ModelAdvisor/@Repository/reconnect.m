
function reconnect(obj)
    PerfTools.Tracer.logMATLABData('MAGroup','Database Reconnect',true);

    if~isa(obj.DatabaseHandle,'sdi.Repository')&&~isempty(obj.FileLocation)
        try
            obj.connect(obj.FileLocation);
        catch E
            if strcmp(E.identifier,'sqldb:ssdb:Locked')
                return;
            end
        end
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Database Reconnect',false);
end
