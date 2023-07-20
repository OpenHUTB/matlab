function allVariantBlockHs=getAllVariantAndModelBlocks(modelName,searchType)










    [ssBlockHs,ivAndModelBlockHs]=Simulink.variant.utils.getAllSubsystemModelAndIVBlocksInModel(modelName,searchType);

    variantSSBlockHs=[];
    variantSimulinkFunctionHs=[];
    variantIRTSubsystemHs=[];
    sfChartHs=[];
    for i=1:length(ssBlockHs)
        if strcmp(get_param(ssBlockHs(i),'Variant'),'on')
            variantSSBlockHs(end+1,1)=ssBlockHs(i);%#ok<*AGROW>
        elseif Simulink.variant.utils.isVariantSimulinkFunction(ssBlockHs(i))
            variantSimulinkFunctionHs(end+1,1)=ssBlockHs(i);%#ok<*AGROW>
        elseif Simulink.variant.utils.isVariantIRTSubsystem(ssBlockHs(i))
            variantIRTSubsystemHs(end+1,1)=ssBlockHs(i);
        elseif Simulink.variant.utils.isSFChart(ssBlockHs(i))
            sfChartHs(end+1,1)=ssBlockHs(i);
        end
    end




    allVariantBlockHs=[variantSSBlockHs;variantSimulinkFunctionHs;variantIRTSubsystemHs;sfChartHs;ivAndModelBlockHs];
end


