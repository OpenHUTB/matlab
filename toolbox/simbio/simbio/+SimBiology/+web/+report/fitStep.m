function out=fitStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateDataMapHTML'
        out=generateDataMapHTML(varargin{:});
    case 'generateGroupSimulationHTML'
        out=generateGroupSimulationHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    case 'generateVariantDoseSetupHTML'
        out=generateModifierSetupHTML(varargin{:});
    end

end

function out=generateHTML(html,step,input)


    if input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'Fit Step',step.description);
    else
        html=buildBlackSectionHeader(html,'Fit Step','');
    end

    if any(strcmp(step.estimationMethod.estimationFunction,{'nlmefit','nlmefitsa'}))
        html=generateFitMixed(html,step);
    else
        html=generateFit(html,step);
    end

    out.html=html;

end

function out=generateDataMapHTML(html,step)


    html=buildBlackSectionHeader(html,'Data Step','');
    html=generateDefinitionHTML(html,step);

    out.html=html;

end

function out=generateModifierSetupHTML(html,step)


    html=buildBlackSectionHeader(html,'Variant and Dose Setup Step','');
    html=generateVariantDoseSetupHTML(html,step);

    out.html=html;

end

function html=generateFit(html,step)

    html=generateEstimatedParametersHTML(html,step);
    html=generateErrorModelHTML(html,step);
    html=generateAlgorighmSettingsHTML(html,step);

end

function html=generateFitMixed(html,step)

    html=generateCovariatesHTML(html,step);
    html=generateMixedEstimatedParametersHTML(html,step);
    html=generateMixedErrorModelHTML(html,step);
    html=generateMixedAlgorighmSettingsHTML(html,step);

end

function out=generateGroupSimulationHTML(html,step,input)


    if input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'Simulation Step',step.description);
    else
        html=buildBlackSectionHeader(html,'Simulation Step','');
    end

    html=generateStopTimeHTML(html,step);
    html=generateSliderSummaryHTML(html,step);

    out.html=html;

end

function out=generateDefinitionHTML(out,step)

    data=step.fitDefinitions;
    classifications={};
    columns={};
    rowStyles={};

    if iscell(data)
        data=[data{:}];
    end

    for i=1:length(data)
        column=data(i).property;
        classification=data(i).classification;

        switch(classification)
        case{'group','independent'}
            classifications{end+1}=classification;%#ok<*AGROW>
            columns{end+1}=column;
            rowStyles{end+1}='';
        case 'response'
            if(data(i).use)
                classifications{end+1}=classification;
                columns{end+1}=[column,' ~ ',data(i).value];
                rowStyles{end+1}='';
            end
        case 'dose from data'
            if(data(i).use)
                type='Bolus';
                tlag=data(i).children(4).value;

                if strcmp(data(i).children(3).type,'rawdata')
                    type=['Infusion Data Column: ',data(i).children(3).value];
                elseif strcmp(data(i).children(3).type,'parameter')
                    type=['Duration Parameter: ',data(i).children(3).value];
                elseif strcmp(data(i).children(3).type,'Instant')
                    type='Bolus';
                end

                classifications{end+1}=classification;
                columns{end+1}=[column,' -> ',data(i).value];
                rowStyles{end+1}='doseFromData';

                classifications{end+1}=' ';
                columns{end+1}=type;

                if~isempty(tlag)
                    rowStyles{end+1}='doseFromData';
                else
                    rowStyles{end+1}='';
                end

                if~isempty(tlag)
                    classifications{end+1}=' ';
                    columns{end+1}=['Time Lag Parameter: ',tlag];
                    rowStyles{end+1}='';
                end
            end
        case 'variant from data'
            if(data(i).use)
                unitConversion=data(i).children(3).value;
                classifications{end+1}=classification;
                columns{end+1}=[column,' ~ ',data(i).value];

                if strcmp(unitConversion,'[]')
                    rowStyles{end+1}='';
                else
                    rowStyles{end+1}='variantFromData';
                    classifications{end+1}=' ';
                    columns{end+1}=['UnitConversion: ',unitConversion];
                    rowStyles{end+1}='';
                end
            end
        end
    end

    data=[classifications;columns]';

    headers={'Classification','Value'};
    styles={'style="width:100px"','style="width:auto"'};
    tableHTML=buildTable(headers,data,styles,'Data Map','',rowStyles);
    out=appendLine(out,tableHTML);

