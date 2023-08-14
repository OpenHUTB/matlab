


function sfVariantBlks=getSFVariantBlks(mdlAndItsBlks)
    sfVariantBlks=[];
    for modelIdx=1:length(mdlAndItsBlks)
        allBlks=mdlAndItsBlks(modelIdx).Blocks;
        for blkIdx=1:numel(allBlks)
            blkH=getSimulinkBlockHandle(allBlks{blkIdx});
            if(blkH<0)
                continue;
            end
            if~Simulink.variant.utils.isSFChart(blkH)
                continue;
            end
            chartInfo=Simulink.variant.utils.getSFObj(allBlks{blkIdx},Simulink.variant.utils.StateflowObjectType.CHART);
            if isempty(chartInfo)
                continue;
            end

            chartId=chartInfo.Id;
            varTransInfo=Stateflow.Variants.VariantMgr.getAllVariantConditionsInChart(chartId);
            if isempty(varTransInfo)
                continue;
            end
            sfVariantBlks(end+1)=blkH;%#ok<AGROW>
        end
    end
end
