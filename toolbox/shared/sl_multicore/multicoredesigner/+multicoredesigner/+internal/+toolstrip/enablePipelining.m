function enablePipelining(cbinfo)


    enablePipelining=cbinfo.EventData;
    modelH=cbinfo.model.Handle;
    appContext=multicoredesigner.internal.toolstrip.getappcontextobj(cbinfo);
    appContext.enablePipelining(enablePipelining,modelH);

end


