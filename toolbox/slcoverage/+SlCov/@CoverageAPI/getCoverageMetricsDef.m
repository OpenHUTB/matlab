function description=getCoverageMetricsDef(covId,metricNames,varargin)



    try
        description={};
        if~cv('ishandle',covId)
            return;
        end
        cvd=[];
        if nargin>2
            cvd=varargin{1};
        end
        if numel(metricNames)>1
            desc=complexity_details(covId);
            description=addToDesc(description,desc);
        end
        for idx=1:numel(metricNames)
            desc=getOneMetricDef(covId,metricNames{idx},cvd);
            description=addToDesc(description,desc);
        end
    catch MEx
        rethrow(MEx);
    end


    function description=addToDesc(description,desc)
        if isempty(desc.totalCount)
            return;
        end
        if isempty(description)
            description=desc;
        else
            description(end+1)=desc;
        end



        function description=getDescrStruct
            description=struct('name',[],'totalCount',[],'localCount',[],'details',[],'executed',[]);

            function description=getOneMetricDef(blockCvId,metricName,cvd)

                metricEnum=cvi.MetricRegistry.getEnum(metricName);
                description=getDescrStruct;
                dataMat=[];
                if~isempty(cvd)&&isfield(cvd.metrics,metricName)
                    dataMat=cvd.metrics.(metricName);
                end

                switch metricName
                case 'decision'
                    description=decision_details(description,blockCvId,metricEnum,dataMat);
                case 'condition'
                    description=condition_details(description,blockCvId,metricEnum,dataMat);
                case 'mcdc'
                    description=mcdc_details(description,blockCvId,metricEnum);
                case 'tableExec'
                    description=table_details(description,blockCvId,metricEnum);
                case{'sigrange','sigsize'}
                    description=sigrange_details(description,blockCvId,metricEnum,metricName,dataMat);
                otherwise
                    description=testobjective_details(description,blockCvId,metricEnum,metricName);
                end

                function blockCvId=checkEMLBlockId(blockCvId)
                    if cv('get',blockCvId,'.code')~=0
                        blockCvId=cv('get',cv('get',blockCvId,'.treeNode.parent'),'.treeNode.parent');
                    end

                    function description=complexity_details(blockCvId)
                        blockCvId=checkEMLBlockId(blockCvId);
                        description=getDescrStruct;
                        allmetrics=cvi.MetricRegistry.getDDEnumVals;
                        cycloEnum=allmetrics.MTRC_CYCLCOMPLEX;
                        [totalCount,localCount]=cv('MetricGet',blockCvId,cycloEnum,'.dataCnt.deep','.dataCnt.shallow');

                        if isempty(totalCount)||(totalCount==0)
                            return;
                        end
                        description.name='complexity';
                        description.totalCount=totalCount;
                        description.localCount=localCount;
                        description.details=[];
                        description.cvIds=[];



                        function description=testobjective_details(description,blockCvId,testobjectiveEnum,metricName)
                            [testObjs,totalCount]=cv('MetricGet',blockCvId,testobjectiveEnum,'.baseObjs','.dataCnt.deep');
                            if isempty(totalCount)||(totalCount==0)
                                return;
                            end
                            txtDetail=1;

                            description.totalCount=totalCount;
                            description.cvIds=testObjs;
                            description.details=[];


                            for idx=1:numel(testObjs)
                                testObjId=testObjs(idx);
                                d=[];
                                d.text=cv('TextOf',testObjId,-1,[],txtDetail);
                                outcomes=cv('get',testObjId,'.dc.numOutcomes');
                                for i=1:outcomes
                                    out.text=cv('TextOf',testObjId,i-1,[],txtDetail);
                                    out.executionCount=0;
                                    if~isfield(d,'outcome')
                                        d.outcome=out;
                                    else
                                        d.outcome(end+1)=out;
                                    end
                                end
                                if isempty(description.details)
                                    description.details=d;
                                else
                                    description.details(end+1)=d;
                                end
                            end
                            description.name=metricName;


                            function description=sigrange_details(description,blockCvId,metricEnum,metricName,dataMat)
                                blockCvId=checkEMLBlockId(blockCvId);
                                metricIsa=cv('get','default','sigrange.isa');
                                [metricId,cvIsa]=cv('MetricGet',blockCvId,metricEnum,'.id','.isa');
                                if isempty(metricId)||(metricId==0)||(cvIsa~=metricIsa)
                                    return;
                                end
                                if~isempty(dataMat)
                                    [baseIdx,allWidths]=cv('get',metricId,'.cov.baseIdx','.cov.allWidths');
                                    lngth=sum(allWidths);
                                    mins=dataMat(baseIdx+(1:2:(2*lngth)));
                                    maxs=dataMat(baseIdx+(2:2:(2*lngth)));
                                    if mins<Inf||maxs>-Inf
                                        description.executed=1;
                                    end
                                end
                                description.name=metricName;
                                description.totalCount=2;
                                description.cvIds=[];
                                description.details=[];


                                function description=table_details(description,blockCvId,metricEnum)

                                    tables=cv('MetricGet',blockCvId,metricEnum,'.baseObjs');
                                    if isempty(tables)||(numel(tables)~=1)
                                        return;
                                    end

                                    description.name='tableExec';
                                    brkDims=cv('get',tables,'table.dimBrkSizes');
                                    intervalCnt=prod(brkDims+1);
                                    description.totalCount=intervalCnt;
                                    description.details=[];
                                    description.cvIds=tables;


                                    function description=mcdc_details(description,blockCvId,metricEnum)
                                        txtDetail=1;

                                        [mcdcentries,totalCount]=cv('MetricGet',blockCvId,metricEnum,'.baseObjs','.dataCnt.deep');
                                        if isempty(totalCount)||(totalCount==0)
                                            return;
                                        end

                                        description.name='mcdc';
                                        description.totalCount=totalCount;
                                        description.cvIds=mcdcentries;
                                        description.details=[];

                                        for mcdcId=mcdcentries(:)'
                                            mcdcEntry.text=cv('TextOf',mcdcId,-1,[],txtDetail);
                                            conditions=cv('get',mcdcId,'.conditions');

                                            for i=1:length(conditions)
                                                condId=conditions(i);
                                                condEntry.text=cv('TextOf',condId,-1,[],txtDetail);
                                                mcdcEntry.condition(i)=condEntry;
                                            end
                                            if isempty(description.details)
                                                description.details=mcdcEntry;
                                            else
                                                description.details(end+1)=mcdcEntry;
                                            end
                                        end



                                        function description=condition_details(description,blockCvId,metricEnum,dataMat)
                                            txtDetail=1;

                                            [conditions,totalCount]=cv('MetricGet',blockCvId,metricEnum,'.baseObjs','.dataCnt.deep');
                                            if isempty(totalCount)||(totalCount==0)
                                                return;
                                            end

                                            description.name='condition';
                                            description.totalCount=totalCount;
                                            description.cvIds=conditions;
                                            description.details=[];
                                            executed=[];
                                            for condId=conditions(:)'
                                                condEntry.text=cv('TextOf',condId,-1,[],txtDetail);
                                                if~isempty(dataMat)
                                                    [trueCountIdx,falseCountIdx]=cv('get',condId,'.coverage.trueCountIdx','.coverage.falseCountIdx');
                                                    condEntry.trueCounts=dataMat(trueCountIdx+1);
                                                    condEntry.falseoCnts=dataMat(falseCountIdx+1);
                                                    if condEntry.trueCounts>0||condEntry.falseCounts>0
                                                        executed=1;
                                                    end
                                                else
                                                    condEntry.trueCounts=0;
                                                    condEntry.falseoCnts=0;
                                                end

                                                if isempty(description.details)
                                                    description.details=condEntry;
                                                else
                                                    description.details(end+1)=condEntry;
                                                end
                                            end
                                            description.executed=executed;


                                            function description=decision_details(description,blockCvId,metricEnum,dataMat)

                                                [decisions,totalCount]=cv('MetricGet',blockCvId,metricEnum,'.baseObjs','.dataCnt.deep');

                                                if isempty(totalCount)||(totalCount==0)
                                                    return;
                                                end
                                                description.name='decision';
                                                description.totalCount=totalCount;
                                                description.cvIds=decisions;
                                                description.details=[];
                                                txtDetail=1;
                                                executed=[];
                                                for decId=decisions(:)'
                                                    d=[];
                                                    [outcomes,startIdx]=cv('get',decId,'.dc.numOutcomes','.dc.baseIdx');
                                                    d.text=cv('TextOf',decId,-1,[],txtDetail);
                                                    for i=1:outcomes

                                                        out.text=cv('TextOf',decId,i-1,[],txtDetail);
                                                        if~isempty(dataMat)
                                                            out.executionCount=dataMat(startIdx+i);
                                                            if out.executionCount>0
                                                                executed=1;
                                                            end
                                                        else
                                                            out.executionCount=0;
                                                        end
                                                        if~isfield(d,'outcome')
                                                            d.outcome=out;
                                                        else
                                                            d.outcome(end+1)=out;
                                                        end
                                                    end
                                                    if isempty(description.details)
                                                        description.details=d;
                                                    else
                                                        description.details(end+1)=d;
                                                    end
                                                end
                                                description.executed=executed;
