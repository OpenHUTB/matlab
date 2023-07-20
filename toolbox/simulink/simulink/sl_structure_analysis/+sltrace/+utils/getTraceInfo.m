function traceInfo=getTraceInfo(isTraceToSrc,segment,isTraceAll,interceptor,busElement)
    currentGraph=get_param(segment,'Parent');
    currentBD=get_param(sltrace.utils.getBaseGraph(currentGraph),'handle');


    seg=SLM3I.SLDomain.handle2DiagramElement(segment);

    if(seg.isvalid()&&isa(seg,'SLM3I.Segment'))
        oldState=warning('off','backtrace');
        x=onCleanup(@()warning(oldState.state,'backtrace'));
        if(isTraceToSrc)
            if isTraceAll
                traceInfo=SLM3I.SLDomain.getHighlightToAllSrcAdv(seg,interceptor,busElement);
            else
                traceInfo=SLM3I.SLDomain.getHighlightToSrcInfo(seg);
            end
        else
            if isTraceAll
                traceInfo=SLM3I.SLDomain.getHighlightToAllDestAdv(seg,interceptor,busElement);
            else
                traceInfo=SLM3I.SLDomain.getHighlightToDestInfo(seg);
            end
        end
        traceInfo.traceBD=currentBD;

        slprivate('remove_hilite',currentBD);
        SLM3I.SLDomain.removeBdFromHighlightMode(currentBD);
    else
        error(message('Simulink:HiliteTool:InvalidSegHandleSLM3I'));
    end

end