function[ResultDescription,ResultDetails]=utilDisplayHardwareResults(hardwareResults,skipTiming,...
    ResultDescription,ResultDetails)




    if~isempty(hardwareResults)

        resourceVariables=hardwareResults.ResourceVariables;
        usage=hardwareResults.ResourceData;
        availableResources=hardwareResults.AvailableResources;
        utilization=hardwareResults.Utilization;

        resourceFile=hardwareResults.ResourceFile;
        slackValue=hardwareResults.Slack;


        ResultDescription{end+1}=ModelAdvisor.Text(message('hdlcoder:hdldisp:ParsedResourceReport',getFileLink(resourceFile)).getString());
        ResultDetails{end+1}='';


        numRows=size(resourceVariables,1);

        resourceSummaryTable=ModelAdvisor.Table(numRows,4);

        setHeading(resourceSummaryTable,'Resource summary');

        setColHeading(resourceSummaryTable,1,'Resource');
        setColHeading(resourceSummaryTable,2,'Usage');
        setColHeading(resourceSummaryTable,3,'Available');
        setColHeading(resourceSummaryTable,4,'Utilization (%)');

        resourceSummaryTable.setEntries([resourceVariables,usage,availableResources,utilization]);


        ResultDescription{end+1}=resourceSummaryTable;
        ResultDetails{end+1}='';

        if~skipTiming

            timingVariables=hardwareResults.TimingVariables;
            timingData=hardwareResults.TimingData;

            timingFile=hardwareResults.TimingFile;

            ResultDescription{end+1}=ModelAdvisor.Text(message('hdlcoder:hdldisp:ParsedTimingReport',getFileLink(timingFile)).getString());
            ResultDetails{end+1}='';


            numRows=size(timingVariables,1);

            timingSummaryTable=ModelAdvisor.Table(numRows,2);

            setHeading(timingSummaryTable,'Timing summary');

            setColHeading(timingSummaryTable,1,'');
            setColHeading(timingSummaryTable,2,'Value');

            timingSummaryTable.setEntries([timingVariables,timingData]);


            ResultDescription{end+1}=timingSummaryTable;
            ResultDetails{end+1}='';
        end

        if~isinf(slackValue)
            if slackValue<0
                ResultDescription{end+1}=ModelAdvisor.Text(message('hdlcoder:hdldisp:TimingFailWarning').getString());
                ResultDetails{end+1}='';
            end
        else
            ResultDescription{end+1}=ModelAdvisor.Text(message('hdlcoder:hdldisp:TargetFreqNotSet').getString());
            ResultDetails{end+1}='';
        end
    end
end



function link=getFileLink(fileName)
    if feature('hotlinks')
        separators=strfind(fileName,filesep);
        displayName=fileName(separators(end)+1:end);
        link=sprintf('<a href="matlab:edit(''%s'')">%s</a>',fileName,displayName);
    else
        link=fileName;
    end
end