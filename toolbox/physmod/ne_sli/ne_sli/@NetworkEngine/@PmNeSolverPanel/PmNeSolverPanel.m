function hObj=PmNeSolverPanel(varargin)








    hObj=NetworkEngine.PmNeSolverPanel;
    hObj.CreateInstanceFcn=PMDialogs.PmCreateInstance;

    narginchk(1,1);
    pm_assert(ishandle(varargin{1}));
    hObj.BlockHandle=varargin{1};

    hSlBlk=pmsl_getdoublehandle(hObj.BlockHandle);

    descPnl=PMDialogs.PmDescriptionPanel(hSlBlk);

    paramPanel=PMDialogs.PmGroupPanel(hSlBlk,getString(message('physmod:ne_sli:nesl_utility:common:ParametersContainer')),'Box');




    equationFormulationPnl=PMDialogs.PmDropDown(...
    hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:EquationFormulation')),...
    'EquationFormulation',...
    {getString(message('physmod:ne_sli:nesl_utility:solver:EquationFormulationTime')),...
    getString(message('physmod:ne_sli:nesl_utility:solver:EquationFormulationFrequencyTime'))},...
    1,...
    '',...
    [],...
    {'NE_TIME_EF','NE_FREQUENCY_TIME_EF'}...
    );
    paramPanel.Items=equationFormulationPnl;


    indexReductionMethodPnl=PMDialogs.PmDropDown(...
    hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:IndexReductionMethod')),...
    'IndexReductionMethod',...
    {getString(message('physmod:ne_sli:nesl_utility:solver:IndexReductionMethodNone')),...
    getString(message('physmod:ne_sli:nesl_utility:solver:IndexReductionMethodDerivativeReplacement')),...
    getString(message('physmod:ne_sli:nesl_utility:solver:IndexReductionMethodProjection'))},...
    1,...
    'DerivativeReplacements',...
    [],...
    {'None','DerivativeReplacement','Projection'});
    paramPanel.Items(end+1)=indexReductionMethodPnl;


    doDCCheck=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:SteadyState')),...
    'DoDC',...
    0);
    paramPanel.Items(end+1)=doDCCheck;

    showResidualTolerance=strcmpi(get_param(hSlBlk,'ConsistencySolver'),'NEWTON_FTOL');

    if showResidualTolerance


        tolEditPnl=PMDialogs.PmEditBox(hSlBlk,...
        getString(message('physmod:ne_sli:nesl_utility:solver:ResidualTolerance')),...
        'ResidualTolerance',...
        1);
        paramPanel.Items(end+1)=tolEditPnl;

    else


        consistencyTolSource=PMDialogs.PmDropDown(...
        hSlBlk,...
        getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyTolerance')),...
        'ConsistencyTolSource',{
        getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyToleranceGlobal')),...
        getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyToleranceLocal'))
        }',1,'',...
        [],...
        {
'GLOBAL'
'LOCAL'
        }');
        paramPanel.Items(end+1)=consistencyTolSource;

        consistencyAbsTol=PMDialogs.PmEditBox(hSlBlk,...
        l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyAbsoluteTolerance'))),...
        'ConsistencyAbsTol',...
        1);
        paramPanel.Items(end+1)=consistencyAbsTol;

        consistencyRelTol=PMDialogs.PmEditBox(hSlBlk,...
        l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyRelativeTolerance'))),...
        'ConsistencyRelTol',...
        1);
        paramPanel.Items(end+1)=consistencyRelTol;

        consistencyTolFactor=PMDialogs.PmEditBox(hSlBlk,...
        l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyToleranceFactor'))),...
        'ConsistencyTolFactor',...
        1);
        paramPanel.Items(end+1)=consistencyTolFactor;

    end


    useAdvancerPnl=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:UseLocalSolver')),...
    'UseLocalSolver',...
    0);
    paramPanel.Items(end+1)=useAdvancerPnl;


    advancerPanel=PMDialogs.PmDropDown(...
    hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:SolverType'))),...
    'LocalSolverChoice',{
    getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypeBackward'))
    getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypeTrapezoidal'))
    getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypePartitioning'))
    }',1,'',...
    [],...
    {
'NE_BACKWARD_EULER_ADVANCER'
'NE_TRAPEZOIDAL_ADVANCER'
'NE_PARTITIONING_ADVANCER'
    }');
    paramPanel.Items(end+1)=advancerPanel;


    fixedStepPnl=PMDialogs.PmEditBox(hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:LocalSolverSampleTime'))),'LocalSolverSampleTime',1);
    paramPanel.Items(end+1)=fixedStepPnl;



    partitioningMethod=PMDialogs.PmDropDown(...
    hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionMethod'))),...
    'PartitionMethod',{
    getString(message('physmod:ne_sli:nesl_utility:solver:PartitioningMethodRobust'))
    getString(message('physmod:ne_sli:nesl_utility:solver:PartitioningMethodFast'))
    }',1,'',...
    [],...
    {
'ROBUST'
'FAST'
    }');
    paramPanel.Items(end+1)=partitioningMethod;


    partitioningPanel=PMDialogs.PmDropDown(...
    hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionStorageMethod'))),...
    'PartitionStorageMethod',{
    getString(message('physmod:ne_sli:nesl_utility:solver:PartitioningCachingOnline'))
    getString(message('physmod:ne_sli:nesl_utility:solver:PartitioningCachingOffline'))
    }',1,'',...
    [],...
    {
'AS_NEEDED'
'EXHAUSTIVE'
    }');
    paramPanel.Items(end+1)=partitioningPanel;


    partitioningBudget=PMDialogs.PmEditBox(hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionMemoryBudget'))),'PartitionMemoryBudget',1);
    paramPanel.Items(end+1)=partitioningBudget;


    doFixedCostCheck=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:DoFixedCost')),...
    'DoFixedCost',...
    1);
    paramPanel.Items(end+1)=doFixedCostCheck;


    maxNonlinIterPnl=PMDialogs.PmEditBox(hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:MaxNonlinIter'))),...
    'MaxNonlinIter',1);
    paramPanel.Items(end+1)=maxNonlinIterPnl;


    maxModeIterPnl=PMDialogs.PmEditBox(hSlBlk,...
    sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:MaxModeIter'))),...
    'MaxModeIter',1);
    paramPanel.Items(end+1)=maxModeIterPnl;


    resolveIndetEquationsCheck=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:ResolveIndetEquations')),...
    'ResolveIndetEquations',...
    0);

    paramPanel.Items(end+1)=resolveIndetEquationsCheck;


    functionEvalNumThreadPnl=PMDialogs.PmEditBox(hSlBlk,...
    l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:FunctionEvalNumThread'))),...
    'FunctionEvalNumThread',1);
    paramPanel.Items(end+1)=functionEvalNumThreadPnl;


    computeImpulsesCheck=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:ComputeImpulses')),...
    'ComputeImpulses',...
    1);
    paramPanel.Items(end+1)=computeImpulsesCheck;


    ImpulseIterationsEdit=PMDialogs.PmEditBox(hSlBlk,...
    l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ImpulseIterations'))),...
    'ImpulseIterations',1);
    paramPanel.Items(end+1)=ImpulseIterationsEdit;


    linearAlgebraPnl=PMDialogs.PmDropDown(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebra')),...
    'LinearAlgebra',{getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraAuto')),...
    getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraSparse')),...
    getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraFull'))},1,'',...
    [],{'auto','Sparse','Full'});
    paramPanel.Items(end+1)=linearAlgebraPnl;

    linearAlgebraNumThreadPnl=PMDialogs.PmEditBox(hSlBlk,...
    l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraNumThread'))),...
    'LinearAlgebraNumThread',1);
    paramPanel.Items(end+1)=linearAlgebraNumThreadPnl;


    delaysMemBudgetPnl=PMDialogs.PmEditBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:DelaysMemoryBudget')),...
    'DelaysMemoryBudget',1);
    paramPanel.Items(end+1)=delaysMemBudgetPnl;


    applyFilteringPnl=PMDialogs.PmCheckBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:AutomaticFiltering')),...
    'AutomaticFiltering',0);
    paramPanel.Items(end+1)=applyFilteringPnl;


    timeConstantPnl=PMDialogs.PmEditBox(hSlBlk,...
    getString(message('physmod:ne_sli:nesl_utility:solver:FilteringTimeConstant')),...
    'FilteringTimeConstant',1);
    paramPanel.Items(end+1)=timeConstantPnl;

    wholePanel=PMDialogs.PmGroupPanel(hSlBlk,'','NoBoxNoTitle');
    wholePanel.Items=[descPnl,paramPanel];

    hObj.Items=wholePanel;

end

function ans=l_indent(str)
    ans=sprintf('     %s',str);
end
