function out=generateSamplesStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    case 'generateCombinationsHTML'
        out=generateCombinationsHTML(varargin{:});
    end

end

function out=generateHTML(html,step,input)

    if input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'Generate Samples Step',step.description);
    else
        html=buildBlackSectionHeader(html,'Generate Samples Step','');
    end


    tableHTML=generateParameterSetCombinationTableHTML(step);
    if~isempty(tableHTML)
        html=appendLine(html,tableHTML);
    end


    sets=step.parameterSets;
    sets=sets([sets.use]);

    for i=1:length(sets)
        set=sets(i);
        switch(set.scanType)
        case 'Quantity'
            tableHTML=generateQuantityTableHTML(set);
        case 'Dose'
            tableHTML=generateDoseTableHTML(set);
        case 'Variant'
            tableHTML=generateVariantTableHTML(set);
        end

        if~isempty(tableHTML)
            html=appendLine(html,tableHTML);
        end
    end


    out.html=html;

end

function html=generateParameterSetCombinationTableHTML(step)


    numIterations=step.numIterations;
    if ischar(numIterations)
        numIterations=str2double(numIterations);
    end


    parameterSets=step.parameterSets;
    parameterSets=parameterSets([step.parameterSets.use]);

    if numel(parameterSets)==1
        numIterations=parameterSets.numIterations;
    end

    if isnumeric(numIterations)
        numIterations=num2str(numIterations);
    end

    html='    <h2>Total Number of Runs</h2>';
    html=appendLineWithPad(html,sprintf('<label>%s</label>',numIterations),2);


    html=generateCombinationsHTML(html,step,'Parameter Set Combinations');

end

function html=generateCombinationsHTML(html,step,title)

    list=step.combinations;
    if~isempty(list)
        samplingData=cell(1,numel(list));
        combination=cell(1,numel(list));

        for i=1:numel(list)
            samplingData{i}=list(i).name;
            combination{i}=sprintf('%s %s %s',list(i).prop1,list(i).product,list(i).prop2);
        end

        headers={'Sampling Data','Combination'};
        styles={'style="width:100px"','style="width:auto"'};
        data=[samplingData;combination;]';
        tableHTML=buildTable(headers,data,styles,title);
        html=appendLine(html,tableHTML);
    end

end

function html=generateQuantityTableHTML(set)

    switch(set.quantityScanType)
    case 'user defined values'
        html=generateUserDefinedHTML(set);
    case{'values from a distribution'}
        html=generateDistributionHTML(set);
    otherwise
        html=generateQuantityDataHTML(set);
    end

end

function html=generateVariantTableHTML(set)

    html='';
    tableData=set.parameterSetData.VARIANTS;
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

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).name;
    end

    headers={' ','Name'};
    styles={'style="width:60px"','style="width:auto"'};
    data=[rowNumbers;names;]';
    html=buildTable(headers,data,styles,['Parameter Set (Variant in Model): ',set.name]);

end

function html=generateDoseTableHTML(set)

    switch(set.doseScanType)
    case 'doses in model'
        html=generateDosesInModelTableHTML(set);
    otherwise
        html=generateDosesFromDataTableHTML(set);
    end

end

