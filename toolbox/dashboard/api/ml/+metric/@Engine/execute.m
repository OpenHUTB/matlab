function execute(obj,metricIDs,varargin)

    p=inputParser;
    p.addRequired('MetricIDs',@isCellOrString);
    p.addParameter('ArtifactScope',{},@isCellOrString);
    parse(p,metricIDs,varargin{:});

    metricIDs=p.Results.MetricIDs;

    if ischar(metricIDs)
        metricIDs={metricIDs};
    elseif isstring(metricIDs)
        metricIDs=cellstr(metricIDs);
    end


    obj.throwIfDirtyArtifacts();

    artUUID=obj.getUUIDFromAddress(p.Results.ArtifactScope,true);

    es=metric.internal.ExecutionService.get(obj.ProjectPath);
    l=addlistener(es,'UserNotificationEvent',...
    obj.getUserMessageHandler());%#ok<NASGU>

    if~isempty(metricIDs)


        if isempty(artUUID)
            es.execute(metricIDs);
        else
            es.execute(metricIDs,artUUID);
        end
    end
end

function o=isCellOrString(v)
    o=iscellstr(v)||ischar(v)||isstring(v);
end
