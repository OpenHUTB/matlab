function traceInfo=getFunctionBlockTraceInfo(sid)


    traceInfo=[];

    if~coder.internal.gui.Features.MlfbTraceability.Enabled||isempty(sid)||~ischar(sid)
        return;
    end

    persistent coderTraceInstalled;
    if isempty(coderTraceInstalled)
        coderTraceInstalled=~isempty(which('coder.trace.getTraceInfo'));
    end
    if~coderTraceInstalled
        return;
    end

    try
        model=bdroot(sid);
    catch
        return;
    end

    traceInfo=coder.trace.getTraceInfo(model);
end