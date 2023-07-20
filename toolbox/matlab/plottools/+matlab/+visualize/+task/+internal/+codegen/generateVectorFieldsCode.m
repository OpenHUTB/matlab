function generatedCode=generateVectorFieldsCode(chartName,outputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    inputArgs=[];
    annotationLabels={};
    zLabel='';
    uLabel='';
    vLabel='';
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
            elseif strcmpi(channel.Name,'Z')
                zLabel=replace(dataMapped,'''','''''');
            elseif strcmpi(channel.Name,'U')
                uLabel=replace(dataMapped,'''','''''');
            elseif strcmpi(channel.Name,'V')
                vLabel=replace(dataMapped,'''','''''');
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
    secondVar='';
    if~isempty(annotationLabels)
        firstVar=annotationLabels{1};
        secondVar=annotationLabels{2};
    elseif~isempty(zLabel)
        firstVar=zLabel;
        if~isempty(uLabel)
            secondVar=uLabel;
        end
    else
        firstVar=uLabel;
        secondVar=vLabel;
    end
    if~isempty(secondVar)
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryTwoData";
        if~isempty(zLabel)&&~isempty(annotationLabels)
            summaryLine=getString(message(summaryMsgCatalog,chartString,[firstVar,', ',secondVar,','],zLabel));
        else
            summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar,secondVar));
        end
    else
        summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryOneData";
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar));
    end

    labelCode=getXYLabelCode(firstVar,secondVar,zLabel,uLabel,annotationLabels);

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

function xyLabelCode=getXYLabelCode(firstVar,secondVar,zVar,uVar,annotationLabels)
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(firstVar);
    secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(secondVar);
    zVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(zVar);
    uVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(uVar);
    titleCode='';
    xyLabelCode='';
    commentCode='';
    if~isempty(annotationLabels)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))];
        xyLabelCode=[newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'];
        titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    elseif~isempty(firstVar)&&isempty(zVar)
        if isempty(uVar)
            commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'ylabel','title'))];
            xyLabelCode=[newline,'ylabel(''',firstVar,''')'];
            titleCode=[newline,'title(''',firstVar,''')'];
        else
            commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'];
            titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
        end
    end
    if~isempty(zVar)
        if isempty(titleCode)
            if~isempty(uVar)
                titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
            else
                titleCode=[newline,'title(''',zVar,''')'];
            end
        else
            if~isempty(firstVar)&&~isempty(secondVar)
                titleCode=[newline,'title(''',zVar,' vs. ',firstVar,' and ',secondVar,''')'];
            elseif~isempty(firstVar)&&isempty(secondVar)
                titleCode=[newline,'title(''',zVar,' vs. ',firstVar,''')'];
            end
        end
        if isempty(commentCode)
            commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'zlabel','title'))];
        else
            commentCode=replace(commentCode,'ylabel','ylabel, zlabel');
        end
        xyLabelCode=[xyLabelCode,newline,'zlabel(''',zVar,''')'...
        ,titleCode];
    else
        xyLabelCode=[xyLabelCode...
        ,titleCode];
    end
    xyLabelCode=[commentCode...
    ,xyLabelCode];
end