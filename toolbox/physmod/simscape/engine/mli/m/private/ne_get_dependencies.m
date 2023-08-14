function[indrows,deprows,T,is_sl,is_nl,vars,MJ]=ne_get_dependencies(sys,ss_inputs,diff_vars_known,...
    special_equations,...
    is_row_included,...
    is_linear,jac_fcn)








    pm_assert(~(sys.HasConstraints),...
    'ne_get_dependencies expects HasConstraints to be false: use ne_get_index2_dependencies for HasConstraints true');
    standardJ=nargin<nargin(mfilename)||isempty(jac_fcn);
    if standardJ
        J=ne_sparse_system_method(sys,'DXF',ss_inputs);
        J_analyze=J;
    else
        J_analyze=feval(jac_fcn,sys,ss_inputs);
    end

    num_diff=sys.NumDiffStates;
    [m,n]=size(J_analyze);
    pm_assert(m==n,'Unexpected Jacobian matrix size');

    if diff_vars_known&&sys.NumDiffStates>0





























        M_p=sys.M_P(sys.inputs);
        M_p=M_p(1:num_diff,1:num_diff);
        full_row_match=dmperm(M_p);


        row_match=full_row_match(logical(full_row_match));

        J_analyze(1:num_diff,:)=sparse(num_diff,n);
        J_analyze(row_match,logical(full_row_match))=speye(length(row_match));
        is_row_included(~full_row_match)=false;


        if any(full_row_match==0)
            J_analyze(:,~full_row_match)=0;
        end
    end

    is_special=zeros(n,1);
    is_special(special_equations)=1;














    is_general=cell2mat({sys.EquationData.general});
    is_general=is_general(:);
    is_topology=is_linear&~is_general;
    is_linear_not_topology=is_linear&is_general;
    is_switched_linear=sys.SLF(ss_inputs)&~is_linear;
    is_nonlinear=~is_linear&~is_switched_linear;


    pm_assert(all(is_topology+is_linear_not_topology+is_switched_linear+is_nonlinear)==1);
    if nnz(is_row_included)~=0
        order_vec=[find(is_row_included&~is_special&is_topology);...
        find(is_row_included&~is_special&is_linear_not_topology);...
        find(is_row_included&~is_special&is_switched_linear);...
        find(is_row_included&~is_special&is_nonlinear);...
        find(is_row_included&is_special&is_topology);...
        find(is_row_included&is_special&is_linear_not_topology);...
        find(is_row_included&is_special&is_switched_linear);...
        find(is_row_included&is_special&is_nonlinear)];
        pm_assert(length(unique(order_vec))==length(order_vec),'Repeated rows in order_vec');
        [indrows,deprows_all,T_all]=ne_findindrows(J_analyze,order_vec);


        T_all_alg=T_all;
        T_all_alg(:,1:num_diff)=0;

        df_variable=sys.DXF_V_X(ss_inputs)|sys.DUF_V_X(ss_inputs)|sys.DTF_V_X(ss_inputs);

        df_nonlin=df_variable&(~sys.SLF(ss_inputs));
        T_alg_part_of_row_involves_nonlin_in_xut=double(logical(T_all_alg))*double(df_nonlin);




        is_unfixable_T_row=T_alg_part_of_row_involves_nonlin_in_xut|~any(T_all(:,1:num_diff),2);
        deprows=deprows_all(is_unfixable_T_row);
        deprows_fixable=deprows_all(~is_unfixable_T_row);
        T=T_all(is_unfixable_T_row,:);
        T_fixable=T_all(~is_unfixable_T_row,:);
    else
        indrows=zeros(1,0);
        deprows=zeros(1,0);
        deprows_fixable=[];
        T=zeros(0,n);
    end

    vars=ne_logical_matrix_product(T,J_analyze);


    if standardJ





















        M=ne_sparse_system_method(sys,'M',ss_inputs);
        MJ=[M(:,1:sys.NumDiffStates),J(:,sys.NumDiffStates+1:sys.NumStates)];
        if~isempty(deprows_fixable)
            diffi=1:sys.NumDiffStates;
            algi=sys.NumDiffStates+1:sys.NumStates;
            nAlg=sys.NumStates-sys.NumDiffStates;
            nFixable=size(T_fixable,1);
            sc=[T_fixable(:,algi)*J(algi,diffi),sparse(nFixable,nAlg)];
            MJ=[MJ;sc];
        end
    else
        MJ=[];
    end

    is_sl=any(T(:,is_switched_linear),2);
    is_nl=any(T(:,is_nonlinear),2);
