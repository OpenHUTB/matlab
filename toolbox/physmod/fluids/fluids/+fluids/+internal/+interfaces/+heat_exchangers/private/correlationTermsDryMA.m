







function[corr_term,hbar_seg,cpbar_seg,T_out,hbar_out,cpbar_out,mu_out,k_out,Pr_out]...
    =correlationTermsDryMA(Q_seg,hbar_in,cpbar_in,mu_in,k_in,Pr_in,props)

%#codegen
    coder.allowpcode('plain')

    a=props.a;
    b=props.b;
    c=props.c;


    hbar_out=hbar_in+Q_seg/props.mdot_ag;


    T_out=interp1(props.hbar_in_TLU,props.T_TLU,hbar_out,'linear','extrap');
    T_out_limited=min(max(T_out,props.T_TLU(1)),props.T_TLU(end));


    cpbar_out=[1,T_out_limited,T_out_limited^2]*props.cpbar_in_coeff;


    mu_out=interp1(props.T_TLU,props.mu_in_TLU,T_out_limited,'linear','extrap');
    k_out=interp1(props.T_TLU,props.k_in_TLU,T_out_limited,'linear','extrap');
    Pr_out=interp1(props.T_TLU,props.Pr_in_TLU,T_out_limited,'linear','extrap');


    hbar_seg=(hbar_in+hbar_out)/2;
    mu_seg=(mu_in+mu_out)/2;
    k_seg=(k_in+k_out)/2;
    Pr_seg=(Pr_in+Pr_out)/2;
    cpbar_seg=(cpbar_in+cpbar_out)/2;


    Re_seg=abs(props.mdot_in)/mu_seg*props.DS_ratio;


    Re_seg_lam=(props.Nu_lam/a/Pr_seg^c)^(1/b);


    Re_seg_abs_limited=sqrt(Re_seg^2+Re_seg_lam^2);


    corr_term=a*Re_seg_abs_limited^b*Pr_seg^c*k_seg;

end