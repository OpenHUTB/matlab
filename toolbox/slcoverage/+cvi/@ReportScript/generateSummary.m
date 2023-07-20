
function generateSummary(this,options)




    this.generateString=true;
    htmlData=[];
    if numel(this.allTests)>1&&~options.cumulativeReport
        total=this.allTests{1};
        for i=2:length(this.allTests)
            total=total+this.allTests{i};
        end
        this.allTests{i+1}=total;
    end
    testIds=[this.allTests{:}];
    this.cvstruct=cvprivate('report_create_structured_data',this.allTests,testIds,this.metricNames,this.toMetricNames,options,this.waitbarH);

    this.cvstruct.testLabels={''};

    if~isempty(this.metricNames)||~isempty(this.toMetricNames);
        dumpStructuralCoverage(this,options);
        options.summaryHtml=this.htmlStr;
    end

