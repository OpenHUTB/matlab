








function plotConeInSDI(expr,n,isContinuous,runID)

    if(isa(expr,'sltest.assessments.Expression'))
        expr=expr.internal;
    end

    if~(isa(expr,'sltest.assessments.internal.expression'))
        error(message('sltest:assessments:ExpectedArgumentType',1,'an expression'));
    end

    if nargin<2
        n=1;
    end
    if nargin<3
        isContinuous=true;
    end
    if nargin<4
        runID=-1;
    end

    nextFailure=true;
    k=n;
    if(n<0)
        if(runID~=-1)
            error('RunID can only be provide to report one failure');
        end
        k=1;
    end

    while nextFailure
        try
            r=expr.getConeData(k);
        catch
            error('Results does not have %d failures',n);
        end
        if(isempty(r))
            if(n<0)
                break;
            else
                error('Results does not have %d failures',n);
            end
        end
        failureTime=inf;
        for i=1:numel(r)
            failureTime=min(failureTime,r(i).Time(1));
        end
        if runID==-1
            runID=Simulink.sdi.createRun(sprintf('Expression Failure %d at time %f',k,failureTime));
        end
        parentMap=containers.Map;
        signalMap=containers.Map;
        sdiEngine=Simulink.sdi.Instance.engine;
        for i=1:numel(r)
            v=r(i).Value;
            addVerifyMetaData=false;
            if strcmp(r(i).Name,expr.stringLabel())&&~isempty(v)&&isa(v(1),'sltest.assessments.Logical')
                v=arrayfun(@LogicalToSlTestResult,v);
                addVerifyMetaData=true;
            end
            ts=timeseries(v,r(i).Time);
            ts.Name=r(i).Name;

            ts.DataInfo.Interpolation=tsdata.interpolation.createZOH;
            sigID=Simulink.sdi.addToRun(runID,'namevalue',{r(i).Name},{ts});
            signalMap(r(i).Name)=sigID;
            if(isfield(r(i),'Children'))
                if(~isempty(r(i).Children))
                    sdiEngine.setMetaDataV2(sigID,'ExpressionHasChildren',int32(1));
                end
                for k=1:numel(r(i).Children)
                    parentMap(r(i).Children{k})=sigID;
                end
            end
            if addVerifyMetaData
                sdiEngine.setMetaDataV2(sigID,'IsAssessment',int32(1));
                sdiEngine.setMetaDataV2(sigID,'AssessmentResult',int32(1));
                if(~isContinuous)
                    sdiEngine.sigRepository.setSignalIsEventBased(sigID,true);
                end
            end

            sdiEngine.setSignalLineColor(sigID,[1;0;0]);
        end
        sNames=parentMap.keys;
        sIds=parentMap.values;
        for k=1:numel(sNames)
            sdiEngine.setMetaDataV2(signalMap(sNames{k}),'ParentExpressionID',sIds{k});
        end
        if(n<0)
            k=k+1;
        else
            nextFailure=false;
        end
    end
end

function y=LogicalToSlTestResult(u)
    switch u
    case sltest.assessments.Logical.True
        y=slTestResult.Pass;
    case sltest.assessments.Logical.False
        y=slTestResult.Fail;
    case sltest.assessments.Logical.Untested
        y=slTestResult.Untested;
    end
end

