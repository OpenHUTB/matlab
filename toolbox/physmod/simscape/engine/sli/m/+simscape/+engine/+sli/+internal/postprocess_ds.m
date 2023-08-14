function ds=postprocess_ds(ds)




    if length(ds.VariableData)<length(ds.EquationData)
        pm_error('physmod:simscape:engine:sli:ds2dae:EquationsExceedVariables');
    elseif length(ds.EquationData)<length(ds.VariableData)
        ssys=NetworkEngine.SolverSystem(ds);
        si=ssys.inputs;
        missingGroundFcn=ssc_engmliprivate('ne_missing_ground');
        [~,c_err_string]=feval(missingGroundFcn,ssys,si);
        pm_error('physmod:simscape:engine:sli:ds2dae:VariablesExceedEquations',c_err_string);
    end
end


