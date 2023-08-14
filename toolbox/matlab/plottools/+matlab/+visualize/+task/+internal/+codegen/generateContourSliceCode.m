function generatedCode=generateContourSliceCode(chartName,outputs,channels,parameters,doGenerateLabels)











    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    inputArgs=[];
    annotationLabels={};
    zLabel='';
    vLabel='';
    xSliceLabel='';
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
            elseif isempty(zLabel)&&strcmpi(channel.Name,'V')
                vLabel=replace(dataMapped,'''','''''');
            elseif~isempty(vLabel)&&strcmpi(channel.Name,'XSlice')
                xSliceLabel=replace(dataMapped,'''','''''');
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
        firstVar=vLabel;
        secondVar=xSliceLabel;
    end
    summaryMsgCatalog="MATLAB:graphics:visualizedatatask:ChartSummaryTwoData";
    if~isempty(zLabel)
        summaryLine=getString(message(summaryMsgCatalog,chartString,[firstVar,', ',secondVar,','],zLabel));
    else
        summaryLine=getString(message(summaryMsgCatalog,chartString,firstVar,secondVar));
    end

    labelCode=getXYLabelCode(firstVar,secondVar,zLabel,annotationLabels);

    vizCode=[outputVar,chartName,'(',inputArgs(1:end-1)];

    if~isempty(parameters)&&~isempty(parameters.SelectedValue)
        vizCode=[vizCode,',''',parameters.SelectedValue,''');'];
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

function xyLabelCode=getXYLabelCode(firstVar,secondVar,zVar,annotationLabels)
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(firstVar);
    secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(secondVar);
    zVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(zVar);
    titleCode='';
    xyLabelCode='';
    commentCode='';
    if~isempty(annotationLabels)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))];
        xyLabelCode=[newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'];
        titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    elseif~isempty(firstVar)&&isempty(zVar)
        commentCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:AddLabel")),' title'];
        titleCode=[newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    end
    if~isempty(zVar)
        if isempty(titleCode)
            titleCode=[newline,'title(''',zVar,''')'];
        elseif~isempty(firstVar)&&~isempty(secondVar)
            titleCode=[newline,'title(''',zVar,' vs. ',firstVar,' and ',secondVar,''')'];
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