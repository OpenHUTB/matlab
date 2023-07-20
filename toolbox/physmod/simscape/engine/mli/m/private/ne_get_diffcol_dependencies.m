function[status,c_err_string]=ne_get_diffcol_dependencies(sys,MJ)




    nd=sys.NumDiffStates;
    n=sys.NumStates;
    order=[nd+1:n,1:nd];
    [~,dep,T]=ne_findindrows(MJ',order);
    isDiffcolDep=(dep<=sys.NumDiffStates);
    status=0;
    c_err_string='';
    if nnz(isDiffcolDep)>0
        status=1;
        cid='physmod:simscape:engine:mli:ne_pre_transient_diagnose:ComplexDependentVariables';
        c_err_string=ne_message_combining_vars(sys,T(isDiffcolDep,:),cid);
    end
