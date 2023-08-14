function setNumCores(cbinfo)





    numCores=cbinfo.EventData;
    modelH=cbinfo.model.Handle;

    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    if isempty(numCores)
        appContext.setNumCores([],modelH);
    elseif ischar(numCores)
        appContext.setNumCores(str2double(numCores),modelH);
    end
end


