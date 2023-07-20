
function filtObjs=getFilteredMetricsBySubProp(filter,cvid,ssid)




    try
        filtObjs=[];
        if cv('get',cvid,'.origin')==2
            filtObjs=getStateflowEventObj(filtObjs,filter,cvid,ssid);
        end
        if isempty(filtObjs)
            filtObjs=getFilteredObjs(filtObjs,filter,cvid,ssid);
        end
    catch MEx
        rethrow(MEx);
    end


    function filtObjs=getFilteredObjs(filtObjs,filter,cvid,ssid)
        if filter.hasMetricProp
            metricNames=SlCov.FilterEditor.getSupportedMetricNames;
            for idx=1:numel(metricNames)
                filtObjs=getMetricObjs(filtObjs,filter,metricNames{idx},cvid,ssid);
            end
        end

        function tfObjs=getFilterObjDescStruct()
            tfObjs.objs=[];
            tfObjs.idx=[];
            tfObjs.objectiveModes={};
            tfObjs.rationale={};
            tfObjs.outcomeIdx={};
            tfObjs.outcomeModes={};
            tfObjs.outcomeRationale={};
            tfObjs.selectorType={};

            function filtObjs=getMetricObjs(filtObjs,filter,metricName,cvid,ssid)
                metricEnum=cvi.MetricRegistry.getEnum(metricName);
                dObjs=cv('MetricGet',cvid,metricEnum,'.baseObjs');
                if isempty(dObjs)||isempty(ssid)
                    return;
                end

                [res,propInstance]=filter.isFilteredByMetric(ssid,metricName);

                if~res&&Simulink.ID.isValid(ssid)

                    h=Simulink.ID.getHandle(ssid);


                    ssid=cvi.TopModelCov.getSID(cvid);
                    [res,propInstance]=filter.isFilteredByMetric(ssid,metricName);


                    if isa(h,'Stateflow.Transition')
                        sfId=h.Id;
                        if sf('Private','is_truth_table_fcn',sf('get',sfId,'.parent'))
                            ssid=Simulink.ID.getParent(Simulink.ID.getSID(h));
                            [res,propInstance]=filter.isFilteredByMetric(ssid,metricName);
                        end
                    end

                    if~res
                        h=Simulink.ID.getHandle(ssid);
                        try
                            libSid=Simulink.ID.getLibSID(h);
                        catch MEx %#ok<NASGU>
                            libSid='';
                        end

                        if~isempty(libSid)&&Simulink.ID.isValid(libSid)
                            h=Simulink.ID.getHandle(libSid);
                            ssid=Simulink.ID.getSID(h);
                            [res,propInstance]=filter.isFilteredByMetric(ssid,metricName);
                        end
                    end
                end
                if~res
                    return;
                end

                tfObjs=getFilterObjDescStruct;
                for iidx=1:numel(propInstance.value)
                    value=propInstance.value(iidx);
                    tfObjs=addToStruct(tfObjs,dObjs,value);
                end
                filtObjs.(metricName)=tfObjs;

                function tfObjs=addToStruct(tfObjs,dObjs,value)
                    if numel(dObjs)<value.idx
                        return;
                    end
                    fidx=find(tfObjs.idx==value.idx);
                    if isempty(fidx)
                        tfObjs.objs=[tfObjs.objs,dObjs(value.idx)];
                        tfObjs.idx=[tfObjs.idx,value.idx];

                        if isempty(value.outcomeIdx)
                            tfObjs.objectiveModes=[tfObjs.objectiveModes,{value.mode}];
                            tfObjs.rationale=[tfObjs.rationale,{value.rationale}];
                            tfObjs.outcomeIdx=[tfObjs.outcomeIdx,{[]}];
                            tfObjs.outcomeModes=[tfObjs.outcomeModes,{[]}];
                            tfObjs.outcomeRationale=[tfObjs.outcomeRationale,{{}}];
                            tfObjs.selectorType=[tfObjs.selectorType,{value.selectorType}];
                        else
                            tfObjs.objectiveModes=[tfObjs.objectiveModes,{[]}];
                            tfObjs.rationale=[tfObjs.rationale,{[]}];
                            tfObjs.outcomeIdx=[tfObjs.outcomeIdx,{value.outcomeIdx}];
                            tfObjs.outcomeModes=[tfObjs.outcomeModes,{value.mode}];
                            tfObjs.outcomeRationale=[tfObjs.outcomeRationale,{{value.rationale}}];
                            tfObjs.selectorType=[tfObjs.selectorType,{value.selectorType}];
                        end
                    else
                        if isempty(value.outcomeIdx)
                            tfObjs.objectiveModes{fidx}=value.mode;
                            tfObjs.rationale{fidx}=value.rationale;
                            tfObjs.selectorType{fidx}=value.selectorType;
                        else
                            tfObjs.outcomeIdx{fidx}=[tfObjs.outcomeIdx{fidx},value.outcomeIdx];
                            tfObjs.outcomeModes{fidx}=[tfObjs.outcomeModes{fidx},value.mode];
                            tfObjs.outcomeRationale{fidx}=[tfObjs.outcomeRationale{fidx},{value.rationale}];
                            tfObjs.selectorType{fidx}=[tfObjs.selectorType{fidx},value.selectorType];
                        end
                    end


                    function filtObjs=getStateflowEventObj(filtObjs,filter,cvid,ssid)

                        isState=cv('get',cvid,'.refClass')==sf('get','default','state.isa');
                        isTransitions=cv('get',cvid,'.refClass')==sf('get','default','transition.isa');
                        if~isState&&~isTransitions
                            return;
                        end
                        [res,subProps]=filter.isFilteredBySubProp(ssid);
                        if~res
                            return;
                        end
                        condObjs=[];
                        if isTransitions
                            metricEnum=cvi.MetricRegistry.getEnum('condition');
                            condObjs=cv('MetricGet',cvid,metricEnum,'.baseObjs');
                        end
                        metricEnum=cvi.MetricRegistry.getEnum('decision');
                        decObjs=cv('MetricGet',cvid,metricEnum,'.baseObjs');
                        if isempty(condObjs)&&isempty(decObjs)
                            return;
                        end
                        filtObjs=[];

                        if isState
                            [fObjs,objIdx,mode,rationale,selectorType]=checkSfEvents(decObjs,subProps,'MSG_SF_STATE_ON_DECISION');
                            tfObjs=getFilterObjDescStruct;









                            if numel(fObjs)==numel(decObjs)
                                tfObjs=getFilterObjDescStruct;
                                tfObjs.mode=mode(end);
                                tfObjs.objs=cvid;
                                tfObjs.rationale=rationale(end);
                                tfObjs.selectorType=selectorType(end);
                                filtObjs.slslf=tfObjs;
                            end
                            tfObjs.objs=fObjs;
                            tfObjs.mode=mode;
                            tfObjs.idx=objIdx;
                            tfObjs.rationale=rationale;
                            tfObjs.selectorType=selectorType;
                            filtObjs.decision=tfObjs;
                        elseif isTransitions

                            if isempty(condObjs)
                                if checkFilteredProp(cv('GetSlsfName',cvid),subProps)
                                    tfObjs=getFilterObjDescStruct;

                                    tfObjs.idx=1;
                                    tfObjs.rationale={subProps.Rationale};
                                    tfObjs.mode=subProps.mode;
                                    tfObjs.selectorType=subProps.selectorType;
                                    filtObjs.decision=tfObjs;

                                    tfObjs=getFilterObjDescStruct;
                                    tfObjs.objs=cvid;
                                    tfObjs.mode=subProps.mode;
                                    tfObjs.rationale={subProps.Rationale};
                                    tfObjs.selectorType=subProps.selectorType;
                                    filtObjs.slsf=tfObjs;
                                end
                            else
                                [fObjs,objIdx,mode,rationale,selectorType]=checkSfEvents(condObjs,subProps,'MSG_SF_TRANS_PRED');


                                tfObjs=getFilterObjDescStruct;
                                if numel(fObjs)==numel(condObjs)-1
                                    tfObjs.objs=condObjs;
                                    tfObjs.mode=[mode,mode(end)];
                                    tfObjs.idx=1:numel(condObjs);
                                    tfObjs.rationale=[rationale,rationale(end)];
                                    tfObjs.selectorType=[selectorType,selectorType(end)];
                                else
                                    tfObjs.objs=fObjs;
                                    tfObjs.idx=objIdx;
                                    tfObjs.mode=mode;
                                    tfObjs.rationale=rationale;
                                    tfObjs.selectorType=selectorType;
                                end
                                filtObjs.condition=tfObjs;
                            end
                        end


                        function res=checkFilteredProp(eventName,subProps)
                            res=false;
                            for sidx=1:numel(subProps)
                                if strcmpi(eventName,subProps(sidx).value.name)
                                    res=true;
                                    return;
                                end
                            end


                            function[filtObjs,objIdx,mode,rationale,selectorType]=checkSfEvents(objs,subProps,msg)
                                rationale=[];
                                mode=[];
                                filtObjs=[];
                                objIdx=[];
                                selectorType=[];
                                if isempty(objs)
                                    return;
                                end
                                msgtype=cvprivate('get_formatter_of_type',msg);

                                for idx=1:numel(objs)
                                    obj=objs(idx);
                                    descr=cv('get',obj,'.descriptor');
                                    if msgtype==cv('get',descr,'.formatter')
                                        if checkFilteredProp(cv('get',descr,'.txtParams'),subProps)
                                            filtObjs(end+1)=obj;%#ok<AGROW>
                                            mode(end+1)=subProps.mode;%#ok<AGROW>
                                            objIdx(end+1)=idx;%#ok<AGROW>
                                            rationale{end+1}=subProps.Rationale;%#ok<AGROW>
                                            selectorType(end+1)=subProps.selectorType;%#ok<AGROW>
                                        end
                                    end
                                end


