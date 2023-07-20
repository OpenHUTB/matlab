function[ba,Ksa,Kisa,Ksf]=autoblks_determine_spdreg_params(Ts,Tst,Jp,EV_motion,EV_sf)











    s=2*pi*EV_motion;
    zz=exp(-s*Ts);
    p1=zz(1);p2=zz(2);p3=zz(3);
    ba=(Jp-Jp*p1*p2*p3)/Ts;
    Ksa=(Jp*(p1*p2+p2*p3+p3*p1)-3*Jp+2*ba*Ts)/(-Ts^2);
    Kisa=(Jp*(-p1-p2-p3)+3*Jp-ba*Ts-Ksa*Ts^2)/Ts^3;


    Ksf=(1-exp(-Tst*2*pi*EV_sf))/(Tst);

end