function html=generateUserDefinedHTML(set)

    html='';
    tableData=set.parameterSetData.USERDEFINED;
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
    values=cell(1,numel(tableData));
    currentValue=cell(1,numel(tableData));

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).name;
        currentValue{i}=tableData(i).modelValue;


        children=tableData(i).children;
        if iscell(children)
            children=[children{:}];
        end

        props={children.name};
        switch(children(strcmp('Type',props)).value)
        case 'Range Of Values'
            spacing=children(strcmp('Spacing',props)).value;
            minValue=getNumericValue(children(strcmp('Min',props)).value);
            maxValue=getNumericValue(children(strcmp('Max',props)).value);
            numSteps=getNumericValue(children(strcmp('# Of Steps',props)).value);
            values{i}=generateRangeCode(spacing,minValue,maxValue,numSteps);
        case 'Percentage Range'
            spacing=children(strcmp('Spacing',props)).value;
            minValue=getNumericValue(children(strcmp('Min %',props)).value);
            maxValue=getNumericValue(children(strcmp('Max %',props)).value);
            numSteps=getNumericValue(children(strcmp('# Of Steps',props)).value);

            value=children(strcmp('Value',props)).value;
            if ischar(value)
                if strcmp(value,'Current Value')
                    value=tableData(i).modelValue;
                else
                    value=str2double(value);
                end
            end

            minValue=value+((minValue/100)*value);
            maxValue=value+((maxValue/100)*value);
            if(minValue==0)&&(maxValue==0)
                maxValue=1;
            end
            values{i}=generateRangeCode(spacing,minValue,maxValue,numSteps);
        case 'Individual Values'
            value=children(strcmp('Values',props)).value;
            if~strcmp(value(1),'[')
                values{i}=['[',value,']'];
            else
                values{i}=value;
            end
        case 'MATLAB Code'
            values{i}=children(strcmp('Code',props)).value;
        end
    end

    headers={' ','Name','Value','Current Value'};
    styles={'style="width:60px"','style="width:100px"','style="width:auto"','style="width:100px"'};
    data=[rowNumbers;names;values;currentValue]';
    html=buildTable(headers,data,styles,sprintf('Quantity Parameter Set: %s (%s)',set.name,set.parameterCombination));

end

function html=generateDistributionHTML(set)

    html='';
    tableData=set.parameterSetData.DISTRIBUTION;
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
    styles={'style="width:60px"','style="width:100px"','style="width:100px"','style="width:auto"','style="width:100px"'};
    data=[rowNumbers;names;distribution;props;currentValue]';
    html=buildTable(headers,data,styles,['Parameter Set (Quantity): ',set.name]);


    samplingType=set.samplingType;
    props={'Sampling Type'};
    values={samplingType};


    if startsWith(set.samplingType,'halton')
        props={'Sampling Type','Skip','Leap','Scramble Method'};
        values={samplingType,set.samplingOptions.skip,set.samplingOptions.leap,set.samplingOptions.scrambleMethodHalton};
    elseif startsWith(set.samplingType,'sobol')
        props={'Sampling Type','Skip','Leap','Point Order','Scramble Method'};
        values={samplingType,set.samplingOptions.skip,set.samplingOptions.leap,set.samplingOptions.pointOrder,set.samplingOptions.scrambleMethodSobol};
    elseif startsWith(set.samplingType,'latin')&&endsWith(set.samplingType,'correlation matrix')
        props={'Sampling Type','Smooth','Criterion','Iterations'};
        values={samplingType,set.samplingOptions.smooth,set.samplingOptions.criterion,set.samplingOptions.iterations};
    end

    isCorrelation=contains(samplingType,'correlation');
    if isCorrelation
        corrMatrix=generateCovariateMatrix(set.parameterSetData.CORRELATIONMATRIX.paramNames,set.parameterSetData.CORRELATIONMATRIX.tableData);
        corrHeading='Correlation Matrix';
    else
        corrMatrix=generateCovariateMatrix(set.parameterSetData.COVARIANCEMATRIX.paramNames,set.parameterSetData.COVARIANCEMATRIX.tableData);
        corrHeading='Covariance Matrix';
    end


    props{end+1}=corrHeading;
    values{end+1}=mat2str(corrMatrix);
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

end

function html=generateQuantityDataHTML(set)

    html='';
    tableData=set.parameterSetData.QUANTITYDATASET.tableData;
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
    columnName=cell(1,numel(tableData));
    names=cell(1,numel(tableData));

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).componentName;
        columnName{i}=tableData(i).name;
    end


    props={'Data Name','Groups'};
    values={set.parameterSetData.QUANTITYDATASET.selectedDataName,getGroupsSelected(set.parameterSetData.QUANTITYDATASET)};
    html=buildSectionHeader(html,['Parameter Set (Quantity): ',set.name],'');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

    headers={' ','Name','Value'};
    styles={'style="width:60px"','style="width:auto"','style="width:auto"'};
    data=[rowNumbers;columnName;names]';
    tableHTML=buildTable(headers,data,styles,'');
    html=appendLine(html,tableHTML);

