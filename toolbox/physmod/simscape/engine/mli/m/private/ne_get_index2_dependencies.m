function[indrows,deprows,T,is_sl,is_nl,vars]=...
    ne_get_index2_dependencies(sys,ss_inputs,is_equation_included,is_linear)








    J=ne_tosparse(sys.DXF_P(ss_inputs),sys.DXF(ss_inputs));
    M=ne_tosparse(sys.M_P(ss_inputs),sys.M(ss_inputs));
    n_d=sys.NumDiffStates;
    n=sys.NumStates;
    MJ=[M(:,1:n_d),J(:,n_d+1:n)];

    [m,n]=size(MJ);
    pm_assert(m==n,'Unexpected Jacobian matrix size');

    if nnz(is_equation_included)~=0
        order_vec=find(is_equation_included);
        pm_assert(length(unique(order_vec))==length(order_vec),'Repeated rows in order_vec');
        [indrows,deprows_all,T_all]=ne_findindrows(MJ,order_vec);
        T=T_all;
        deprows=deprows_all;
    else
        indrows=zeros(1,0);
        deprows=zeros(1,0);
        T=zeros(0,n);
    end

    vars=ne_logical_matrix_product(T,MJ);

    is_switched_linear=sys.SLF(ss_inputs)&~is_linear;
    is_nonlinear=~is_linear&~is_switched_linear;
    is_sl=any(T(:,is_switched_linear),2);
    is_nl=any(T(:,is_nonlinear),2);
