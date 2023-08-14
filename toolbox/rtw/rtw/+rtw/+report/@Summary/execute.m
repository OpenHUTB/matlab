function execute(obj)



    obj.AddSectionNumber=false;
    obj.AddSectionShrinkButton=false;
    obj.AddSectionToToc=false;
    p=Advisor.Paragraph;

    out=obj.getConfigSummary;
    configTextElement=out(1);
    objectivesTextElement=out(2);
    resultTextElement=out(3);

    data=obj.getModelSummary;

    table=Advisor.Table(size(data,1),size(data,2));
    table.setStyle('AltRow');
    table.setEntries(data);
    p.addItem(table);
    p.addItem('<br />');
    p.addItem(configTextElement.emitHTML);
    obj.addSection('sec_model_info',message('RTW:report:ModelInformationLabel').getString,'',p);

    p=Advisor.Paragraph;

    data=obj.getCodeSummary;



    if~isempty(obj.SubsystemPathAndName)
        model=bdroot(obj.SubsystemPathAndName);
    else
        model=obj.ModelName;
    end
    if(coder.internal.slcoderReport('generateCodeMetricsReportOn',model))
        obj.loadCodeMetricsFiles;
        [r,~]=size(data);
        data{r+1,1}=['<span id="metricsLocationTitle"> ',message('RTW:report:SummaryMemoryInformationLabel').getString,' </span>'];
        data{r+1,2}=['<span id="metricsLocation"><script>document.write("',message('RTW:report:SummaryMemoryInformation').getString,'"); getCodeMetricsByPolling();</script></span>'];
    end

    [r,~]=size(data);
    data{r+1,1}=message('RTW:report:ObjectiveSpecifiedLabel').getString;
    data{r+1,2}=objectivesTextElement.emitHTML;

    table=Advisor.Table(size(data,1),size(data,2));
    table.setStyle('AltRow');
    table.setEntries(data);

    p.addItem(table);
    obj.addSection('sec_code_info',message('RTW:report:CodeInformationLabel').getString,'',p);

    p=Advisor.Paragraph;
    data=cell(length(obj.AdditionalInformation)+1,2);
    data{1,1}=message('RTW:report:SummaryCodeGenAdvisorLabel').getString;
    data{1,2}=resultTextElement.emitHTML;

    if obj.IsFmaTriggered
        data{2,1}=[obj.InstructionSetExtensions,' ',message('RTW:report:InstructionSetExtensionLabel').getString];
        data{2,2}=message('RTW:report:FmaTriggeredMessage').getString;
    end

    if obj.isReductionTriggered
        [r,~]=size(data);
        data{r+1,1}=message('RTW:report:OptimizeReductionLabel').getString;
        data{r+1,2}=[message('RTW:report:ReductionTriggeredMessage').getString,' ',obj.InstructionSetExtensions,' ',message('RTW:report:InstructionSetExtensionLabel').getString];
    end

    if(~isempty(obj.AdditionalInformation))
        for k=1:length(obj.AdditionalInformation)
            data{k+1,1}=obj.AdditionalInformation(k).title;
            data{k+1,2}=obj.AdditionalInformation(k).message;
        end
    end

    table=Advisor.Table(size(data,1),size(data,2));
    table.setStyle('AltRow');
    table.setEntries(data);
    obj.addSection('sec_additional_info',message('RTW:report:AdditionalInformationLabel').getString,'',table);

end
