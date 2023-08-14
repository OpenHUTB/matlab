function generatedCode=generateParallelPlotCode(chartName,outputs,channels,parameters,doGenerateLabels)










    code='';
    summaryLine=getString(message('MATLAB:graphics:visualizedatatask:ChartInPurposeLine',chartName));
    generatedCode={code,summaryLine};
    inputArgs=[];
    varNames={};
    hasTableSelected=false;
    for i=1:numel(channels)
        channel=channels(i);

        dataMapped=channel.DataMapped;
        if channel.IsRequired&&strcmpi(dataMapped,'select variable')
            return;
        elseif~strcmpi(dataMapped,'select variable')&&~strcmpi(dataMapped,'default value')
            if isa(matlab.visualize.task.internal.model.DataModel.getEvaluatedData(dataMapped),'tabular')
                hasTableSelected=true;
            end
            if strcmpi(channel.Name,'GroupData')
                channelName=channel.Name;
                if hasTableSelected
                    channelName='GroupVariable';
                    dataVar=dataMapped;
                    if contains(dataVar,'.')
                        dataVar=['"',extractAfter(dataVar,'.'),'"'];
                        dataVar=replace(dataVar,["(",")"],'');
                    else
                        dataVar=['`',dataVar,'`'];
                    end
                    inputArgs=[inputArgs,'''',channelName,'''',',',dataVar,','];
                else
                    inputArgs=[inputArgs,'''',channelName,'''',',`',dataMapped,'`,'];
                end
            else
                inputArgs=[inputArgs,'`',dataMapped,'`,'];
            end

            varNames{end+1}=dataMapped;
        end
    end
    outputVar='';
    if doGenerateLabels
        outputVar=[outputs.name,' = '];
    end
    firstVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{1});
    if numel(varNames)>1
        secondVar=matlab.visualize.task.internal.codegen.defaults.clearVariableNameFormatting(varNames{2});
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryTwoData",['`',chartName,'`'],varNames{1},varNames{2}));
        commentsCode=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryTwoData",chartName,varNames{1},varNames{2}));
        labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",'xlabel, ylabel','title'))...
        ,newline,'xlabel(''',firstVar,''')'...
        ,newline,'ylabel(''',secondVar,''')'...
        ,newline,'title(''',secondVar,' vs. ',firstVar,''')'];
    else
        summaryLine=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryOneData",['`',chartName,'`'],varNames{1}));
        commentsCode=getString(message("MATLAB:graphics:visualizedatatask:ChartSummaryOneData",chartName,varNames{1}));
        label='xlabel';
        labelCode=['% ',getString(message("MATLAB:graphics:visualizedatatask:CommentForAnnotations",label,'title'))...
        ,newline,'xlabel(''',firstVar,''')'...
        ,newline,'title(''',firstVar,''')'];
    end

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
        generatedCode={code,summaryLine};
    end