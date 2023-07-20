function postprocess_check_on_zc(solver,dae_or_ds,sp)




    solver=get_param(solver,'Handle');




    isVariableSolver=strcmpi('Variable-step',...
    get_param(bdroot(solver),'SolverType'));
    isZcGloballyOff=strcmpi('DisableAll',...
    get_param(bdroot(solver),'ZeroCrossControl'));
    hasZcSignals=(numel(dae_or_ds.ZCData)>0);

    if isVariableSolver&&...
        hasZcSignals&&...
        isZcGloballyOff&&...
        ~sp.UseLocalSolver

        user_pref=...
        pmsl_modelparameter(bdroot(solver),...
        'GlobalZcOffDiagnosticOptions','warning',true,'warning');
        warnForZcOff=strcmpi(user_pref,'warning');

        if warnForZcOff
            pm_warning('physmod:simscape:engine:sli:zc:ZeroCrossingsGloballyOff');
        else
            pm_error('physmod:simscape:engine:sli:zc:ZeroCrossingsGloballyOff');
        end
    end
end


