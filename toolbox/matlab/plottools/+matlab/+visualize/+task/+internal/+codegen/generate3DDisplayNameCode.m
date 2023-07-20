function generatedCode=generate3DDisplayNameCode(chartName,outputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    inputArgs=[];
    annotationLabels={};
    cLabel='';
    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;
        if strcmpi(dataMapped,'select variable')||strcmpi(dataMapped,'default value')
            if channel.IsRequired
                return;
            end
        else
            inputArgs=[inputArgs,'`',dataMapped,'`,'];%#ok<AGROW>
            if ismember(channel.Name,{'X','Y'})
                annotationLabels{end+1}=replace(dataMapped,'''','''''');%#ok<AGROW>
            else
                cLabel=replace(dataMapped,'''','''''');
            end
        end
    end

    outputVar='';
    if doGenerateLabels&&~isempty(outputs)
        numOutputs=numel(outputs);
        if numOutputs==1
            outputVar=[outputs.name,' = '];
        else
            outputVar='[';
            for i=1:numOutputs
                outputVar=[outputVar,outputs(i).name,','];%#ok<AGROW>
            end
            outputVar(end)='';
            outputVar=[outputVar,'] = '];
        end
    end


    chartString=['`',chartName,'`'];
    firstVar='';
    secondVar='';
    if~isempty(annotationLabels)
        firstVar=annotationLabels{1};
        secondVar=annotationLabels{2};
    end
    if isempty(firstVar)
        firstVar=cLabel;
    end
    if~isempty(secondVar)
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryTwoData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar,secondVar));
    else
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryOneData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar));
    end

    labelCode=getXYLabelCode(firstVar,secondVar);

    vizCode=[outputVar,chartName,'(',inputArgs(1:end-1)];

    numOfOptions=numel(parameters);
    parameterCode='';

    for i=1:numOfOptions
        paramName=parameters(i).Name;
        paramVal=parameters(i).SelectedValue;
        if~isempty(paramVal)
            if ischar(paramVal)
                paramVal=['''',paramVal,''''];
            else
                paramVal=num2str(paramVal);
            end
            parameterCode=[parameterCode,'''',paramName,...
            ''',',paramVal,',...',newline];
        end
    end
    if~isempty(parameterCode)
        parameterCode=[',',parameterCode];
        parameterCode(end-4:end)=[];
    end
    if~isempty(parameterCode)
        vizCode=[vizCode,parameterCode,');'];
    else
        vizCode=[vizCode,');'];
    end

    code=vizCode;
    if doGenerateLabels
        code=[code...
        ,newline...
        ,newline,labelCode];
    end
    generatedCode={code,summaryLine};
end

function xyLabelCode=getXYLabelCode(firstVar,secondVar)
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(firstVar);
    secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(secondVar);
    xyLabelCode='';
    if~isempty(secondVar)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))];
        xyLabelCode=[newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'];
        titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    else
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'];
        titleCode=[newline,'title(''',firstVar,''')'];
    end

    xyLabelCode=[commentCode...
    ,[xyLabelCode...
    ,titleCode]];
end