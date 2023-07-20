function[status,msg]=ne_massmatrix_diagnose(ss,input,~,~)













    try
        [inp,sys]=ss.expand(input);
        [status,msg]=ne_massmatrix_diagnose_internal(sys,inp);
    catch ME
        if strcmp(ME.identifier,'physmod:common:mf:system:xform:DifferentNumberOfDifferentialEquationsAndVariables')
            msg=ME.message;
            status=1;
        else
            rethrow(ME);
        end
    end
end
