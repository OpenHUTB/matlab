function addTestobjectiveData(this,toMetricNames,allTests)




    for idxM=1:numel(toMetricNames)
        metricName=toMetricNames{idxM};
        numOfRows=findSize(allTests,metricName);
        metric=zeros(numOfRows,numel(allTests));
        for idxT=1:numel(allTests)
            cm=allTests{idxT}.metrics.testobjectives.(metricName);
            if~isempty(cm)
                metric(:,idxT)=cm;
            end
        end
        this.testobjectiveData.(metricName)=metric;
    end
end

function size=findSize(allTests,metricName)
    for i=1:numel(allTests)
        if~isempty(allTests{i}.metrics.testobjectives.(metricName))
            size=numel(allTests{i}.metrics.testobjectives.(metricName));
        end
    end
end