function[status,c_err_string,T]=ne_diagnose_internal(topSys,...
    topInputs,...
    problem_id_alg_only,...
    problem_id_including_special,...
    diff_vars_known,...
    print_messages_including_special,...
    is_equation_included_top,...
    is_equation_linear_top,...
    doNonlin,...
    jac_fcn)


















    if nargin<nargin(mfilename)
        jac_fcn=[];
    end

    [status,c_err_string,T]=local_diagnose_internal(topSys,...
    topInputs,...
    problem_id_alg_only,...
    problem_id_including_special,...
    diff_vars_known,...
    print_messages_including_special,...
    is_equation_included_top,...
    is_equation_linear_top,...
    jac_fcn);

    if status

        [ss_inputs,sys]=topSys.expand(topInputs);

        probably_linear=ne_probably_linear_rows(sys,ss_inputs);
        if doNonlin
            is_equation_included=true(sys.NumStates,1);
        else
            is_equation_included=probably_linear;
        end







        sys=sys.regularize;
        ss_inputs.M=sys.MODE(ss_inputs);
        sys.RESET(ss_inputs);
        [sysStatus,sys_c_err_string,sysT]=local_diagnose_internal(sys,...
        ss_inputs,...
        problem_id_alg_only,...
        problem_id_including_special,...
        diff_vars_known,...
        print_messages_including_special,...
        is_equation_included,...
        probably_linear,...
        jac_fcn);
        if sysStatus



            status=sysStatus;
            c_err_string=sys_c_err_string;
            T=sysT;
        end
    end


    function[status,c_err_string,T]=local_diagnose_internal(sys,...
        ss_inputs,...
        problem_id_alg_only,...
        problem_id_including_special,...
        diff_vars_known,...
        print_messages_including_special,...
        is_equation_included,...
        is_equation_linear,...
        jac_fcn)
        if nargin<7
            print_messages_including_special=true;
        end

        status=0;
        c_err_string='';

        if sys.IsMConstant



            [status1,c_err_string1]=ne_massmatrix_diagnose_internal(sys,ss_inputs,sys);
            status=max(status,status1);
            c_err_string=[c_err_string,c_err_string1];
        end

        [status1,c_err_string1]=ne_missing_ground(sys,ss_inputs);
        status=max(status,status1);
        c_err_string=[c_err_string,c_err_string1];

        special_equations=1:sys.NumDiffStates;

        if sys.HasConstraints
            [~,deprows,T,is_sl,is_nl,vars]=ne_get_index2_dependencies(sys,ss_inputs,...
            is_equation_included,...
            is_equation_linear);
        else
            [~,deprows,T,is_sl,is_nl,vars,MJ]=...
            ne_get_dependencies(sys,ss_inputs,diff_vars_known,special_equations,...
            is_equation_included,...
            is_equation_linear,jac_fcn);
            if all(is_equation_included)&&~isempty(deprows)&&~isempty(MJ)
                [status_cols,c_err_string_cols]=...
                ne_get_diffcol_dependencies(sys,MJ);
                status=max(status,status_cols);
                c_err_string=[c_err_string,c_err_string_cols];
            end
        end

        status=max(status,1.0*(~isempty(deprows)));
        if~status

            return;
        end

        for i=1:length(deprows)
            pm_assert(nnz(T(i,deprows))==1&&T(i,deprows(i))==1,'Bad T structure.');
            [one_err_string,topology_only]=ne_get_one_err_string(T(i,:),...
            sys.EquationData,...
            sys.EquationRange,...
            sys.VariableData,...
            vars(i,:));
            equation_type_string='';
            if is_sl(i)&&~is_nl(i)
                equation_type_string=[' '...
                ,pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:IncludingSwitchedLinear')];
            elseif~is_sl(i)&&is_nl(i)
                equation_type_string=[' '...
                ,pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:IncludingNonlinear')];
            elseif is_sl(i)&&is_nl(i)
                equation_type_string=[' '...
                ,pm_message('physmod:simscape:engine:mli:ne_pre_transient_diagnose:IncludingSwitchedAndNonLinear');];
            end

            if topology_only
                problem_string='';
            elseif any(T(i,special_equations))
                if~print_messages_including_special
                    continue;
                end
                problem_string=pm_message(problem_id_including_special,equation_type_string);
            else
                problem_string=pm_message(problem_id_alg_only,equation_type_string);
            end

            one_err_string=[problem_string,one_err_string];
            c_err_string=[c_err_string,sprintf('%s\n',one_err_string)];
        end

