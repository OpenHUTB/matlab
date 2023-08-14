function[Kp_d,Kp_q,Ki]=autoblks_determine_curreg_params(EV_current,Ld,Lq,Rs)






    Kp_d=2*pi*EV_current*Ld;
    Kp_q=2*pi*EV_current*Lq;
    Ki=2*pi*EV_current*Rs;

end

