



function rollUpSubsystems(this,modelData,param)
    if param.mode

        mask.scope=param.subsystemUnits;
        mask.invert=true;
        mask.mode=0;
        for idx=1:numel(modelData)
            ccvd=modelData(idx).cvd;
            ccvd.traceOn=this.isTraceOn;
            if~isempty(mask.scope)&&...
                ~any(endsWith(mask.scope,ccvd.modelinfo.analyzedModel))
                maskedCvd=ccvd.applyMask(mask);
                this.results=cv.aggregation.addToResult(this.results,maskedCvd);
            else
                this.results=cv.aggregation.addToResult(this.results,ccvd);
            end
        end
    else

        subsysData={};
        for idx=1:numel(modelData)
            ccvd=modelData(idx).cvd;
            if contains(ccvd.modelinfo.analyzedModel,'/')
                subsysData{end+1}=modelData(idx);
            else
                this.results=cv.aggregation.addToResult(this.results,ccvd);
            end
        end
        values=this.results.values;
        for idx=1:numel(values)
            mcvd=values{idx}.cvd;
            mcvd.traceOn=true;
            for sidx=1:numel(subsysData)
                scvd=subsysData{sidx}.cvd;
                scvd.traceOn=this.isTraceOn;
                ncvd=mcvd.addSubsystem(scvd.modelinfo.analyzedModel,scvd);
                if~isempty(ncvd)
                    this.results=cv.aggregation.setResult(this.results,ncvd);
                    mcvd=ncvd;
                end
                this.results=cv.aggregation.addToResult(this.results,scvd);
            end
        end
    end
end

