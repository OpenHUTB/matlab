function[selectors,isVarTrans]=createSFVariantFilterRuleSelectors(modelcovId,activeRoot,testId)



    try
        selectors={};
        isVarTrans={};

        if~sf('feature','Stateflow Variants')||~strcmpi(cv('Feature','SFVariants'),'on')
            return;
        end

        if nargin<2||isempty(activeRoot)
            activeRoot=cv('get',modelcovId,'.activeRoot');
        end

        if nargin<3
            testId=[];
        end

        if~isempty(testId)
            cvd=cvdata(testId);
        else
            cvd=[];
        end

        sfIsa.state=sf('get','default','state.isa');
        sfIsa.trans=sf('get','default','transition.isa');
        sfIsa.chart=sf('get','default','chart.isa');

        topCvId=cv('get',activeRoot,'.topSlsf');
        mixedIds=cv('DecendentsOf',topCvId);
        allChartCvId=cv('find',mixedIds,'slsfobj.origin',2,'slsfobj.refClass',sfIsa.chart);
        inactiveCalledComponents=[];
        for idxC=1:numel(allChartCvId)
            cvChartId=allChartCvId(idxC);

            chartId=cv('get',cvChartId,'.handle');
            chartBlockH=get_param(cv('get',cvChartId,'.origPath'),'handle');

            if~Stateflow.Utils.chartHasVariantTransitions(chartBlockH)||...
                ~isempty(find(inactiveCalledComponents,cvChartId))
                continue;
            end

            mixedIds=cv('FindDescendantsUntil',cvChartId,sfIsa.chart);

            cvStateIds=cv('find',mixedIds,'slsfobj.origin',2,'slsfobj.refClass',sfIsa.state);
            [selectors,inactiveCalledComponents,isVarTrans]=processStates(selectors,inactiveCalledComponents,chartBlockH,cvStateIds,sfIsa,isVarTrans,cvd);

            cvTransIds=cv('find',mixedIds,'slsfobj.origin',2,'slsfobj.refClass',sfIsa.trans);
            [selectors,isVarTrans]=processTransitons(selectors,chartBlockH,cvTransIds,isVarTrans,cvd);
            [selectors,isVarTrans]=processSubstates(selectors,chartBlockH,cvChartId,chartId,~Sldv.utils.isAtomicSubchartSubsystem(chartBlockH),isVarTrans,cvd);
        end
    catch MEx
        rethrow(MEx);
    end
end


function[selectors,isVarTrans]=addCharts(selectors,cvIds,isVarTrans,cvd)
    for idx=1:numel(cvIds)
        cvId=cvIds(idx);
        sid=cvi.TopModelCov.getSID(cvId);
        if~isempty(cvd)
            sid=cvd.mapFromHarnessSID(sid);
        end
        so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.StateAllContent,sid);
        selectors{end+1}=so;
        isVarTrans{end+1}=false;
    end
end


function[selectors,isVarTrans]=addStates(selectors,cvIds,isVarTrans,cvd)
    for idx=1:numel(cvIds)
        cvId=cvIds(idx);
        sid=cvi.TopModelCov.getSID(cvId);
        if~isempty(cvd)
            sid=cvd.mapFromHarnessSID(sid);
        end
        so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.State,sid);
        selectors{end+1}=so;
        isVarTrans{end+1}=false;
    end
end


function[selectors,isVarTrans]=addTransitions(selectors,cvIds,isVarTrans,varTran,cvd)
    for idx=1:numel(cvIds)
        cvId=cvIds(idx);
        sid=cvi.TopModelCov.getSID(cvId);
        if~isempty(cvd)
            sid=cvd.mapFromHarnessSID(sid);
        end
        so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.Transition,sid);
        selectors{end+1}=so;
        isVarTrans{end+1}=varTran;
    end
end


