function out=gsaStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateSecondStepMPGSAHTML'
        out=generateSecondStepMPGSAHTML(varargin{:});
    case 'generateResultsHTML'
        out=generateResultsHTML(varargin{:});
    end

end

function out=generateHTML(html,step,input)

    if input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,[getStepName(step),' Step'],step.description);
    else
        html=buildBlackSectionHeader(html,[getStepName(step),' Step'],'');
    end

    switch(step.analysis)
    case 'Sobol indices'
        html=generateSobolIndicesHTML(html,step);
    case 'Elementary effects'
        html=generateElementaryEffectsHTML(html,step);
    otherwise
        html=generateMPGSAHTML(html,step);
    end


    out.html=html;

end

function out=generateSecondStepMPGSAHTML(html,step,steps,input)

    if input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'MPGSA Step',step.description);
    else
        html=buildBlackSectionHeader(html,'MPGSA Step','');
    end

    step=getStepByType(steps,'Global Sensitivity Analysis');
    html=generateClassifiersHTML(html,step);
    html=generateMPGSASettingsHTML(html,step);


    out.html=html;

end

function html=generateSobolIndicesHTML(html,step)

    html=generateAnalysisHTML(html,step);
    html=generateNumberOfSamplesHTML(html,step);
    html=generateSimulationTimeHTML(html,step);
    html=generateCombinationsHTML(html,step);
    html=generateSensitivityInputsHTML(html,step);
    html=generateSensitivityOutputsHTML(html,step);

end

function html=generateElementaryEffectsHTML(html,step)

    html=generateAnalysisHTML(html,step);
    html=generateNumberOfSamplesHTML(html,step);
    html=generateSimulationTimeHTML(html,step);
    html=generateSensitivityInputsBoundedHTML(html,step);
    html=generateSensitivityOutputsHTML(html,step);
    html=generateElementaryEffectsSettingsHTML(html,step);

end

function html=generateMPGSAHTML(html,step)

    html=generateAnalysisHTML(html,step);
    html=generateTotalNumberOfSimulations(html,step);
    html=generateSimulationTimeHTML(html,step);
    html=generateCombinationsHTML(html,step);
    html=generateSensitivityInputsHTML(html,step);
    html=generateClassifiersHTML(html,step);
    html=generateMPGSASettingsHTML(html,step);

end

function html=generateAnalysisHTML(html,step)

    html=appendLineWithPad(html,'<h2>Analysis</h2>',1);
    html=appendLineWithPad(html,sprintf('<label>%s</label>',step.analysis),2);

end

function html=generateNumberOfSamplesHTML(html,step)

    numSamples=step.numberOfSamples;
    if isnumeric(numSamples)
        numSamples=num2str(numSamples);
    end

    html=appendLineWithPad(html,'<h2>Number of Samples</h2>',1);
    html=appendLineWithPad(html,sprintf('<label>%s</label>',numSamples),2);

end

