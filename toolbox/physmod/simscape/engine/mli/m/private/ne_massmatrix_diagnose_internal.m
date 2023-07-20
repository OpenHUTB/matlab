function[status,msg]=ne_massmatrix_diagnose_internal(sys,inp,~,~)

































    status=0;
    msg='';
    if(sys.NumStates==0||...
        sys.NumDiffStates==0)
        return;
    end

    M=ne_sparse_system_method(sys,'M',inp);
    Mdd=M(1:sys.NumDiffStates,1:sys.NumDiffStates);



    zeroCols=all(Mdd==0,1);
    if any(zeroCols)
        ret=sprintf('\n');
        str='';
        hyperlinks=ne_variable_hyperlink(sys,zeroCols);
        for i=1:length(hyperlinks)
            str=[str,ret,hyperlinks{i}];%#ok
        end
        msg=pm_message('physmod:simscape:engine:mli:ne_massmatrix_diagnostics:MixedDiffAlgVariables',str);
        status=1;
        return
    end



    zeroRows=all(Mdd==0,2);
    if any(zeroRows)
        ret=sprintf('\n');
        [m,~]=size(M);
        rows=find(zeroRows');
        str='';
        for row=rows
            iwant=false(1,m);
            iwant(row)=true;
            one_err_string=ne_get_one_err_string(iwant,...
            sys.EquationData,...
            sys.EquationRange);
            str=[str,ret,one_err_string];%#ok
        end
        msg=pm_message('physmod:simscape:engine:mli:ne_massmatrix_diagnostics:MixedDiffAlgEquations',str);
        status=1;
        return
    end
end
