function[retVal,schema]=Render(hThis,schema)%#ok<INUSD>













    retVal=true;

    [~,schema]=hThis.renderChildren();
    schema=schema{1};


    useFtolOnly=strcmpi(get(hThis.BlockHandle,'ConsistencySolver'),'NEWTON_FTOL');
    useConsistencyTol=~useFtolOnly;
    if useConsistencyTol
        consistencyTolSourceSchema=pmsl_extractdialogschema(...
        schema,'Type','combobox',...
        'Name',getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyTolerance')));

        consistencyTolSourceSchema.Source.Listeners{1}=@l_update_consistency_tols_status;

        [consistencyAbsTolSchema,consistencyAbsTolPath]=pmsl_extractdialogschema(...
        schema,'Type','edit',...
        'Name',l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyAbsoluteTolerance'))));
        [consistencyRelTolSchema,consistencyRelTolPath]=pmsl_extractdialogschema(...
        schema,'Type','edit',...
        'Name',l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyRelativeTolerance'))));

        consistencyAbsTolSchema.Enabled=l_get_consistency_tols_status(l_init_getter);
        consistencyRelTolSchema.Enabled=l_get_consistency_tols_status(l_init_getter);

        schema=pmsl_updatedialogschema(schema,consistencyAbsTolSchema,consistencyAbsTolPath);
        schema=pmsl_updatedialogschema(schema,consistencyRelTolSchema,consistencyRelTolPath);
    end


    [fixedCostCheckBoxSchema]=pmsl_extractdialogschema(schema,'Type','checkbox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:DoFixedCost')));
    fixedCostCheckBoxSchema.Source.Listeners={
    @l_update_mode_iteration_status
    @l_update_nonlin_iter_status
    @l_update_compute_impulses_status
    @l_update_impulse_iterations_status
    @l_update_function_eval_num_thread_status
    @l_update_res_indet_status
    };

    [nonlinIterSchema,nonlinIterPath]=pmsl_extractdialogschema(schema,'Type','edit','Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:MaxNonlinIter'))));
    [modeIterSchema,modeIterPath]=pmsl_extractdialogschema(schema,'Type','edit','Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:MaxModeIter'))));

    [computeImpulsesSchema,computeImpulsesPath]=pmsl_extractdialogschema(schema,'Type','checkbox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:ComputeImpulses')));
    computeImpulsesSchema.Source.Listeners={@l_update_impulse_iterations_status};

    [impulseIterationsSchema,impulseIterationsPath]=pmsl_extractdialogschema(schema,'Type','edit','Name',l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:ImpulseIterations'))));

    [localSolverCheckBoxSchema]=pmsl_extractdialogschema(schema,'Type','checkbox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:UseLocalSolver')));
    localSolverCheckBoxSchema.Source.Listeners={
    @l_update_fixed_cost_value
    @l_update_mode_iteration_status
    @l_update_partitioning_status
    @l_update_part_budget_status
    @l_update_function_eval_num_thread_status
    @l_update_res_indet_status
    };

    [advChoiceSchema,advChoicePath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:SolverType'))));
    advChoiceSchema.Source.Listeners={
    @l_update_partitioning_status
    @l_update_part_budget_status
    @l_update_function_eval_num_thread_status
    @l_update_res_indet_status
    };

    [resIndetCheckBoxSchema,resIndetCheckBoxPath]=pmsl_extractdialogschema(schema,'Type','checkbox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:ResolveIndetEquations')));

    [functionEvalNumThreadSchema,functionEvalNumThreadPath]=pmsl_extractdialogschema(schema,'Type','edit','Name',l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:FunctionEvalNumThread'))));

    [advStepsizeSchema,advStepsizePath]=pmsl_extractdialogschema(schema,'Type','edit',...
    'Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:LocalSolverSampleTime'))));
    [partMethodSchema,partMethodPath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionMethod'))));

    [partChoiceSchema,partChoicePath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionStorageMethod'))));
    partChoiceSchema.Source.Listeners={@l_update_part_budget_status};

    [partBudgetSchema,partBudgetPath]=pmsl_extractdialogschema(schema,'Type','edit',...
    'Name',sprintf('     %s',getString(message('physmod:ne_sli:nesl_utility:solver:PartitionMemoryBudget'))));

    [equationFormulationSchema,equationFormulationPath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:EquationFormulation')));

    equationFormulationSchema.Source.Listeners={@l_update_index_reduction_status};

    [indexReductionSchema,indexReductionPath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:IndexReductionMethod')));

    applyFilteringSchema=pmsl_extractdialogschema(schema,'Type','checkbox',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:AutomaticFiltering')));
    [filteringConstantSchema,filteringConstantPath]=pmsl_extractdialogschema(schema,'Type','edit',...
    'Name',getString(message('physmod:ne_sli:nesl_utility:solver:FilteringTimeConstant')));

    [linearAlgebraSchema,linearAlgebraPath]=pmsl_extractdialogschema(schema,'Type','combobox',...
    'Name',sprintf('%s',getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebra'))));
    linearAlgebraSchema.Source.Listeners={@l_update_linear_algebra_num_thread_status};

    [linearAlgebraNumThreadSchema,linearAlgebraNumThreadPath]=pmsl_extractdialogschema(schema,'Type','edit','Name',l_indent(getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraNumThread'))));


    numBuddySoFar=0;
    advChoiceSchema=l_connect_to_checkbox(localSolverCheckBoxSchema,advChoiceSchema);
    advStepsizeSchema=l_connect_to_checkbox(localSolverCheckBoxSchema,advStepsizeSchema);
    filteringConstantSchema=l_connect_to_checkbox(applyFilteringSchema,filteringConstantSchema);


    modeIterSchema.Enabled=l_get_mode_iteration_status(l_init_getter);
    nonlinIterSchema.Enabled=l_get_nonlin_iter_status(l_init_getter);
    computeImpulsesSchema.Enabled=l_get_compute_impulses_status(l_init_getter);
    impulseIterationsSchema.Enabled=l_get_impulse_iterations_status(l_init_getter);
    partMethodSchema.Enabled=l_get_partitioning_status(l_init_getter);
    partChoiceSchema.Enabled=l_get_partitioning_status(l_init_getter);
    partBudgetSchema.Enabled=l_get_part_budget_status(l_init_getter);
    indexReductionSchema.Enabled=l_get_index_reduction_status(l_init_getter);
    linearAlgebraNumThreadSchema.Enabled=l_get_linear_algebra_num_thread_status(l_init_getter);
    functionEvalNumThreadSchema.Enabled=l_get_function_eval_num_thread_status(l_init_getter);
    resIndetCheckBoxSchema.Enabled=l_get_res_indet_status(l_init_getter);


    schema=pmsl_updatedialogschema(schema,nonlinIterSchema,nonlinIterPath);
    schema=pmsl_updatedialogschema(schema,modeIterSchema,modeIterPath);
    schema=pmsl_updatedialogschema(schema,computeImpulsesSchema,computeImpulsesPath);
    schema=pmsl_updatedialogschema(schema,impulseIterationsSchema,impulseIterationsPath);
    schema=pmsl_updatedialogschema(schema,advChoiceSchema,advChoicePath);
    schema=pmsl_updatedialogschema(schema,advStepsizeSchema,advStepsizePath);
    schema=pmsl_updatedialogschema(schema,partMethodSchema,partMethodPath);
    schema=pmsl_updatedialogschema(schema,partChoiceSchema,partChoicePath);
    schema=pmsl_updatedialogschema(schema,partBudgetSchema,partBudgetPath);
    schema=pmsl_updatedialogschema(schema,indexReductionSchema,indexReductionPath);
    schema=pmsl_updatedialogschema(schema,filteringConstantSchema,filteringConstantPath);
    schema=pmsl_updatedialogschema(schema,linearAlgebraSchema,linearAlgebraPath);
    schema=pmsl_updatedialogschema(schema,linearAlgebraNumThreadSchema,linearAlgebraNumThreadPath);
    schema=pmsl_updatedialogschema(schema,resIndetCheckBoxSchema,resIndetCheckBoxPath);
    schema=pmsl_updatedialogschema(schema,functionEvalNumThreadSchema,functionEvalNumThreadPath);

    function out=l_get_consistency_tols_status(getter)
        if useConsistencyTol
            out=l_expect(consistencyTolSourceSchema,getter,...
            getString(message('physmod:ne_sli:nesl_utility:solver:ConsistencyToleranceLocal')));
        else
            out=false;
        end
    end

    function l_update_consistency_tols_status(~,hDlg,~,~)
        if useConsistencyTol
            usingLocalTolerances=l_get_consistency_tols_status(l_update_getter(hDlg));
            hDlg.setEnabled(consistencyAbsTolSchema.Tag,usingLocalTolerances);
            hDlg.setEnabled(consistencyRelTolSchema.Tag,usingLocalTolerances);
        end
    end

    function widget=l_connect_to_checkbox(checkBox,widget)



        widget.Enabled=widget.Source.EnableStatus&&checkBox.Value;
        checkBoxSource=checkBox.Source;
        numBuddySoFar=numBuddySoFar+1;
        checkBoxSource.buddyItemsTags{numBuddySoFar}=widget.Tag;
        checkBoxSource.ResolveBuddyTags=true;
    end

    function ans=l_indent(str)
        ans=sprintf('     %s',str);
    end

    function l_update_fixed_cost_value(~,hDlg,~,~)
        localSolverValue=hDlg.getWidgetValue(localSolverCheckBoxSchema.Tag);
        hDlg.setWidgetValue(fixedCostCheckBoxSchema.Tag,...
        localSolverValue);
        hThis.TagSearch(fixedCostCheckBoxSchema.Tag,'Partial','First').Value=localSolverValue;
        l_update_nonlin_iter_status([],hDlg,[],[]);
    end

    function out=l_get_mode_iteration_status(getter)
        out=modeIterSchema.Source.EnableStatus&&getter(fixedCostCheckBoxSchema)&&~getter(localSolverCheckBoxSchema);
    end

    function l_update_mode_iteration_status(~,hDlg,~,~)
        hDlg.setEnabled(modeIterSchema.Tag,l_get_mode_iteration_status(l_update_getter(hDlg)));
    end

    function out=l_get_nonlin_iter_status(getter)
        out=nonlinIterSchema.Source.EnableStatus&&getter(fixedCostCheckBoxSchema);
    end

    function l_update_nonlin_iter_status(~,hDlg,~,~)
        hDlg.setEnabled(nonlinIterSchema.Tag,l_get_nonlin_iter_status(l_update_getter(hDlg)));
    end

    function out=l_get_compute_impulses_status(getter)
        out=computeImpulsesSchema.Source.EnableStatus&&getter(fixedCostCheckBoxSchema);
    end

    function l_update_compute_impulses_status(~,hDlg,~,~)
        hDlg.setEnabled(computeImpulsesSchema.Tag,l_get_compute_impulses_status(l_update_getter(hDlg)));
    end

    function out=l_get_impulse_iterations_status(getter)
        out=impulseIterationsSchema.Source.EnableStatus&&getter(fixedCostCheckBoxSchema)&&getter(computeImpulsesSchema);
    end

    function l_update_impulse_iterations_status(~,hDlg,~,~)
        hDlg.setEnabled(impulseIterationsSchema.Tag,l_get_impulse_iterations_status(l_update_getter(hDlg)));
    end

    function out=l_get_partitioning_status(getter)
        usingLocalSolver=getter(localSolverCheckBoxSchema);
        usingPartitioning=l_expect(advChoiceSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypePartitioning')));
        out=partChoiceSchema.Source.EnableStatus&&partMethodSchema.Source.EnableStatus&&usingLocalSolver&&usingPartitioning;
    end

    function l_update_partitioning_status(~,hDlg,~,~)
        hDlg.setEnabled(partMethodSchema.Tag,l_get_partitioning_status(l_update_getter(hDlg)));
        hDlg.setEnabled(partChoiceSchema.Tag,l_get_partitioning_status(l_update_getter(hDlg)));
    end

    function out=l_get_part_budget_status(getter)
        usingLocalSolver=getter(localSolverCheckBoxSchema);
        usingPartitioning=l_expect(advChoiceSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypePartitioning')));
        usingOfflineCaching=l_expect(partChoiceSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:PartitioningCachingOffline')));
        out=partBudgetSchema.Source.EnableStatus&&usingLocalSolver&&usingPartitioning&&usingOfflineCaching;
    end

    function out=l_get_index_reduction_status(getter)
        freq=l_expect(equationFormulationSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:EquationFormulationFrequencyTime')));
        out=indexReductionSchema.Source.EnableStatus&&~freq;
    end

    function l_update_index_reduction_status(~,hDlg,~,~)
        hDlg.setEnabled(indexReductionSchema.Tag,l_get_index_reduction_status(l_update_getter(hDlg)));
    end

    function l_update_part_budget_status(~,hDlg,~,~)
        hDlg.setEnabled(partBudgetSchema.Tag,l_get_part_budget_status(l_update_getter(hDlg)));
    end

    function out=l_get_linear_algebra_num_thread_status(getter)
        usingLocalSolver=getter(localSolverCheckBoxSchema);
        usingSparseLinearAlgebra=l_expect(linearAlgebraSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:LinearAlgebraSparse')));
        out=linearAlgebraNumThreadSchema.Source.EnableStatus&&usingLocalSolver&&usingSparseLinearAlgebra;
    end

    function l_update_linear_algebra_num_thread_status(~,hDlg,~,~)
        hDlg.setEnabled(linearAlgebraNumThreadSchema.Tag,l_get_linear_algebra_num_thread_status(l_update_getter(hDlg)));
    end

    function out=l_get_function_eval_num_thread_status(getter)
        usingLocalSolver=getter(localSolverCheckBoxSchema);
        usingBackwardEuler=l_expect(advChoiceSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypeBackward')));
        out=functionEvalNumThreadSchema.Source.EnableStatus&&usingLocalSolver&&usingBackwardEuler&&getter(fixedCostCheckBoxSchema);
    end

    function l_update_function_eval_num_thread_status(~,hDlg,~,~)
        hDlg.setEnabled(functionEvalNumThreadSchema.Tag,l_get_function_eval_num_thread_status(l_update_getter(hDlg)));
    end

    function out=l_get_res_indet_status(getter)
        usingLocalSolver=getter(localSolverCheckBoxSchema);
        usingPartitioning=l_expect(advChoiceSchema,getter,getString(message('physmod:ne_sli:nesl_utility:solver:SolverTypePartitioning')));
        IsRegSolver=(usingLocalSolver&&~usingPartitioning)||~usingLocalSolver;
        out=resIndetCheckBoxSchema.Source.EnableStatus&&getter(fixedCostCheckBoxSchema)&&IsRegSolver;
    end

    function l_update_res_indet_status(~,hDlg,~,~)
        hDlg.setEnabled(resIndetCheckBoxSchema.Tag,l_get_res_indet_status(l_update_getter(hDlg)));
    end

    function getter=l_update_getter(hDlg)
        getter=@(sch)(hDlg.getWidgetValue(sch.Tag));
    end

    function getter=l_init_getter
        getter=@(sch)(sch.Value);
    end

    function out=l_expect(sch,getter,choice)
        idx=find(strcmp(sch.Entries,choice));
        assert(isscalar(idx));
        x=getter(sch);
        if ischar(x)
            out=strcmp(choice,x);
        else
            idx=idx-1;
            out=idx==x;
        end
    end

end



