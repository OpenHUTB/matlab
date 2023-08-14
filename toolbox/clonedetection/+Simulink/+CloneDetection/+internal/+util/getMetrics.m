function metricsData=getMetrics(clonesRawData)





    metricsData=struct;
    reuseTitleTexts=containers.Map('KeyType','char','ValueType','char');
    keySet={'overAllPotentialReuse','exactPotentialReuse','similarPotentialReuse'};
    valueSet={'Overall','Exact','Similar'};
    reuseTitleTexts=containers.Map(keySet,valueSet);

    if clonesRawData.cloneDetectionStatus
        metricsTypes=fieldnames(clonesRawData.metrics);
        for i=1:length(metricsTypes)
            percentage=round((clonesRawData.metrics.(metricsTypes{i})/clonesRawData.totalBlocks)*100);
            metricsData.(reuseTitleTexts(metricsTypes{i}))=percentage;
        end

        metricsData.Overall=metricsData.Exact+metricsData.Similar;
    end
end
