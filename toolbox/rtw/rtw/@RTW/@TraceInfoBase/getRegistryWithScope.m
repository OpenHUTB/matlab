function registry=getRegistryWithScope(h)

    if~isempty(h.SourceSystem)
        inlineTrace=coder.trace.getTraceInfo(h.SourceSystem);
    else
        inlineTrace=coder.trace.getTraceInfo(h.Model);
    end
    registry=h.getRegistry;
    for i=1:length(registry)
        for j=1:length(registry(i).location)
            if isempty(registry(i).location(j).scope)&&registry(i).location(j).column(1)>0
                [~,file,ext]=fileparts(registry(i).location(j).file);
                filename=[file,ext];
                registry(i).location(j).scope=inlineTrace.getFcnScope(filename,...
                registry(i).location(j).line,registry(i).location(j).column(1));
            end
        end
    end
    h.Registry=registry;
