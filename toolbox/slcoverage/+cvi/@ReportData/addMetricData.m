function addMetricData(this,metricName,allTests)




    numOfRows=findSize(allTests,metricName);
    metric=zeros(numOfRows,numel(allTests));
    if strcmpi(metricName,'tableExec')
        for i=1:length(allTests)
            this.metricData.tableExec.dataObjs{i}=allTests{i};
            cm=allTests{i}.metrics.tableExec;
            if~isempty(cm)
                metric(:,i)=cm;
            end
        end
        this.metricData.tableExec.rawData=metric;
    else
        for i=1:length(allTests)
            cm=allTests{i}.metrics.(metricName);
            if~isempty(cm)
                metric(:,i)=cm;
            end
        end
        this.metricData.(metricName)=metric;
    end
end

function size=findSize(allTests,metricName)
    for i=1:numel(allTests)
        if~isempty(allTests{i}.metrics.(metricName))
            size=numel(allTests{i}.metrics.(metricName));
        end
    end
end