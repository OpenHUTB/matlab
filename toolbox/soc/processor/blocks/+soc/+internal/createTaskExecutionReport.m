function createTaskExecutionReport(testerObj,results,modelName)




    fileName=['./',modelName,'.html'];

    wrtObj=soc.internal.htmlFileWriter(fileName);

    title=['Task Execution Report for "',modelName,'"'];
    wrtObj.writeTitle(title);

    wrtObj.writeHeader(title);
    wrtObj.writeMediumHeader('Date:');
    wrtObj.writeNoBRLine(datestr(now));

    wrtObj.startParagraph;
    if isequal(numel(testerObj.CurrentRuns),1)
        wrtObj.writeMediumHeader('Run name:');
        for i=1:numel(testerObj.CurrentRuns)
            wrtObj.writeNoBRLine(testerObj.CurrentRuns{i});
        end
    else
        wrtObj.writeMediumHeader('Run names:');
        for i=1:numel(testerObj.CurrentRuns)
            wrtObj.writeLine(['Run # ',num2str(i),'. ',testerObj.CurrentRuns{i}]);
        end
    end

    for i=1:numel(results)
        wrtObj.startParagraph;
        writeTaskSection(wrtObj,testerObj,results{i});
        wrtObj.startParagraph;
    end

    wrtObj.writeOutFile;

    web(fileName);
end


function writeTaskSection(wrtObj,testerObj,results)%#ok<INUSL>
    OUTCOMESTR={'Fail','Pass'};%#ok<*NASGU>
    taskName=results.Task;
    isRunVsRun=isfield(results,'Run2Data');
    taskData{1}=results.Run1Data.Durations;
    if isRunVsRun
        taskData{2}=results.Run2Data.Durations;
    end

    wrtObj.writeMediumHeader('Task name:');
    wrtObj.writeNoBRLine(taskName);

    wrtObj.writeMediumHeader(' ');
    wrtObj.writeMediumHeader('Execution times');
    wrtObj.writeNoBRLineStrong('Histogram');
    wrtObj.startParagraph;

    data=cell(length(taskData),4);
    rowHeads={};
    imgFiles={};
    for i=1:length(taskData)
        fileName=[taskName,'_Run',num2str(i)];
        title=['Run # ',num2str(i)];
        imgFiles{i}=createHistImage(taskData{i},fileName,title);%#ok<AGROW>
        data{i,1}=num2str(mean(taskData{i}));
        data{i,2}=num2str(std(taskData{i}));
        data{i,3}=num2str(min(taskData{i}));
        data{i,4}=num2str(max(taskData{i}));
        rowHeads{i}=['Run # ',num2str(i)];%#ok<AGROW>
    end
    wrtObj.writeImagesHorizontal(imgFiles);

    wrtObj.writeNoBRLineStrong('Statistics');
    wrtObj.startParagraph;
    wrtObj.writeTable(rowHeads,{'Mean','SD','Min','Max'},data);


























end


function imgFile=createHistImage(data,fileName,titleTxt)
    histogram(data,'BinMethod','fd','Normalization','probability');
    title(titleTxt);
    imgFile=['./',fileName,'.png'];
    saveas(gcf,imgFile);
    close(gcf);
end