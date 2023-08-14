function generatedCode=generateNoDisplayNameCode(chartName,outputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    inputArgs=[];
    varNames={};
    zlabel='';
    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;
        if channel.IsRequired&&strcmpi(dataMapped,'select variable')
            return;
        elseif~strcmpi(dataMapped,'select variable')&&~strcmpi(dataMapped,'default value')
            inputArgs=[inputArgs,'`',dataMapped,'`,'];
            varNames{end+1}=replace(dataMapped,'''','''''');
            if numel(channels)>2&&strcmpi(channel.Name,'Z')
                zlabel=varNames{end};
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

    [summaryLine,labelCode]=matlab.visualize.task.internal.codegen.defaults.generateNoLegend(chartName,...
    varNames,zlabel);

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