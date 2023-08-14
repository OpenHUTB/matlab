function setDesignLatency(cbinfo)



    designLatency=cbinfo.EventData;
    modelH=cbinfo.model.Handle;

    if~isempty(designLatency)&&ischar(designLatency)
        appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
        appContext.setDesignLatency(str2double(designLatency),modelH);
    end

end