end

function out=generateVariantDoseSetupHTML(out,step)

    tableData=step.groupDefinitions;
    columnNames=step.groupDefinitionsColumnNames;
    headerInfo=step.groupDefinitionsHeader;
    headingLabel='Variant and Dose Setup';
    styles={'style="width:150px"'};

    group=cell(1,numel(tableData));

    for i=1:numel(group)
        group{i}=tableData(i).group;
    end

    data=[group]';%#ok<NBRAK> 
    headers={'Group'};
    groupDescription={''};

    for i=1:numel(columnNames)
        name=columnNames{i};

        if startsWith(name,{'variant','dose'})
            next=cell(1,numel(tableData));
            for j=1:numel(next)
                next{j}=tableData(j).(name);
            end

            label=[upper(name(1)),name(2:end)];
            data=[data,next'];
            headers=[headers,label];
            groupDescription=[groupDescription,headerInfo{i}.description];
            styles=[styles,'style="width:auto"'];
        end
    end

    groupHeader.columnNames=headers;
    groupHeader.spans=ones(1,numel(headers));

    tableHTML=buildTableWithGroupHeader(groupHeader,groupDescription,data,styles,headingLabel);
    out=appendLine(out,tableHTML);

end

function out=generateEstimatedParametersHTML(out,step)

    data=step.estimatedParameterInfo;
    name=cell(1,length(data));
    transformation=cell(1,length(data));
    value=cell(1,length(data));
    bounds=cell(1,length(data));
    catVariable=cell(1,length(data));

    for i=1:length(data)
        lowerBound=data(i).children(2).value;
        upperBound=data(i).children(3).value;
        boundsValue='Unbounded';
        if~isempty(lowerBound)
            boundsValue=['[',num2str(lowerBound),'  ',num2str(upperBound),']'];
        end

        name{i}=data(i).name;
        transformation{i}=data(i).expression;
        value{i}=data(i).children(1).value;
        bounds{i}=boundsValue;
        catVariable{i}=strtrim(data(i).categoryVariable);
    end

    headers={'Name','Transformation','Initial Untransformed Value','Untransformed Bounds'};
    styles={' ','style="width:100px"','style="width:100px"','style="width:100px"'};

    if areValuesDefined(catVariable)

        headers{end+1}='Category Variable';
        styles{end+1}='style="width:100px"';
        data=[name;transformation;value;bounds;catVariable]';
    else
        data=[name;transformation;value;bounds]';
    end


    heading='Estimated Parameters';
    if(step.pooled)
        heading='Estimated Parameters (Pooled Fit)';
    end

    tableHTML=buildTable(headers,data,styles,heading);
    out=appendLine(out,tableHTML);

end

function html=generateErrorModelHTML(html,step)

    errorModel=step.errorModel;
    switch(errorModel.optimErrorModelOption)
    case 'common'
        html=appendLineWithPad(html,'<h2>Error Model</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>Use the same error model for each response: %s</label>',errorModel.optimErrorModel),2);
    case 'separate'
        names={errorModel.optimErrorModelForEachResponse.name};
        errorModels={errorModel.optimErrorModelForEachResponse.errorModel};
        rowNumbers=num2cell(1:numel(names));
        headers={' ','Response Name','ErrorModel'};
        data=[rowNumbers;names;errorModels]';
        styles={'style="width:30px"','style="width:auto"','style="width:auto"'};
        tableHTML=buildTable(headers,data,styles,'Error Model');
        html=appendLine(html,tableHTML);
    case 'weights'
        html=appendLineWithPad(html,'<h2>Error Model</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>Use weights for each response: %s</label>',errorModel.optimErrorModelWeights),2);
    end