function html=generateSimulationTimeHTML(html,step)

    settings=step.simulationTimeSettings;

    if(settings.useStopTime)
        props={'StopTime','Interpolation'};
        values={settings.stopTime,settings.interpolation};
    else
        props={'OutputTimes'};
        values={settings.outputTimes};
    end

    html=buildSectionHeader(html,'Simulation Time','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generateTotalNumberOfSimulations(html,step)

    list=step.combinations;
    if~isempty(list)
        html=appendLineWithPad(html,'<h2>Total Number of Samples</h2>',1);
        html=appendLineWithPad(html,sprintf('<label>%s</label>',step.numIterations),2);
    end

end

function html=generateCombinationsHTML(html,step)

    html=SimBiology.web.report.generateSamplesStep('generateCombinationsHTML',html,step,'Sensitivity Input Combinations');

end

function html=generateSensitivityInputsBoundedHTML(html,step)


    inputs=step.sensitivityInputs.sensitivityBoundedInputs;
    if iscell(inputs)
        inputs=[inputs{:}];
    end

    inputs=inputs([inputs.use]);
    inputs=inputs([inputs.sessionID]~=-1);


    rowNumber={};
    name={};
    lower={};
    upper={};
    value={};

    for i=1:numel(inputs)
        rowNumber{i}=i;%#ok<*AGROW> 
        name{i}=inputs(i).name;
        lower{i}=inputs(i).lower;
        upper{i}=inputs(i).upper;
        value{i}=inputs(i).value;
    end

    data=[rowNumber;name]';
    headers={' ','Component Name'};
    styles={'style="width:30px"','style="width:auto"'};

    if areValuesDefined(lower)
        data=[data,lower'];
        headers=[headers,'Lower Bound'];
        styles{end+1}='';
    end

    if areValuesDefined(upper)
        data=[data,upper'];
        headers=[headers,'Upper Bound'];
        styles{end+1}='';
    end

    data=[data,value'];
    headers=[headers,'Current Value'];
    styles{end+1}='';

    tableHTML=buildTable(headers,data,styles,'Sensitivity Inputs');
    html=appendLine(html,tableHTML);

end

function html=generateSensitivityInputsHTML(html,step)

    sections=step.sensitivityInputs;
    sections=sections([sections.use]);

    for i=1:numel(sections)
        tableHTML=generateSensitivityInputTableHTML(step,sections(i));

        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end
    end

end

function html=generateSensitivityInputTableHTML(step,set)

    isSobol=strcmp(step.analysis,'Sobol indices');
    html='';
    tableData=set.sensitivityInputs;
    if isempty(tableData)
        return;
    end

    if iscell(tableData)
        tableData=[tableData{:}];
    end

    tableData=tableData([tableData.use]);
    tableData=tableData([tableData.sessionID]~=-1);
    if isempty(tableData)
        return;
    end

    rowNumbers=cell(1,numel(tableData));
    names=cell(1,numel(tableData));
    distribution=cell(1,numel(tableData));
    props=cell(1,numel(tableData));
    currentValue=cell(1,numel(tableData));

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).name;
        currentValue{i}=tableData(i).modelValue;
        distribution{i}=tableData(i).distributionClassName;

        children=tableData(i).children;
        children=children([children.visible]);
        list=cell(1,numel(children)-1);
        for j=2:numel(children)
            propName=children(j).name;
            propValue=num2str(children(j).value);
            propExpression=[propName,' = ',propValue];
            list{j-1}=propExpression;
        end
        props{i}=createCommaSeparatedList(list);
    end

    headers={' ','Name','Distribution','Distribution Properties','Current Value'};
    styles={'style="width:30px"','style="width:100px"','style="width:100px"','style="width:auto"','style="width:auto"'};
    data=[rowNumbers;names;distribution;props;currentValue]';

    if isSobol
        html=buildTable(headers,data,styles,['Sensitivity Inputs: ',set.name]);
    else
        html=buildTable(headers,data,styles,['Sensitivity Inputs: ',set.name,' (Number of Samples: ',num2str(set.numberOfSamples),')']);
    end


    samplingOptions=set.samplingOptions;
    samplingType=samplingOptions.type;
    props={'Sampling Type'};
    values={samplingType};


    if startsWith(samplingType,'halton')
        props={'Sampling Type','Skip','Leap','Scramble Method'};
        values={samplingType,samplingOptions.skip,samplingOptions.leap,samplingOptions.scrambleMethodHalton};
    elseif startsWith(samplingType,'sobol')
        props={'Sampling Type','Skip','Leap','Point Order','Scramble Method'};
        values={samplingType,samplingOptions.skip,samplingOptions.leap,samplingOptions.pointOrder,samplingOptions.scrambleMethodSobol};
    elseif startsWith(samplingType,'latin')
        props={'Sampling Type','Smooth','Criterion','Iterations'};
        values={samplingType,samplingOptions.smooth,samplingOptions.criterion,samplingOptions.iterations};
    end

    if~isSobol
        corrMatrix=generateCovariateMatrix(set.correlationMatrix.paramNames,set.correlationMatrix.tableData);
        props{end+1}='Correlation Matrix';
        values{end+1}=mat2str(corrMatrix);
    end


    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generateSensitivityOutputsHTML(html,step)


    outputs=step.sensitivityOutputs;
    if iscell(outputs)
        outputs=[outputs{:}];
    end

    outputs=outputs([outputs.use]);
    outputs=outputs([outputs.sessionID]~=-1);


    rowNumber={};
    name={};

    for i=1:numel(outputs)
        rowNumber{i}=i;%#ok<*AGROW> 
        name{i}=outputs(i).name;
    end

    data=[rowNumber;name]';
    headers={' ','Component Name'};
    styles={'style="width:30px"','style="width:95%"'};
    sensTable=buildTable(headers,data,styles,'Sensitivity Outputs');
    html=appendLine(html,sensTable);

end

function html=generateClassifiersHTML(html,step)


    classifiers=step.classifiers;
    if iscell(classifiers)
        classifiers=[classifiers{:}];
    end

    classifiers=classifiers([classifiers.use]);
    classifiers={classifiers.expression};


    rowNumber={};
    expression={};

    for i=1:numel(classifiers)
        rowNumber{i}=i;
        expression{i}=classifiers{i};
    end

    data=[rowNumber;expression]';
    headers={' ','Expression'};
    styles={'style="width:30px"','style="width:auto"'};
    sensTable=buildTable(headers,data,styles,'Classifiers');
    html=appendLine(html,sensTable);

end

function html=generateMPGSASettingsHTML(html,step)

    html=appendLineWithPad(html,'<h2>Significance Level</h2>',1);
    html=appendLineWithPad(html,sprintf('<label>%s</label>',step.significanceLevel),2);

end

function html=generateElementaryEffectsSettingsHTML(html,step)

    gridSettings=step.gridSettings;
    outputSettings=step.outputSettings;

    props={'PointSelection','SamplingMethod','GridLevel','GridDelta','AbsoluteEffects'};
    values={gridSettings.pointSelection,gridSettings.samplingMethod,...
    gridSettings.gridLevel,gridSettings.gridDelta,...
    outputSettings.absoluteEffects};

    html=buildSectionHeader(html,'Settings','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function out=generateResultsHTML(html,data,step,dataName)

    out=[];
    header=[getStepName(step),' Step'];

    if isfield(data,dataName)
        results=data.(dataName);


        html=buildBlackSectionHeader(html,header,'');


        tableInfo=struct;
        tableInfo=SimBiology.web.gsahandler('getData',{results,[],tableInfo});
        tables=tableInfo.data.tables;

        for i=1:length(tables)
            styles={};
            [groupHeadings,headings,data]=generateResultsTableData(tables(i));

            if strcmp(tables(i).name,'PValues')
                styles=repmat({'style="width:auto"'},1,length(headings));
                styles{1}='style="width:200px"';
            elseif endsWith(tables(i).name,'Sample Information')
                styles=repmat({'style="width:auto"'},1,length(headings));
                styles{1}='style="width:250px"';
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

function out=getStepName(step)

    if strcmp(step.type,'Global Sensitivity Analysis')
        switch(step.analysis)
        case 'Sobol indices'
            out='Sobol Indices';
        case 'Elementary effects'
            out='Elementary Effects';
        otherwise
            out='MPGSA';
        end
    else
        out='MPGSA';
    end

end

function covMatrix=generateCovariateMatrix(names,covInfo)

    covMatrix=SimBiology.web.codegenerationutil('generateCovarianceMatrix',names,covInfo);

end

function out=areValuesDefined(list)

    out=SimBiology.web.report.utilhandler('areValuesDefined',list);

end

function code=appendLine(code,newLine)

    code=SimBiology.web.report.utilhandler('appendLine',code,newLine);

end

function code=appendLineWithPad(code,newLine,numTabs)

    code=SimBiology.web.report.utilhandler('appendLineWithPad',code,newLine,numTabs);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end

function code=buildPropertyValueTable(props,values)

    code=SimBiology.web.report.utilhandler('buildPropertyValueTable',props,values);

end

function code=buildSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildSectionHeader',out,header,description);

end

function code=buildTable(headers,contentInfo,styles,caption,varargin)

    code=SimBiology.web.report.utilhandler('buildTable',headers,contentInfo,styles,caption,varargin{:});

end

function html=buildTableWithGroupHeader(groupHeadings,headings,data,styles,caption)

    html=SimBiology.web.report.utilhandler('buildTableWithGroupHeader',groupHeadings,headings,data,styles,caption);

end

function out=createCommaSeparatedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedList',list);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);
end
