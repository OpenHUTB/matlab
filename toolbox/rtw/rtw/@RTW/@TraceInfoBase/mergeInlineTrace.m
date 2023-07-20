function mergeInlineTrace(h)

    if h.inlineTraceIsMerged,return,end

    h.inlineTraceIsMerged=true;

    if isempty(h.Registry),return,end
    registry=h.Registry;
    if~isempty(h.SourceSystem)
        inlineTrace=coder.trace.getTraceInfo(h.SourceSystem);
    else
        inlineTrace=coder.trace.getTraceInfo(h.Model);
    end
    if~isempty(inlineTrace)


        fileMap=cell(1,length(inlineTrace.files));
        files=inlineTrace.files;
        for i=1:length(inlineTrace.files)
            fileMap{i}=fullfile(inlineTrace.buildDir,files{i});
        end
        for i=length(registry):-1:1
            if~isempty(inlineTrace.sourceSubsysSID)
                sids{i}=[h.TmpModel,Simulink.ID.getSubsystemBuildSID(registry(i).sid,inlineTrace.sourceSubsysSID)];
            else
                sids{i}=registry(i).sid;
            end
        end
        m2c=inlineTrace.getSIDToCodeLocations(sids);
        for i=1:length(m2c)
            if isempty(m2c(i).tokens)
                continue;
            end
            registry(i)=coder.internal.mergeCodeLocation(registry(i),m2c(i),fileMap);
        end
        h.Registry=registry;
    end

