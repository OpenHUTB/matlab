function ModelBaseRatePriority=getModelBaseRatePriority(ModelName)





    if strcmpi(get_param(ModelName,'LibraryType'),'None')&&...
        ~strcmpi(get_param(ModelName,'SolverType'),'Variable-step')
        sample_time_constraint=get_param(ModelName,'SampleTimeConstraint');
        switch sample_time_constraint
        case{'unconstrained','STIndependent'}
            ModelBaseRatePriority=40;
        case 'Specified'
            sample_times=get_param(ModelName,'SampleTimeProperty');
            ModelBaseRatePriority=sample_times(1).Priority;
        otherwise
            ModelBaseRatePriority=40;
        end
    else
        ModelBaseRatePriority=40;
    end
end
