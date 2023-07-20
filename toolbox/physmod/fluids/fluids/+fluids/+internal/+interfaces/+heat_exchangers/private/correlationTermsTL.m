





function[corr_term,T_seg,h_out,T_out,mu_out,k_out,Pr_out]...
    =correlationTermsTL(Q_seg,h_in,T_in,mu_in,k_in,Pr_in,props)

%#codegen
    coder.allowpcode('plain')

    a=props.a;
    b=props.b;
    c=props.c;


    h_out=h_in+Q_seg/props.mdot;


    T_out=interp1(props.h_TLU,props.T_TLU,h_out,'linear','extrap');
    T_out_limited=min(max(T_out,props.T_TLU(1)),props.T_TLU(end));


    mu_out=interp1(props.T_TLU,props.mu_TLU,T_out_limited,'linear','extrap');
    k_out=interp1(props.T_TLU,props.k_TLU,T_out_limited,'linear','extrap');
    Pr_out=interp1(props.T_TLU,props.Pr_TLU,T_out_limited,'linear','extrap');


    T_seg=(T_in+T_out)/2;
    mu_seg=(mu_in+mu_out)/2;
    k_seg=(k_in+k_out)/2;
    Pr_seg=(Pr_in+Pr_out)/2;


    Re_seg=abs(props.mdot)/mu_seg*props.DS_ratio;


    Re_seg_lam=(props.Nu_lam/a/Pr_seg^c)^(1/b);


    Re_seg_abs_limited=sqrt(Re_seg^2+Re_seg_lam^2);


    corr_term=a*Re_seg_abs_limited^b*Pr_seg^c*k_seg;

end