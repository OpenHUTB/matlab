function[filteredConditions,filteredDecisions,numFilteredMCDCEntries]=cv_filter_object(cvId,metricNames)




    persistent sfIsa;

    filteredDecisions=[];
    filteredConditions=[];
    numFilteredMCDCEntries=0;
    condEnable=false;
    decEnable=false;
    mcdcEnable=false;
    for(metric=metricNames(:)')
        if(strcmp(metric,'condition'))
            condEnable=true;
        elseif(strcmp(metric,'decision'))
            decEnable=true;
        elseif(strcmp(metric,'mcdc'))
            mcdcEnable=true;
        end
    end



    if isempty(sfIsa)
        sfIsa.trans=sf('get','default','trans.isa');
        sfIsa.state=sf('get','default','state.isa');
        sfIsa.junction=sf('get','default','junction.isa');
        sfIsa.port=sf('get','default','port.isa');
        sfIsa.data=sf('get','default','data.isa');
        sfIsa.chart=sf('get','default','chart.isa');
    end

    [origin,refClass,sfId]=cv('get',cvId,'.origin','.refClass','.handle');

    if origin==2
        switch(refClass)
        case sfIsa.chart
            sf('Parse',sfId);
        case sfIsa.trans

            decisions=cv('MetricGet',cvId,cvi.MetricRegistry.getEnum('decision'),'.baseObjs');
            conditions=cv('MetricGet',cvId,cvi.MetricRegistry.getEnum('condition'),'.baseObjs');

            transitionParsedStruct=sf('TransitionParsedStruct',sfId);
            isTriggered=transitionParsedStruct.isTriggered;
            label=sf('get',sfId,'.labelString');

            if isTriggered







                eventCnt=cvEventParser(label);

                if eventCnt==1
                    if isempty(conditions)
                        if(decEnable)
                            filteredDecisions=decisions(1);
                        end
                    else
                        if(condEnable)
                            filteredConditions=conditions(1);
                        end
                    end
                else
                    if~isempty(conditions)
                        if(eventCnt>length(conditions)&&condEnable)
                            error(message('Slvnv:simcoverage:cv_filter_object:NoConditions'));
                        end
                        if(condEnable)
                            filteredConditions=conditions(1:eventCnt);
                        end
                    end
                    if(eventCnt==length(conditions))
                        if(decEnable)
                            filteredDecisions=decisions(1);
                        end
                    end
                end
                if mcdcEnable
                    numFilteredMCDCEntries=eventCnt;
                end

            end
        end
    end
