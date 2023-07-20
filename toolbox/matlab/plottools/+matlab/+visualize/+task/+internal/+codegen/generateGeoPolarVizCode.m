function generatedCode=generateGeoPolarVizCode(chartName,chartOutputs,channels,optionalRows,doGenerateLabels)












    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    displayNameString='';
    inputArgs=[];
    varNames={};
    prevData='select variable';

    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;


        if strcmpi(dataMapped,'select variable')||strcmpi(dataMapped,'default value')


            if channel.IsRequired
                return;
            end
        else
            if channel.IsRequired
                dataMappedStr=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(dataMapped);
                displayNameString=[',','''','DisplayName',''',','''',replace(dataMappedStr,'''',''''''),''''];

                inputArgs=[inputArgs,'`',dataMapped,'`,'];
                varNames{end+1}=replace(dataMapped,'''','''''');%#ok<*AGROW>






            elseif~isempty(displayNameString)&&...
                (strcmpi(prevData,'select variable')||strcmpi(prevData,'default value'))
                inputArgs=[inputArgs,'[],`',dataMapped,'`,'];
                varNames{end+1}=replace(dataMapped,'''','''''');
            else
                inputArgs=[inputArgs,'`',dataMapped,'`,'];
                varNames{end+1}=replace(dataMapped,'''','''''');
            end
        end
        prevData=dataMapped;
    end


    chartString=['`',chartName,'`'];
    firstVar=varNames{1};
    secondVar='';
    if numel(varNames)>1
        secondVar=varNames{2};
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryTwoData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar,secondVar));
    else
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryOneData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar));
    end

    xyLabelCode=getXYLabelCode(firstVar,secondVar);


    outputVarName='';
    if doGenerateLabels&&~isempty(chartOutputs)
        if numel(chartOutputs)==1
            outputVarName=[chartOutputs.name,' = '];
        else
            outputVarName='[';
            for i=1:numel(chartOutputs)
                outputVarName=[outputVarName,chartOutputs(i).name,','];
            end
            outputVarName(end)='';
            outputVarName=[outputVarName,'] ='];
        end
    end

    vizCode=[outputVarName,chartName,'(',inputArgs(1:end-1)];

    parameterCode=generateOptionalParameterCode(optionalRows);
    if~isempty(parameterCode)
        vizCode=[vizCode,parameterCode,');'];
    else
        vizCode=[vizCode,');'];
    end

    code=vizCode;
    if doGenerateLabels
        code=[code...
        ,newline...
        ,newline,xyLabelCode];
    end
    generatedCode={code,summaryLine};
end

function parameterCode=generateOptionalParameterCode(optionsRows)
    numOfOptions=numel(optionsRows);
    parameterCode='';

    for i=1:numOfOptions
        paramName=optionsRows(i).Name;
        paramVal=optionsRows(i).SelectedValue;
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
end

function xyLabelCode=getXYLabelCode(firstVar,secondVar)
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(firstVar);
    secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(secondVar);
    if~isempty(secondVar)
        xyLabelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'...
        ,newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    else
        xyLabelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'...
        ,newline,'title(''',firstVar,''')'];
    end
end