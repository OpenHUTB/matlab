







function[corr_term,T_seg,h_out,T_out,wgt_liq_seg,wgt_vap_seg,wgt_mix_seg]...
    =correlationTerms2P(Q_seg,h_in,T_in,props)

%#codegen
    coder.allowpcode('plain')

    mdot=props.mdot;
    sqrt_v_sat_ratio=props.sqrt_v_sat_ratio;
    a_liq=props.a_liq;
    a_vap=props.a_vap;
    a_mix=props.a_mix;
    b=props.b;
    c=props.c;
    DS_ratio=props.DS_ratio;
    Nu_lam=props.Nu_lam;


    h_out=h_in+Q_seg/mdot;


    T_out=interp1(props.h_TLU,props.T_TLU,h_out,'linear','extrap');


    [h_liq_in,T_liq_in,h_vap_in,T_vap_in,T_mix_in,x_mix_in]...
    =zoneFluidProperties2P(h_in,T_in,props);

    [h_liq_out,T_liq_out,h_vap_out,T_vap_out,T_mix_out,x_mix_out]...
    =zoneFluidProperties2P(h_out,T_out,props);


    T_liq_seg=(T_liq_in+T_liq_out)/2;
    T_vap_seg=(T_vap_in+T_vap_out)/2;
    T_mix_seg=(T_mix_in+T_mix_out)/2;

    h_liq_seg=(h_liq_in+h_liq_out)/2;
    h_vap_seg=(h_vap_in+h_vap_out)/2;


    h_liq_seg_limited=min(max(h_liq_seg,props.h_TLU(1)),props.h_TLU(end));
    h_vap_seg_limited=min(max(h_vap_seg,props.h_TLU(1)),props.h_TLU(end));
    mu_liq_seg=interp1(props.h_TLU,props.mu_TLU,h_liq_seg_limited,'linear','extrap');
    mu_vap_seg=interp1(props.h_TLU,props.mu_TLU,h_vap_seg_limited,'linear','extrap');
    k_liq_seg=interp1(props.h_TLU,props.k_TLU,h_liq_seg_limited,'linear','extrap');
    k_vap_seg=interp1(props.h_TLU,props.k_TLU,h_vap_seg_limited,'linear','extrap');
    Pr_liq_seg=interp1(props.h_TLU,props.Pr_TLU,h_liq_seg_limited,'linear','extrap');
    Pr_vap_seg=interp1(props.h_TLU,props.Pr_TLU,h_vap_seg_limited,'linear','extrap');



    if isfinite(x_mix_in)
        x_min=min(x_mix_in,x_mix_out);
        delta_x=max(abs(x_mix_out-x_mix_in),1e-6);
        cavallini_term=(((sqrt_v_sat_ratio-1)*(x_min+delta_x)+1)^(1+b)-((sqrt_v_sat_ratio-1)*x_min+1)^(1+b))...
        /(1+b)/(sqrt_v_sat_ratio-1)/delta_x;
    else
        cavallini_term=0;
    end


    Re_liq_seg=abs(mdot)/mu_liq_seg*DS_ratio;
    Re_vap_seg=abs(mdot)/mu_vap_seg*DS_ratio;
    Re_mix_seg=abs(mdot)/props.mu_sat_liq*DS_ratio;


    Re_liq_seg_lam=(Nu_lam/a_liq/Pr_liq_seg^c)^(1/b);
    Re_vap_seg_lam=(Nu_lam/a_vap/Pr_vap_seg^c)^(1/b);
    Re_mix_seg_lam=(Nu_lam/a_mix/props.Pr_sat_liq^c/cavallini_term)^(1/b);


    Re_liq_seg_abs_limited=sqrt(Re_liq_seg^2+Re_liq_seg_lam^2);
    Re_vap_seg_abs_limited=sqrt(Re_vap_seg^2+Re_vap_seg_lam^2);
    Re_mix_seg_abs_limited=sqrt(Re_mix_seg^2+Re_mix_seg_lam^2);


    corr_term_liq=a_liq*Re_liq_seg_abs_limited^b*Pr_liq_seg^c*k_liq_seg;
    corr_term_vap=a_vap*Re_vap_seg_abs_limited^b*Pr_vap_seg^c*k_vap_seg;
    corr_term_mix=a_mix*Re_mix_seg_abs_limited^b*props.Pr_sat_liq^c*props.k_sat_liq*cavallini_term;


    [wgt_liq_seg,wgt_vap_seg,wgt_mix_seg]=zoneWeights2P(h_in,h_out,...
    corr_term_liq,corr_term_vap,corr_term_mix,props);


    corr_term=corr_term_liq*wgt_liq_seg+corr_term_vap*wgt_vap_seg+corr_term_mix*wgt_mix_seg;


    T_seg=(T_liq_seg*corr_term_liq*wgt_liq_seg+T_vap_seg*corr_term_vap*wgt_vap_seg...
    +T_mix_seg*corr_term_mix*wgt_mix_seg)/corr_term;

end





function[wgt_liq,wgt_vap,wgt_mix]=zoneWeights2P(h_in,h_out,...
    corr_term_liq,corr_term_vap,corr_term_mix,props)



    h_min=min(h_in,h_out)-props.delta_h_thres/2;
    h_max=max(h_in,h_out)+props.delta_h_thres/2;


    h_min_liq=min(h_min,props.h_sat_liq);
    h_max_liq=min(h_max,props.h_sat_liq);
    delta_h_liq_corr=(h_max_liq-h_min_liq)*corr_term_vap*corr_term_mix;


    h_min_vap=max(h_min,props.h_sat_vap);
    h_max_vap=max(h_max,props.h_sat_vap);
    delta_h_vap_corr=(h_max_vap-h_min_vap)*corr_term_liq*corr_term_mix;


    h_min_mix=min(max(h_min,props.h_sat_liq),props.h_sat_vap);
    h_max_mix=min(max(h_max,props.h_sat_liq),props.h_sat_vap);
    delta_h_mix_corr=(h_max_mix-h_min_mix)*corr_term_liq*corr_term_vap;



    wgt_liq=delta_h_liq_corr/(delta_h_liq_corr+delta_h_vap_corr+delta_h_mix_corr);
    wgt_vap=delta_h_vap_corr/(delta_h_liq_corr+delta_h_vap_corr+delta_h_mix_corr);
    wgt_mix=1-wgt_liq-wgt_vap;

end





function[h_liq,T_liq,h_vap,T_vap,T_mix,x_mix]=zoneFluidProperties2P(h,T,props)


    if h<=props.h_sat_liq
        h_liq=h;
        T_liq=T;
    else
        h_liq=props.h_sat_liq;
        T_liq=props.T_sat_liq;
    end


    if h>=props.h_sat_vap
        h_vap=h;
        T_vap=T;
    else
        h_vap=props.h_sat_vap;
        T_vap=props.T_sat_vap;
    end


    if h<props.h_sat_liq
        T_mix=props.T_sat_liq;
        x_mix=0;
    elseif h>props.h_sat_vap
        T_mix=props.T_sat_vap;
        x_mix=1;
    else
        T_mix=T;
        x_mix=(h-props.h_sat_liq)/(props.h_sat_vap-props.h_sat_liq);
    end

end