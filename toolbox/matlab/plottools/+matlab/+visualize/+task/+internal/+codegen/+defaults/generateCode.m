function[code,summaryLine]=generateCode(chartMetaData,channels,optionalRows,doGenerateLabels)












    code='';

    inputArgs=[];
    varNames={};
    displayNameString='';
    prevData='select variable';
    chartName=chartMetaData.Name;
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    zlabel='';

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






            elseif~isempty(displayNameString)&&...
                (strcmpi(prevData,'select variable')||strcmpi(prevData,'default value'))
                inputArgs=[inputArgs,'[],`',dataMapped,'`,'];
            else
                inputArgs=[inputArgs,'`',dataMapped,'`,'];
            end
            varNames{end+1}=dataMapped;%#ok<*AGROW>
            if numel(channels)>2&&...
                (strcmpi(channel.Name,'Z')||strcmpi(channel.Name,'FunZ'))
                zlabel=varNames{end};
            end
        end
        prevData=dataMapped;
    end


    if doGenerateLabelCode(chartMetaData.Outputs)
        [summaryLine,xyLabelCode]=matlab.visualize.task.internal.codegen.defaults.generateXYLabelAndComments(chartName,...
        varNames,zlabel);
    else
        [summaryLine,xyLabelCode]=matlab.visualize.task.internal.codegen.defaults.generateNoLegend(chartName,...
        varNames,zlabel);
    end


    outputVarName='';
    chartOutputs=chartMetaData.Outputs;
    if~isempty(chartOutputs)
        if numel(chartOutputs)==1
            outputVarName=[chartOutputs.name,' = '];
        else
            outputVarName='[';
            for i=1:numel(chartOutputs)
                outputVarName=[outputVarName,chartOutputs(i).name,','];
            end
            outputVarName(end)='';
            outputVarName=[outputVarName,'] = '];
        end
    end


    displayStringCode=[displayNameString,');'];
    if isempty(outputVarName)
        displayStringCode=');';
    end
    if~doGenerateLabels
        outputVarName='';
    end
    code=[code,[outputVarName,chartName,'(',inputArgs(1:end-1)]...
    ,generateOptionalParameterCode(optionalRows)...
    ,displayStringCode];
    if doGenerateLabels
        code=[code,newline...
        ,newline,xyLabelCode];
    end
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

function hasLabelCode=doGenerateLabelCode(outputs)
    hasLabelCode=false;
    if isempty(outputs)
        return;
    end

    for i=1:numel(outputs)
        try
            classMetaData=meta.class.fromName(outputs(i).type);

            if~isempty(classMetaData)
                hasLabelCode=~isempty(findobj(classMetaData.PropertyList,'Name','DisplayName'));
                if hasLabelCode
                    break;
                end
            end
        catch
        end
    end
end