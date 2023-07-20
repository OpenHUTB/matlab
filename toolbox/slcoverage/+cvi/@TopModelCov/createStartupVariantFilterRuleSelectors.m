function selectors=createStartupVariantFilterRuleSelectors(modelH,testId)



    try
        selectors={};
        findBlks=@(mdl,matchFilter)find_system(mdl,...
        'FollowLinks','on','MatchFilter',matchFilter,...
        'LookUnderMasks','all',...
        'DisableCoverage','off');

        allActiveBlks=findBlks(modelH,@Simulink.match.activeVariants);
        allStartupBlks=findBlks(modelH,@Simulink.match.startupVariants);



        nonActiveStartupBlks=setdiff(allStartupBlks,allActiveBlks);

        mapInactiveCvIdToBlks=containers.Map('KeyType','double','ValueType','double');

        for idx=1:length(nonActiveStartupBlks)
            currentBlk=nonActiveStartupBlks(idx);
            covIdCurrentBlk=get_param(currentBlk,'coverageId');

            if covIdCurrentBlk==0
                continue;
            end

            desendents=cv('DecendentsOf',covIdCurrentBlk);

            if~mapInactiveCvIdToBlks.isKey(covIdCurrentBlk)
                mapInactiveCvIdToBlks(covIdCurrentBlk)=currentBlk;
                for jdx=1:length(desendents)
                    mapInactiveCvIdToBlks(desendents(jdx))=0;
                end
            end
        end

        inactiveBlksToFilter=mapInactiveCvIdToBlks.values;

        cvd=cvdata(testId);

        for idx=1:length(inactiveBlksToFilter)
            currentBlk=inactiveBlksToFilter(idx);
            currentBlk=currentBlk{1};
            if currentBlk==0
                continue;
            end
            sid=Simulink.ID.getSID(currentBlk);
            if~isempty(cvd)
                sid=cvd.mapFromHarnessSID(sid);
            end

            if strcmp(get_param(currentBlk,'type'),'block')&&strcmp(get_param(currentBlk,'blockType'),'SubSystem')
                chartID=isChart(currentBlk);
                if~isempty(chartID)
                    if sf('Private','is_eml_chart',chartID)||sf('Private','is_truth_table_chart',chartID)
                        so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.BlockInstance,sid);
                    else
                        so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.Chart,sid);
                    end
                else
                    so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.SubsystemAllContent,sid);
                end
            else
                so=slcoverage.BlockSelector(slcoverage.BlockSelectorType.BlockInstance,sid);
            end
            selectors{end+1}=so;%#ok<AGROW>
        end
    catch MEx
        rethrow(MEx);
    end
end


function chartId=isChart(blockH)
    chartId=[];
    if Stateflow.SLUtils.isStateflowBlock(blockH)
        chartId=sfprivate('block2chart',blockH);
    end
end
