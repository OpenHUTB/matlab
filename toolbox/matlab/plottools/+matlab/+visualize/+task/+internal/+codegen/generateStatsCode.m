function generatedCode=generateStatsCode(chartName,chartOutputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    inputArgs=[];
    varNames={};
    generatedCode={code,summaryLine};
    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;
        if strcmpi(dataMapped,'select variable')||strcmpi(dataMapped,'default value')
            if i<2
                return;
            end
        else
            if i>1&&strcmpi(chartName,'andrewsplot')
                inputArgs=[inputArgs,'''Group'',','`',dataMapped,'`,'];
            else
                inputArgs=[inputArgs,'`',dataMapped,'`,'];
                varNames{end+1}=replace(dataMapped,'''','''''');
            end
        end
    end
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{1});
    if numel(varNames)>1
        secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{2});
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryTwoData",['`',chartName,'`'],varNames{1},varNames{2}));

        labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))...
        ,newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'...
        ,newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    else
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryOneData",['`',chartName,'`'],varNames{1}));

        labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel','title'))...
        ,newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''f(',firstVar,')'')'...
        ,newline,'title(''',firstVar,''')'];
    end
    vizCode=[chartName,'(',inputArgs(1:end-1)];

    parameterCode='';

    for i=1:numel(parameters)
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