function flag=cannot_apply_filter(sldvData)




    flag=(Sldv.DataUtils.isXilSldvData(sldvData)&&...
    ~strcmp(sldvData.AnalysisInformation.Options.Mode,'TestGeneration'))||...
    strcmp(sldvData.AnalysisInformation.Options.Mode,'PropertyProving')||...
    Sldv.utils.isSldvAnalysisRunning(sldvData.ModelInformation.Name);
end