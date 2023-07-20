function[Zsurf]=Zsurf_calc(omega,metalthickness,conductivity)

    mu=1.257e-006;
    Z_eta=377;
    delta_=sqrt(2/(omega*conductivity*mu));






    k1_=(1+1j)/delta_;
    k2_=k1_/conductivity;
    k3_=exp(k1_*metalthickness)+(conductivity*Z_eta-k1_)*(exp(-k1_*metalthickness))/(conductivity*Z_eta+k1_);
    k4_=exp(k1_*metalthickness)-(conductivity*Z_eta-k1_)*(exp(-k1_*metalthickness))/(conductivity*Z_eta+k1_);
    Zsurf1=k2_*k3_/k4_;
    k5_=sqrt(omega*mu*0.5/conductivity);

    if isnan(Zsurf1)
        Zsurf=k5_+k5_*1j;
    else
        Zsurf=Zsurf1;
    end




































end

