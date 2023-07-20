function infoFromCSide=getVariantBlockInfoForVM(blockPath,optArgs)











    tmpVariantTransitionInfo=[];
    if Simulink.variant.utils.isSFChart(get_param(blockPath,'Handle'))
        chartInfo=Simulink.variant.utils.getSFObj(blockPath,Simulink.variant.utils.StateflowObjectType.CHART);
        if~isempty(chartInfo)
            chartId=chartInfo.Id;
            variantTransitionInfo=Stateflow.Variants.VariantMgr.getAllVariantConditionsInChart(chartId);
            if~isempty(variantTransitionInfo)

                getNumDigits=@(a)floor(log10(a)+1);
                nDigitsInMaxSSID=getNumDigits(variantTransitionInfo(end).SSIdNumber);

                tmpVariantTransitionInfo=rmfield(variantTransitionInfo,{'Params','TransitionHandle'});
                for i=1:numel(variantTransitionInfo)
                    nDigitsInSSID=getNumDigits(variantTransitionInfo(i).SSIdNumber);
                    spacePadding=repmat(' ',1,nDigitsInMaxSSID-nDigitsInSSID);
                    tmpVariantTransitionInfo(i).SSIdNumber=[spacePadding,num2str(variantTransitionInfo(i).SSIdNumber)];
                end
            end
        end
    end

    infoFromCSide=slInternal('getVariantBlockInfoForVM',blockPath,...
    optArgs.UseTempWS,optArgs.IgnoreErrors,optArgs.HotlinkErrors,...
    tmpVariantTransitionInfo);

    for i=1:numel(infoFromCSide)

        infoFromCSide(i).Name=Simulink.variant.utils.getNameFromRenderedName(infoFromCSide(i).Name);
    end
end


