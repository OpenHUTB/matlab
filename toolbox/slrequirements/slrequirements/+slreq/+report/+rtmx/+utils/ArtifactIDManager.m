classdef ArtifactIDManager<handle
    properties(Access=private)
ArtifactToIDMap
        CurrentArtifactID;

    end

    methods(Access=private)
        function this=ArtifactIDManager()
            this.ArtifactToIDMap=containers.Map('KeyType','char','ValueType','double');
            this.CurrentArtifactID=1;
        end

        function addArtifactToMap(this,artifactFullPath)
            if~isKey(this.ArtifactToIDMap,artifactFullPath)
                this.CurrentArtifactID=getNextPrime(this.CurrentArtifactID+1);
                this.ArtifactToIDMap(artifactFullPath)=this.CurrentArtifactID;
            end
        end
    end
    methods(Static)
        function this=getInstance(doesReset)
            persistent cachedObj
            if doesReset
                clear cachedObj;
            end

            if isempty(cachedObj)
                cachedObj=slreq.report.rtmx.utils.ArtifactIDManager();
            end

            this=cachedObj;
        end

        function out=getArtifactID(artifactFullPath)
            if isempty(artifactFullPath)
                out=0;
                return;
            end

            artifactMgr=slreq.report.rtmx.utils.ArtifactIDManager.getInstance();
            if~isKey(artifactMgr.ArtifactToIDMap,artifactFullPath)
                artifactMgr.addArtifactToMap(artifactFullPath);
            end
            out=artifactMgr.ArtifactToIDMap(artifactFullPath);
        end
    end
end

function out=getNextPrime(currentNum)
    out=currentNum;
    if currentNum<3
        out=2;
        return;
    end

    if rem(out,2)==0

        out=out+1;
    end
    while~isprime(out)
        out=out+2;
    end
end
