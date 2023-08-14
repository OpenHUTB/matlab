function out=confidenceIntervalStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    end

end

function out=generateHTML(html,step,steps,input)


    fitStep=getStepByType(steps,'Fit');
    if~isempty(fitStep)&&~fitStep.enabled
        fitStep=[];
    end

    if~isempty(fitStep)
        useParallel=logical2str(fitStep.runInParallel);
    else
        useParallel=logical2str(step.runInParallel);
    end

    parameterInfo=step.parameter;
    predictionInfo=step.prediction;

    if strcmp(parameterInfo.calculate,'true')||strcmp(predictionInfo.calculate,'true')
        if input.includeProgramStepDescription
            html=buildBlackSectionHeader(html,'Confidence Interval Step',step.description);
        else
            html=buildBlackSectionHeader(html,'Confidence Interval Step','');
        end
    end

    if strcmp(parameterInfo.calculate,'true')
        html=generateParameterCIHTML(html,parameterInfo,useParallel);
    end

    if strcmp(predictionInfo.calculate,'true')
        html=generatePredictionCIHTML(html,predictionInfo,useParallel);
    end


    out.html=html;

end

function html=generateParameterCIHTML(html,parameterInfo,useParallel)

    props={'Confidence Level (%)','Type'};
    values={parameterInfo.confidenceLevel,parameterInfo.method};

    if strcmp(parameterInfo.method,'bootstrap')
        props{end+1}='Tolerance';
        values{end+1}=parameterInfo.tolerance;
        props{end+1}='NumSamples';
        values{end+1}=parameterInfo.numSamples;
    elseif strcmp(parameterInfo.method,'profileLikelihood')
        props{end+1}='MaxStepSize';
        values{end+1}=parameterInfo.maxStepSize;
        props{end+1}='Tolerance';
        values{end+1}=parameterInfo.tolerance;

        if iscell(parameterInfo.parameters)
            props{end+1}='Parameters';
            values{end+1}=['{',createCommaSeparatedQuotedList(parameterInfo.parameters),'}'];
        else
            props{end+1}='Parameters';
            values{end+1}='all';
        end

        props{end+1}='UseIntegration';
        values{end+1}=parameterInfo.useIntegration;

        if strcmp(parameterInfo.useIntegration,'true')
            props{end+1}='InitialStepSize';
            values{end+1}=parameterInfo.initialStepSize;
            props{end+1}='AbsoluteTolerance';
            values{end+1}=parameterInfo.absoluteTolerance;
            props{end+1}='RelativeTolerance';
            values{end+1}=parameterInfo.relativeTolerance;
            props{end+1}='Hessian';
            values{end+1}=parameterInfo.hessian;

            if strcmp(parameterInfo.hessian,'identity')
                props{end+1}='CorrectionFactor';
                values{end+1}=parameterInfo.correctionFactor;
            end
        end
    end

    props{end+1}='UseParallel';
    values{end+1}=useParallel;

    html=buildSectionHeader(html,'Parameter Confidence Interval Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generatePredictionCIHTML(html,predictionInfo,useParallel)

    props={'Confidence Level (%)','Type'};
    values={predictionInfo.confidenceLevel,predictionInfo.method};

    if strcmp(predictionInfo.method,'bootstrap')
        props{end+1}='NumSamples';
        values{end+1}=predictionInfo.numSamples;
    end

    props{end+1}='UseParallel';
    values{end+1}=useParallel;

    html=buildSectionHeader(html,'Prediction Confidence Interval Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function out=generateResultsHTML(html,results,varargin)

    out=[];


    header='Confidence Interval Step';
    if nargin==3
        header=varargin{1};
    end

    if isfield(results,'parameterCI')
        html=buildBlackSectionHeader(html,header,'');
    end


    if isfield(results,'parameterCI')
        tableInfo=struct;
        tableInfo=SimBiology.web.fitdatahandler('getData',{results.parameterCI,[],tableInfo});
        tables=tableInfo.data.tables;


        [groupHeadings,headings,data]=generateResultsTableData(tables);
        tableHTML=buildTableWithGroupHeader(groupHeadings,headings,data,{},'Parameter Confidence Interval Results');
        html=appendLine(html,tableHTML);
    end














    out.html=html;

end

function[groupHeadings,headings,data]=generateResultsTableData(table)

    columns=table.columnInfo;
    headings=cell(1,length(columns));
    data=cell(1,length(columns));

    for i=1:length(columns)
        next=columns(i).data;
        if(size(next,1)==1)
            next=next';
        end

        data{i}=next;
        headings{i}=columns(i).name;
    end

    data=[data{:}];
    groupHeadings=table.additionalRows;

end

function out=logical2str(value)

    out=SimBiology.web.codegenerationutil('logical2str',value);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);

end

function html=buildTableWithGroupHeader(groupHeadings,headings,data,styles,caption)

    html=SimBiology.web.report.utilhandler('buildTableWithGroupHeader',groupHeadings,headings,data,styles,caption);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end

function out=createCommaSeparatedQuotedList(value)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedQuotedList',value);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);

end
