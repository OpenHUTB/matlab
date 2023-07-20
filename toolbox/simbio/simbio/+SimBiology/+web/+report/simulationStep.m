function out=simulationStep(action,varargin)











    out=[];

    switch(action)
    case 'generateHTML'
        out=generateHTML(varargin{:});
    end

end

function out=generateHTML(html,configset,step,input)


    if~isempty(step)&&input.includeProgramStepDescription
        html=buildBlackSectionHeader(html,'Simulation Step',step.description);
    else
        html=buildBlackSectionHeader(html,'Simulation Settings','');
    end



    solverType=configset.SolverType;
    if~isempty(step)&&isfield(step,'solverType')
        solverType=step.solverType;
    end


    if~isempty(step)&&strcmp(step.type,'Sensitivity')
        solverType='sundials';
    end

    solverOptions=getSolverOptionsStruct(configset,solverType);
    isStochastic=any(strcmp(solverType,{'ssa','impltau','expltau'}));


    props=cell(1,4);
    props{1}='StopTime';
    props{2}='TimeUnits';
    props{3}='MaximumNumberOfLogs';
    props{4}='MaximumWallClock';

    values=cell(1,numel(props));
    for i=1:numel(props)
        values{i}=configset.(props{i});
    end



    if~isempty(step)&&...
        ((isfield(step,'useConfigset')&&~step.useConfigset)||...
        (isfield(step,'stopTimeUseConfigset')&&~step.stopTimeUseConfigset))

        values{1}=step.stopTime;
        values{2}=step.stopTimeUnits;
    end

    if~isStochastic
        outputTimes=solverOptions.OutputTimes;
        if~isempty(outputTimes)
            outputTimes=mat2str(outputTimes);
        end

        props{end+1}='OutputTimes';
        values{end+1}=outputTimes;
    end

    html=buildSectionHeader(html,'Simulation Time','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);


    if strcmp(solverType,'ssa')
        props=cell(1,3);
        props{1}='SolverType';
        props{2}='RandomState';
        props{3}='LogDecimation';
    elseif strcmp(solverType,'impltau')
        props=cell(1,6);
        props{1}='SolverType';
        props{2}='ErrorTolerance';
        props{3}='AbsoluteTolerance';
        props{4}='RandomState';
        props{5}='MaxIterations';
        props{6}='LogDecimation';
    elseif strcmp(solverType,'expltau')
        props=cell(1,4);
        props{1}='SolverType';
        props{2}='ErrorTolerance';
        props{3}='RandomState';
        props{4}='LogDecimation';
    else
        props=cell(1,6);
        props{1}='SolverType';
        props{2}='AbsoluteToleranceScaling';
        props{3}='AbsoluteToleranceStepSize';
        props{4}='AbsoluteTolerance';
        props{5}='RelativeTolerance';
        props{6}='MaxStep';
    end

    switch(solverType)
    case 'ode15s'
        solverType='ode15s (stiff/NDF)';
    case 'ode45'
        solverType='ode45 (Dormand-Prince)';
    case 'ode23t'
        solverType='ode23t (Mod. stiff/Trapezoidal)';
    case 'ssa'
        solverType='Stochastic Simulation Algorithm (SSA)';
    case 'impltau'
        solverType='Implicit Tau-Leaping';
    case 'expltau'
        solverType='Explicit Tau-Leaping';
    end

    values=cell(1,numel(props));
    values{1}=solverType;

    for i=2:numel(props)
        values{i}=solverOptions.(props{i});
        if islogical(values{i})
            values{i}=logical2str(values{i});
        end
    end


    if isStochastic&&~isempty(step)&&isfield(step,'logDecimationUseConfigset')
        if~step.logDecimationUseConfigset
            idx=strcmp('LogDecimation',props);
            values{idx}=step.logDecimation;
        end
    end

    html=buildSectionHeader(html,'Solver Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);


    props=cell(1,3);
    props{1}='DimensionalAnalysis';
    props{2}='UnitConversion';
    props{3}='DefaultSpeciesDimension';

    values=cell(1,numel(props));
    for i=1:numel(props)
        values{i}=configset.CompileOptions.(props{i});
        if islogical(values{i})
            values{i}=logical2str(values{i});
        end
    end

    html=buildSectionHeader(html,'Compile Options','');
    tableHTML=buildPropertyValueTable(props,values);
    html=appendLine(html,tableHTML);

    out.html=html;

end

function out=getSolverOptionsStruct(configset,solverType)

    out=[];

    switch(solverType)
    case 'ssa'
        structType='SimBiology.SSASolverOptions';
    case 'impltau'
        structType='SimBiology.ImplicitTauSolverOptions';
    case 'expltau'
        structType='SimBiology.ExplicitTauSolverOptions';
    otherwise
        structType='SimBiology.ODESolverOptions';
    end

    allOptions=configset.AllSolverOptions;
    for i=1:numel(allOptions)
        if strcmp(allOptions{i}.Type,structType)
            out=allOptions{i};
            break;
        end
    end

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

function out=logical2str(value)

    out=SimBiology.web.codegenerationutil('logical2str',value);

end

function code=buildBlackSectionHeader(out,header,description)

    code=SimBiology.web.report.utilhandler('buildBlackSectionHeader',out,header,description);

end
