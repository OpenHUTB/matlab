function[status,ABCD,c_err_id,c_err_msg]=ne_linearize(sys,input)



























    input.M=sys.MODE(input);
    sys.RESET(input);



    ld.n=sys.NumStates;
    ld.n_d=sys.NumDiffStates;
    ld.n_u=sys.NumInputs;
    ld.n_o=sys.NumOutputs;
    ld.h_c=sys.HasConstraints;
    ld.Mpattern=sys.M_P(input);
    ld.M=ne_tosparse(ld.Mpattern,sys.M(input));
    ld.J=ne_tosparse(sys.DXF_P(input),sys.DXF(input));
    ld.dfdu=ne_tosparse(sys.DUF_P(input),sys.DUF(input));


    ld.dydx=ne_tosparse(sys.DXY_P(input),sys.DXY(input));
    ld.dydu=ne_tosparse(sys.DUY_P(input),sys.DUY(input));


    ld.dMdx=ne_tosparse(sys.DXM_P(input),sys.DXM(input));
    ld.dMdu=ne_tosparse(sys.DUM_P(input),sys.DUM(input));
    ld.fval=sys.F(input);
    if ld.h_c
        ld.dcdx=ne_tosparse(sys.DXC_P(input),sys.DXC(input));



        ld.dcdu=local_get_dc_du(sys,input);
    end
    [status,ABCD,c_err_id,c_err_msg]=ne_linearize_math(ld);


    function dc_du=local_get_dc_du(sys,input)


        n_u=sys.NumInputs;
        n_x=sys.NumStates;
        dc_du=sparse(n_x,n_u);



        cached_u=input.U;
        input.U=zeros(n_u,1);
        c0=sys.C(input);
        for i=1:n_u
            input.U(i)=1;
            dc_du(:,i)=sys.C(input)-c0;
            input.U(i)=0;
        end
        input.U=cached_u;