end

function html=generateAlgorighmSettingsHTML(html,step)

    localSolverSettings='';
    settings=step.algorithmSettings;
    estimateFcn=step.estimationMethod.estimationFunction;
    switch(estimateFcn)
    case 'fminsearch'
        props={'EstimationFcn','TolX','TolFun','MaxIter'};
        values={estimateFcn,settings.tolX,settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.fminsearch;
    case{'lsqcurvefit','lsqnonlin','fminunc','fmincon'}
        props={'EstimationFcn','StepTolerance','FunctionTolerance','OptimalityTolerance','MaxIterations'};
        values={estimateFcn,settings.tolX,settings.tolFun,settings.optimalityTolerance,settings.maxIter};
        advanced=step.advancedSettings.(estimateFcn);
    case 'patternsearch'
        props={'EstimationFcn','StepTolerance','FunctionTolerance','MaxIterations'};
        values={estimateFcn,settings.tolX,settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.patternsearch;
    case 'ga'
        props={'EstimationFcn','FunctionTolerance','MaxGenerations'};
        values={estimateFcn,settings.tolFun,settings.generations};
        advanced=step.advancedSettings.ga;
    case 'particleswarm'
        props={'EstimationFcn','FunctionTolerance','MaxIterations'};
        values={estimateFcn,settings.tolFun,settings.maxIter};
        advanced=step.advancedSettings.particleswarm;
    case 'scattersearch'
        props={'EstimationFcn','MaxIterations','FunctionTolerance','MaxStallIterations','MaxTime'...
        ,'NumInitialPoints','NumTrialPoints','XTolerance','LocalSolver'};
        values={estimateFcn,settings.scatterSearchMaxIter,settings.scatterSearchFunTol,settings.maxStallIterations,settings.maxTime...
        ,settings.numInitialPoints,settings.numTrialPoints,settings.xTolerance,settings.localSolver};
        advanced=step.advancedSettings.scattersearch;
        localSolverSettings=step.localSolverSettings;
    end

    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            props{end+1}=next.property;
            values{end+1}=next.value;
        end
    end

    html=buildSectionHeader(html,'Algorithm Settings','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

    if~isempty(localSolverSettings)


        localSolver=strrep(settings.localSolver,'''','');
        advanced=step.localSolverAdvancedSettings.(localSolver);
        switch(localSolver)
        case 'fminsearch'
            props1={'TolX','TolFun','MaxIter'};
            values1={localSolverSettings.tolX,localSolverSettings.tolFun,localSolverSettings.maxIter};
        case{'lsqcurvefit','lsqnonlin','fminunc','fmincon'}
            props1={'StepTolerance','FunctionTolerance','OptimalityTolerance','MaxIterations'};
            values1={localSolverSettings.tolX,localSolverSettings.tolFun,localSolverSettings.optimalityTolerance,localSolverSettings.maxIter};
        end

        for i=1:length(advanced)
            next=advanced(i);
            if~next.isUndefined
                props1{end+1}=next.property;
                values1{end+1}=next.value;
            end
        end

        html=buildSectionHeader(html,'Local Solver Settings','');
        tableHTML=buildPropertyValueTable(props1,values1);
        html=appendLine(html,tableHTML);
    end

end

function out=generateMixedEstimatedParametersHTML(out,step)

    data=step.estimatedParameterInfo;
    names=cell(1,length(data));
    values=cell(1,length(data));

    for i=1:length(data)
        names{i}=[data(i).name,' = ',data(i).expression];


        list={};
        for j=4:length(data(i).children)
            next=data(i).children(4);
            list{end+1}=[next.name,' = ',num2str(next.value)];
        end
        values{i}=createCommaSeparatedList(list);
    end

    headers={'Estimated Parameters','Initial Conditions'};
    data=[names;values]';

    styles={};
    tableHTML=buildTable(headers,data,styles,'Estimated Parameters');
    out=appendLine(out,tableHTML);

end

function html=generateCovariatesHTML(html,step)

    covariates=step.covariates;
    if numel(covariates)>0
        expressions=cell(1,numel(covariates));

        for i=1:numel(covariates)
            name=['t',covariates(i).name];
            value=covariates(i).value;
            expressions{i}=[name,' = ',value];
        end

        headers={'Covariates'};
        data=[expressions]';%#ok<NBRAK>

        styles={};
        tableHTML=buildTable(headers,data,styles,'Covariates');
        html=appendLine(html,tableHTML);
    end

end

function html=generateMixedErrorModelHTML(html,step)

    errorModel=step.errorModel;
    nlmeErrorModel=errorModel.nlmeErrorModel;
    estimateFcn=step.estimationMethod.estimationFunction;

    switch(nlmeErrorModel)
    case 'constant'
        errorModelStr='constant (y = f+a*e)';
    case 'proportional'
        errorModelStr='proportional (y = f+b*f*e)';
    case 'exponential'
        errorModelStr='exponential (y = f*exp(a*e))';
    case 'combined'
        errorModelStr='combined (y = f+(a+b*f)*e)';
    end

    if strcmp(estimateFcn,'nlmefitsa')&&strcmp(nlmeErrorModel,'combined')
        a=num2str(errorModel.nlmefitsaCombinedParameterA);
        b=num2str(errorModel.nlmefitsaCombinedParameterB);
        html=appendLineWithPad(html,'<h2>Error Model</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>%s&nbsp&nbsp&nbsp&nbsp&nbsp&nbspa = %s&nbsp&nbsp&nbspb = %s</label>',errorModelStr,a,b),2);
    else
        html=appendLineWithPad(html,'<h2>Error Model</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>%s</label>',errorModelStr),2);
    end

end

function html=generateMixedAlgorighmSettingsHTML(html,step)

    props={};
    values={};
    advanced='';
    settings=step.algorithmSettings;


    numEstimates=length(step.covarianceMatrixParameterNames);
    covMatrix=reshape(step.covarianceMatrix,numEstimates,numEstimates);
    covPattern=mat2str(double(covMatrix));

    estimateFcn=step.estimationMethod.estimationFunction;
    switch(estimateFcn)
    case 'nlmefit'
        props={'CovPattern','ApproximationType','OptimFun',...
        'Options.TolX','Options.TolFun','Options.MaxIter'};

        values={covPattern,settings.approximationType,settings.optimFun,...
        settings.nlmeTolX,settings.nlmeTolFun,settings.maxIter};

        advanced=step.advancedSettings.nlmefit;
    case 'nlmefitsa'
        props={'CovPattern','NBurnIn','NIterations','NMCMCIterations',...
        'OptimFun','LogLikMethod','ComputeStdErrors'};

        values={covPattern,settings.nBurnIn,settings.nIterations,...
        settings.NMCMCIterations,settings.optimFun,...
        settings.logLikMethod,settings.computeStdErrors};

        advanced=step.advancedSettings.nlmefitsa;
    end

    for i=1:length(advanced)
        next=advanced(i);
        if~next.isUndefined
            if next.isOption
                props{end+1}=['Options.',next.property];
            else
                props{end+1}=next.property;
            end
            values{end+1}=next.value;
        end
    end

    html=buildSectionHeader(html,'Algorithm Settings','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generateStopTimeHTML(html,step)

    settings=step.stopTimeSettings;


    props={'Include Data Times','Include Stop Time','Stop Time'};
    values={logical2str(settings.dataTimesIncluded),logical2str(settings.stopTimeIncluded),''};

    if(settings.useStopTime)
        values{3}=settings.stopTime;
    else
        values{3}='simulate to maximum time within each group';
    end


    html=buildSectionHeader(html,'Stop Time','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generateSliderSummaryHTML(html,step)

    sliders=step.sliders;
    rowNumber={};
    type={};
    name={};
    lower={};
    upper={};
    value={};

    for i=1:numel(sliders)
        rowNumber{i}=i;%#ok<*AGROW> 
        type{i}=sliders(i).type;
        name{i}=sliders(i).name;
        lower{i}=sliders(i).lower;
        upper{i}=sliders(i).upper;
        value{i}=sliders(i).value;
    end

    if numel(sliders)>0
        data=[rowNumber;type;name;lower;upper;value]';
        headers={' ','Type','Component Name','Lower Bound','Upper Bound','Value'};
        styles={'style="width:30px"','style="width:60px"','style="width:200px"','style="width:100px"','style="width:100px"','style="width:60%"'};
        sliderTable=buildTable(headers,data,styles,'Slider Summary');
        html=appendLine(html,sliderTable);
    end

end

function out=generateResultsHTML(html,data,varargin)

    out=[];


    header='Fit Step';
    if nargin==3
        header=varargin{1};
    end

    if isfield(data,'results')
        results=data.results;


        html=buildBlackSectionHeader(html,header,'');


        tableInfo=struct;
        tableInfo=SimBiology.web.fitdatahandler('getData',{results,[],tableInfo});
        tables=tableInfo.data.tables;

        for i=1:length(tables)
            styles={};
            [groupHeadings,headings,data]=generateResultsTableData(tables(i));


            if strcmp(tables(i).name,'Error Model')
                styles=repmat({'style="width:auto"'},1,length(headings));
                styles{end}='style="width:100px"';
                styles{end-1}='style="width:100px"';

                if strcmp(headings{1},'Response')
                    styles{1}='style="width:100px"';
                else
                    styles{1}='';
                end


                idx=strcmp('a',headings);
                if any(idx)
                    a=data(:,idx);
                    if areValuesEqual(a,'NaN')
                        headings(idx)=[];
                        data(:,idx)=[];
                        styles(idx)=[];
                    end
                end


                idx=strcmp('b',headings);
                if any(idx)
                    b=data(:,idx);
                    if areValuesEqual(b,'NaN')
                        headings(idx)=[];
                        data(:,idx)=[];
                        styles(idx)=[];
                    end
                end
            elseif strcmp(tables(i).name,'Pooled Beta')||strcmp(tables(i).name,'Pooled Parameter Estimates')
                styles=repmat({'style="width:150"'},1,length(headings));
                styles{1}='style="width:auto"';
            elseif strcmp(tables(i).name,'Covariance Matrix')
                styles=repmat({'style="width:250"'},1,length(headings));
                styles{1}='style="width:auto"';
            elseif strcmp(tables(i).name,'Fixed Effects')
                styles=repmat({'style="width:auto"'},1,length(headings));
                styles{1}='style="width:150px"';
            end

            tableHTML=buildTableWithGroupHeader(groupHeadings,headings,data,styles,tables(i).name);
            html=appendLine(html,tableHTML);
        end

        out.html=html;
    end

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

function value=logical2str(value)

    if value
        value='true';
    else
        value='false';
    end

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function out=areValuesDefined(list)

    out=SimBiology.web.report.utilhandler('areValuesDefined',list);

end

function out=areValuesEqual(list,value)

    out=SimBiology.web.report.utilhandler('areValuesEqual',list,value);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function html=buildTableWithGroupHeader(groupHeadings,headings,data,styles,caption)

    html=SimBiology.web.report.utilhandler('buildTableWithGroupHeader',groupHeadings,headings,data,styles,caption);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);

end

function code=buildTable(headers,contentInfo,styles,caption,varargin)

    code=SimBiology.web.report.utilhandler('buildTable',headers,contentInfo,styles,caption,varargin{:});

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end

function out=createCommaSeparatedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedList',list);
end
