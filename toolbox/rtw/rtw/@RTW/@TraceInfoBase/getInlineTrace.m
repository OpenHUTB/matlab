function[inlineTrace,m2cMap]=getInlineTrace(h)




    if~isempty(h.SourceSystem)
        inlineTrace=coder.trace.getTraceInfo(h.SourceSystem);
    else
        inlineTrace=coder.trace.getTraceInfo(h.Model);
    end
    m2cMap=[];
    if~isempty(inlineTrace)
        mc=inlineTrace.getModelToCodeRecords();
        if~isempty(mc)
            m2cMap=containers.Map;
            for i=1:length(mc)
                m2cMap(mc(i).SID)=mc(i);
            end
        end
    end
end
