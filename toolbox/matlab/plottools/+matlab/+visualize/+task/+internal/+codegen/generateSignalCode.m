function generatedCode=generateSignalCode(chartName,chartOutputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    inputArgs=[];
    varNames={};
    generatedCode={code,summaryLine};

    prevMapped=0;
    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;
        if strcmpi(dataMapped,'select variable')||strcmpi(dataMapped,'default value')
            if channel.IsRequired
                return;
            else
                prevMapped=prevMapped+1;
            end
        else
            if~channel.IsRequired
                if prevMapped>0
                    for j=1:prevMapped
                        inputArgs=[inputArgs,'[],'];
                    end
                end
            end
            inputArgs=[inputArgs,'`',dataMapped,'`,'];
            varNames{end+1}=replace(dataMapped,'''','''''');
        end
    end
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{1});

    doGenerateTitle=strcmpi(chartName,'spectrogram')||strcmpi(chartName,'freqz');
    if numel(varNames)>1
        secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{2});
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryTwoData",['`',chartName,'`'],varNames{1},varNames{2}));
        commentsCode=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryTwoData",chartName,varNames{1},varNames{2}));
        labelCode='';
        if doGenerateTitle
            labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'...
            ,newline,'title(''',secondVar,' vs. ',firstVar,''')'];
        end
    else
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryOneData",['`',chartName,'`'],varNames{1}));
        commentsCode=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryOneData",chartName,varNames{1}));
        labelCode='';
        if doGenerateTitle
            labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'...
            ,newline,'title(''',firstVar,''')'];
        end
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