function[selectors,inactiveCalledComponents,isVarTrans]=processStates(selectors,inactiveCalledComponents,chartBlockH,cvStateIds,sfIsa,isVarTrans,cvd)
    for idx=1:numel(cvStateIds)
        cvId=cvStateIds(idx);
        sfId=cv('get',cvId,'.handle');
        ssIdNumber=sf('get',sfId,'.ssIdNumber');
        componentH=sf('get',sfId,'state.simulink.blockHandle');

        if ishandle(componentH)&&...
            ~Stateflow.Utils.isEnabledInCurrentVariantConfig(chartBlockH,ssIdNumber)

            if Sldv.utils.isAtomicSubchartSubsystem(componentH)
                aMixedIds=cv('DecendentsOf',cvId);
                inactiveCharts=cv('find',aMixedIds,'slsfobj.origin',2,'slsfobj.refClass',sfIsa.chart);
                inactiveCalledComponents=[inactiveCalledComponents,inactiveCharts];

                [selectors,isVarTrans]=addCharts(selectors,inactiveCharts,isVarTrans);

                sid=cvi.TopModelCov.getSID(cvId);
                if~isempty(cvd)
                    sid=cvd.mapFromHarnessSID(sid);
                end
                so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.StateAllContent,sid);
                selectors{end+1}=so;
                isVarTrans{end+1}=false;
                continue;
            else

                sid=Simulink.ID.getSID(componentH);
                if~isempty(cvd)
                    sid=cvd.mapFromHarnessSID(sid);
                end
                so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.SubsystemAllContent,sid);
                selectors{end+1}=so;
                isVarTrans{end+1}=false;
            end
        end


        if cv('get',cvId,'.code')~=0
            isEnabled=Stateflow.Utils.isEnabledInCurrentVariantConfig(chartBlockH,ssIdNumber);
            if~isEnabled
                [selectors,isVarTrans]=addStates(selectors,cvId,isVarTrans,cvd);
            else

                [selectors,isVarTrans]=processSubstates(selectors,chartBlockH,cvId,sfId,false,isVarTrans,cvd);
            end
        end
    end
end


function[selectors,isVarTrans]=processSubstates(selectors,chartBlockH,cvId,parentState,isChart,isVarTrans,cvd)
    substates=sf('SubstatesOfInSortedOrder',parentState);
    if isempty(substates)
        return;
    end
    metricEnum=cvi.MetricRegistry.getEnum('decision');
    decisions=cv('MetricGet',cvId,metricEnum,'.baseObj');


    if isChart
        cvId=cv('get',cvId,'.treeNode.parent');
    end
    ssid=cvi.TopModelCov.getSID(cvId);
    if~isempty(cvd)
        ssid=cvd.mapFromHarnessSID(ssid);
    end

    for sIdx=1:numel(substates)
        ssIdNumber=sf('get',substates(sIdx),'.ssIdNumber');
        isEnabled=Stateflow.Utils.isEnabledInCurrentVariantConfig(chartBlockH,ssIdNumber);
        if~isEnabled
            for dIdx=1:numel(decisions)
                so=slcoverage.MetricSelector(slcoverage.MetricSelectorType.DecisionOutcome,ssid,dIdx,sIdx);
                selectors{end+1}=so;%#ok<AGROW>
                isVarTrans{end+1}=false;
            end
        end
    end
end


function[selectors,isVarTrans]=processTransitons(selectors,chartBlockH,cvTransIds,isVarTrans,cvd)
    for idx=1:numel(cvTransIds)
        cvId=cvTransIds(idx);
        if~isempty(cv('get',cvId,'.metrics'))
            sfId=cv('get',cvId,'.handle');
            ssIdNumber=sf('get',sfId,'.ssIdNumber');
            isEnabled=Stateflow.Utils.isEnabledInCurrentVariantConfig(chartBlockH,ssIdNumber);
            isVariant=sf('get',sfId,'.isVariant');
            if isVariant
                [selectors,isVarTrans]=addTransitions(selectors,cvId,isVarTrans,true,cvd);
            elseif~isEnabled
                [selectors,isVarTrans]=addTransitions(selectors,cvId,isVarTrans,false,cvd);
            end
        end
    end
end
