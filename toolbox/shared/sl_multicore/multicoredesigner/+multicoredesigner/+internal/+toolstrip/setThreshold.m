function setThreshold(cbinfo)





    threshold=cbinfo.EventData;
    modelH=cbinfo.model.Handle;

    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(threshold)
        appContext.setThreshold([],modelH);
    elseif ischar(threshold)
        appContext.setThreshold(str2double(threshold),modelH);
    end
end


