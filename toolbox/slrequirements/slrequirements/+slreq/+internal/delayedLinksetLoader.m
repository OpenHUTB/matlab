function result=delayedLinksetLoader(method,artifactPath)























    persistent delayedArtifacts isReady
    if isempty(isReady)
        reset();
    end

    switch method

    case 'count'
        result=double(delayedArtifacts.Count);

    case 'check'
        result=isKey(delayedArtifacts,artifactPath);

    case 'delay'


        if~slreq.data.ReqData.exists()||isempty(slreq.find('type','LinkSet','Artifact',artifactPath))
            delayedArtifacts(artifactPath)=method;
            result=true;
        else
            result=false;
        end

    case 'remove'
        if isKey(delayedArtifacts,artifactPath)
            delayedArtifacts.remove(artifactPath);
            result=true;
        else
            result=false;
        end

    case 'load'


        artifacts=delayedArtifacts.keys();
        loaded=0;
        for i=1:length(artifacts)
            loaded=loaded+slreq.utils.loadLinkSet(artifacts{i});
        end

        result=loaded;

    case 'reset'
        result=~isempty(delayedArtifacts);
        reset();

    otherwise
        error('unsupported method: %s',method);
    end


    function reset()
        delayedArtifacts=containers.Map('KeyType','char','ValueType','char');
        isReady=true;
    end
end

