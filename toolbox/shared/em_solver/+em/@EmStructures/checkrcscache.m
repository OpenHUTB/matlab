function[calculate_static_soln,calculate_dynamic_soln]=checkrcscache(obj,frequency,kvector,polvector)

    calculate_static_soln=1;
    calculate_dynamic_soln=1;











    if calculate_static_soln
        calculate_dynamic_soln=1;
        obj.SolverStruct.RCSSolution.TransmitKVector=kvector;
        obj.SolverStruct.RCSSolution.PolVector=polvector;
        obj.SolverStruct.RCSSolution.TxAngle=[];
        obj.SolverStruct.RCSSolution.I=[];
        obj.SolverStruct.RCSSolution.Frequency=[];
    end


