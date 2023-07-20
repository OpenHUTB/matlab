function[T_mtpa,id_mtpa,iq_mtpa,id_max_mtpa,iq_max_mtpa,i_max]=autoblks_optimize_idiq(Rs,flux,Ld,Lq,p,T_max)






    if Ld>Lq
        msg.message='Ld cannot be greater than Lq.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end

    if flux<=0
        msg.message='Flux cannot be zero or less.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end

    if T_max<=0
        msg.message='Torque cannot be zero or less.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end

    if Rs<=0
        msg.message='Stator resistance cannot be zero or less.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end

    if p<=0
        msg.message='PM pole pairs cannot be zero or less.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end

    if rem(p,1)~=0
        msg.message='PM pole pairs must be an integer.';
        msg.identifier='AUTOLIB:autoblks_optimize_idiq1';
        error(msg);
    end


    Kt=3*p/2*flux;
    is=T_max/Kt;


    is=linspace(0,is,1000);
    id_mtpa=(-flux+sqrt(flux^2+8*(Ld-Lq)^2.*is.*is))/4/(Ld-Lq);
    iq_mtpa=sqrt(is.*is-id_mtpa.*id_mtpa);
    T_mtpa=1.5*p*(flux+(Ld-Lq).*id_mtpa).*iq_mtpa;
    id_max_mtpa=interp1(T_mtpa,id_mtpa,60,'spline');
    iq_max_mtpa=interp1(T_mtpa,iq_mtpa,60,'spline');
    i_max=sqrt(id_max_mtpa^2+iq_max_mtpa^2);

end
