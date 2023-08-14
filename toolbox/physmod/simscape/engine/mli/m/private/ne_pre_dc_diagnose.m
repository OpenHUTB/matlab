function[status,c_err_string]=ne_pre_dc_diagnose(topSys,...
    topInputs,...
    ~,...
    doNonlin)









    problem_id_alg_only='physmod:simscape:engine:mli:ne_pre_transient_diagnose:DependentOrInconsistentEquations';


    problem_id_including_special='';

    diff_vars_known=false;





    print_messages_including_special=false;
    probably_linear_top=ne_probably_linear_rows(topSys,topInputs);
    if doNonlin
        is_equation_included_top=true(topSys.NumStates,1);
    else
        is_equation_included_top=probably_linear_top;
    end

    [status,c_err_string]=ne_diagnose_internal(topSys,...
    topInputs,...
    problem_id_alg_only,...
    problem_id_including_special,...
    diff_vars_known,...
    print_messages_including_special,...
    is_equation_included_top,...
    probably_linear_top,...
    doNonlin);

