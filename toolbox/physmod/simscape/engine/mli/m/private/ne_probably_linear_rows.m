function is_linear=ne_probably_linear_rows(sys,inputs_in)






    ss_inputs=inputs_in.clone;

    J=ne_tosparse(sys.DXF_P(ss_inputs),sys.DXF(ss_inputs));
    J_v_x=sys.DXF_V_X(ss_inputs);




    is_definitely_linear=(J_v_x==0);





    u=ss_inputs.U;
    x=ss_inputs.X;

    xu_fixed=[x;u];
    xu_fixed(isnan(xu_fixed))=1;
    xu_fixed(isinf(xu_fixed))=1e8;
    pertvec=max(abs(xu_fixed),1e-8);
    pertXU=[x;u]+1e24*pertvec;
    pertX=pertXU(1:sys.NumStates);
    pertU=pertXU(sys.NumStates+1:sys.NumStates+sys.NumInputs);
    ss_inputs.U=pertU;
    ss_inputs.X=pertX;
    pertM=sys.MODE(ss_inputs);
    ss_inputs.M=pertM;

    pertJ=ne_tosparse(sys.DXF_P(ss_inputs),sys.DXF(ss_inputs));
    diffJ=pertJ-J;




    is_linear_from_perturbation=~any(diffJ,2)&~any(isnan(diffJ),2)&~sys.SLF(ss_inputs);
    is_linear=is_definitely_linear|is_linear_from_perturbation;

