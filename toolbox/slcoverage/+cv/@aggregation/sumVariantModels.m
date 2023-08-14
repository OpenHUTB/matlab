



function sumVariantModels(this,modelData,param)

    if param.mode
        toCutMap=containers.Map('KeyType','char','ValueType','any');

        for idx=1:numel(modelData)
            ccvd=modelData(idx).cvd;
            if isempty(ccvd.getRootVariantStates)
                continue;
            end

            vs=ccvd.getRootVariantStates();
            for vidx=1:numel(vs)
                path=vs(vidx).path;
                state=vs(vidx).state;
                if toCutMap.isKey(path)
                    cValue=toCutMap(path);
                    toCutMap(path)=cValue+state;
                else
                    toCutMap(path)=state;
                end
            end
        end
        if isempty(toCutMap)
            return;
        end
        alltoCutMap=toCutMap.keys;
        numberofData=numel(modelData);
        for didx=1:numel(modelData)
            scvd=modelData(didx).cvd;
            for cidx=1:numel(alltoCutMap)
                subsysPath=alltoCutMap{cidx};
                cValue=toCutMap(subsysPath);
                if cValue~=numberofData
                    ucvd=scvd.extract(subsysPath);
                    if~isempty(ucvd)
                        this.results=cv.aggregation.addToResult(this.results,ucvd);
                    end
                    tscvd=scvd.cutSubsystem(subsysPath);
                    if~isempty(tscvd)
                        scvd=tscvd;
                    end
                end
            end
            this.results=cv.aggregation.addToResult(this.results,scvd);
        end
    end
end
