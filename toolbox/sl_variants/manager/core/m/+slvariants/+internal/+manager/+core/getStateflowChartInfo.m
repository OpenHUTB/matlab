function chartInfoStruct=getStateflowChartInfo(blockPath)











    if~strcmp('none',get_param(blockPath,'StaticLinkStatus'))


        blockPath=get_param(blockPath,'ReferenceBlock');
    end
    sfRoot=sfroot;
    chartInfo=sfRoot.find('-isa','Stateflow.Chart','Path',blockPath);
    if isempty(chartInfo)
        chartInfoStruct=struct([]);
        return;
    end
    chartInfoStruct.ActionLanguage=chartInfo.ActionLanguage;
    chartInfoStruct.Id=chartInfo.Id;
    chartInfoStruct.GeneratePreprocessorConditionals=chartInfo.GeneratePreprocessorConditionals;
end


