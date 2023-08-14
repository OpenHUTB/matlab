






function[corr_term,hbar_seg,cpbar_seg,T_in,T_out,hbar_out]=correlationTermsWetMA(...
    Q_seg,hbar_in,HR_in,props)

%#codegen
    coder.allowpcode('plain')

    a=props.a;
    b=props.b;
    c=props.c;


    y_w_in=HR_in*props.R_w/(props.R_ag+HR_in*props.R_w);
    y_g_in=props.GR*props.R_g/(props.R_ag+HR_in*props.R_w);
    y_in=[1-y_w_in-y_g_in;y_w_in;y_g_in];


    hbar_out=hbar_in+Q_seg/props.mdot_ag;



    hbar_TLU=props.h_ag_TLU+HR_in*props.h_w_TLU;


    T=interp1(hbar_TLU,props.T_TLU,[hbar_in;hbar_out],'linear','extrap');
    T_limited=min(max(T,props.T_TLU(1)),props.T_TLU(end));
    T_in=T(1);
    T_out=T(2);


    cpbar=[ones(2,1),T_limited,T_limited.^2]*(props.cp_ag_coeff+HR_in*props.cp_w_coeff);


    mu=interp1(props.T_TLU,props.mu_TLU,T_limited,'linear','extrap')*y_in;
    k=interp1(props.T_TLU,props.k_TLU,T_limited,'linear','extrap')*y_in;
    Pr=interp1(props.T_TLU,props.Pr_TLU,T_limited,'linear','extrap')*y_in;


    hbar_seg=(hbar_in+hbar_out)/2;
    mu_seg=(mu(1)+mu(2))/2;
    k_seg=(k(1)+k(2))/2;
    Pr_seg=(Pr(1)+Pr(2))/2;
    cpbar_seg=(cpbar(1)+cpbar(2))/2;


    mdot_in=(1+HR_in)*props.mdot_ag;


    Re_seg=abs(mdot_in)/mu_seg*props.DS_ratio;


    Re_seg_lam=(props.Nu_lam/a/Pr_seg^c)^(1/b);


    Re_seg_abs_limited=sqrt(Re_seg^2+Re_seg_lam^2);


    corr_term=a*Re_seg_abs_limited^b*Pr_seg^c*k_seg;

end