end

function html=generateDosesInModelTableHTML(set)

    html='';
    tableData=set.parameterSetData.DOSES;
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

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).name;
    end

    headers={' ','Name'};
    styles={'style="width:60px"','style="width:auto"'};
    data=[rowNumbers;names]';
    html=buildTable(headers,data,styles,['Parameter Set (Dose in Model): ',set.name]);

end

function html=generateDosesFromDataTableHTML(set)

    html='';
    tableData=set.parameterSetData.DOSEDATASET.tableData;
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
    targetName=cell(1,numel(tableData));
    lagParamName=cell(1,numel(tableData));
    rate=cell(1,numel(tableData));
    amountUnits=cell(1,numel(tableData));
    timeUnits=cell(1,numel(tableData));
    rateUnits=cell(1,numel(tableData));

    for i=1:numel(tableData)
        rowNumbers{i}=i;
        names{i}=tableData(i).externalDataColumn;
        targetName{i}=tableData(i).value;
        lagParamName{i}='';
        rate{i}='';
        amountUnits{i}='';
        timeUnits{i}='';
        rateUnits{i}='';

        children=tableData(i).children;
        children=children([children.isUsed]);
        for j=1:numel(children)
            switch children(j).description
            case 'Lag Parameter Name'
                lagParamName{i}=children(j).value;
            case 'Rate'
                rate{i}=children(j).value;
            case 'Amount Units'
                amountUnits{i}=children(j).value;
            case 'Time Units'
                timeUnits{i}=children(j).value;
            case 'Rate Units'
                rateUnits{i}=children(j).value;
            end
        end
    end

    data=[rowNumbers;names;targetName]';
    headers={' ','Name','TargetName'};
    styles={'style="width:60px"','style="width:auto"',''};

    if areValuesDefined(lagParamName)
        data=[data,lagParamName'];
        headers=[headers,'Lag Parameter Name'];
        styles{end+1}='';
    end

    if areValuesDefined(rate)
        data=[data,rate'];
        headers=[headers,'Rate'];
        styles{end+1}='';
    end

    if areValuesDefined(amountUnits)
        data=[data,amountUnits'];
        headers=[headers,'Amount Units'];
        styles{end+1}='';
    end

    if areValuesDefined(timeUnits)
        data=[data,timeUnits'];
        headers=[headers,'Time Units'];
        styles{end+1}='';
    end

    if areValuesDefined(rateUnits)
        data=[data,rateUnits'];
        headers=[headers,'Rate Units'];
        styles{end+1}='';
    end


    props={'Data Name','Groups'};
    values={set.parameterSetData.DOSEDATASET.selectedDataName,getGroupsSelected(set.parameterSetData.DOSEDATASET)};
    html=buildSectionHeader(html,['Parameter Set (Dose from Data): ',set.name],'');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

    tableHTML=buildTable(headers,data,styles,'');
    html=appendLine(html,tableHTML);

end

function cmd=generateRangeCode(spacing,min,max,numValues)

    if strcmp(spacing,'linear')
        cmd=['linspace(',num2str(min),',',num2str(max),',',num2str(numValues),')'];
    else
        cmd=['logspace(log10(',num2str(min),'), log10(',num2str(max),'),',num2str(numValues),')'];
    end

end

function value=getNumericValue(value)

    if~isnumeric(value)
        value=str2double(value);
    end

end

function out=getGroupsSelected(dataInfo)

    groups=dataInfo.selectedGroups;
    numgroups=numel(groups);




    try
        h=load(dataInfo.dataMATFile);
        data=h.(dataInfo.dataMATFileVariableName);
        data=groupedData(data);
        groupInfo=SimBiology.fit.internal.validateData(data,false);
        if(groupInfo.numGroups==numgroups)
            out='all';
            return;
        end
    catch
    end

    if isnumeric(groups)
        out=mat2str(groups);
    else

        out=createCommaSeparatedList(groups);
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

function out=createCommaSeparatedList(list)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedList',list);

end
