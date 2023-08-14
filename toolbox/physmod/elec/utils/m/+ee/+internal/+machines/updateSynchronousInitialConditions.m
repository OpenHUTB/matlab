function ic=updateSynchronousInitialConditions(ic,b,f)%#codegen






    coder.allowpcode('plain');


    ic.pu_Pt0=ic.si_Pt0/b.SRated;
    ic.pu_Qt0=ic.si_Qt0/b.SRated;
    ic.pu_Vmag0=ic.si_Vmag0/b.VRated;
    ic.pu_It0=sqrt(ic.pu_Pt0^2+ic.pu_Qt0^2)/ic.pu_Vmag0;

    if ic.pu_Pt0==0
        if ic.pu_Qt0==0
            ic.phi0=0;
        elseif ic.pu_Qt0>0
            ic.phi0=pi/2;
        else
            ic.phi0=-pi/2;
        end
    else
        ic.phi0=atan(ic.pu_Qt0/ic.pu_Pt0);
    end
    ic.phi0_deg=180*ic.phi0/pi;


    pu_psi_0_sqr=ic.pu_Vmag0^2+(f.Ra*ic.pu_It0)^2+2*ic.pu_Vmag0*f.Ra*ic.pu_It0*cos(ic.phi0);
    pu_psi_at0=sqrt(pu_psi_0_sqr+2*f.Ll*ic.pu_Vmag0*ic.pu_It0*sin(ic.phi0)+f.Ll^2*ic.pu_It0^2);


    noUseSaturationData=f.saturation_option~=1;


    if noUseSaturationData
        Xad=f.Lad;
        Xaq=f.Laq;
        Xd=f.Ld;
        Xq=f.Lq;
    else
        K_s=interp1(f.saturation.psi,f.saturation.K_s,pu_psi_at0,'linear','extrap');
        ic.saturation_K_s=K_s;
        Xad=K_s*f.Lad;
        Xd=Xad+f.Ll;
        if f.num_q_dampers==2

            Xaq=K_s*f.Laq;
        else
            Xaq=f.Laq;
        end
        Xq=Xaq+f.Ll;
    end

    delta0_numerator=Xq*ic.pu_It0*cos(ic.phi0)-f.Ra*ic.pu_It0*sin(ic.phi0);
    delta0_denominator=ic.pu_Vmag0+f.Ra*ic.pu_It0*cos(ic.phi0)+Xq*ic.pu_It0*sin(ic.phi0);
    ic.delta0=atan2(delta0_numerator,delta0_denominator);
    ic.delta0_deg=180*ic.delta0/pi;

    ic.pu_ed0=ic.pu_Vmag0*sin(ic.delta0);
    ic.pu_eq0=ic.pu_Vmag0*cos(ic.delta0);
    ic.pu_id0=ic.pu_It0*sin(ic.delta0+ic.phi0);
    ic.pu_iq0=ic.pu_It0*cos(ic.delta0+ic.phi0);
    ic.pu_rc_ifd0=(ic.pu_eq0+f.Ra*ic.pu_iq0+Xd*ic.pu_id0)/Xad;
    ic.pu_rc_efd0=f.Rfd*ic.pu_rc_ifd0;


    switch f.axes_param
    case ee.enum.rotorangle.daxis
        ic.angular_position0=(ic.delta0+ic.si_Vang0-pi)/b.nPolePairs;
    otherwise
        ic.angular_position0=(ic.delta0+ic.si_Vang0-pi/2)/b.nPolePairs;

    end
    ic.pu_psid0=ic.pu_eq0+f.Ra*ic.pu_iq0;
    ic.pu_psiq0=-ic.pu_ed0-f.Ra*ic.pu_id0;

    ic.pu_psi00=0;
    ic.pu_psifd0=(Xad+f.Lfd)*ic.pu_rc_ifd0-Xad*ic.pu_id0;
    ic.pu_psi1d0=Xad*(ic.pu_rc_ifd0-ic.pu_id0);
    ic.pu_psi1q0=-Xaq*ic.pu_iq0;

    if f.num_q_dampers==2
        ic.pu_psi2q0=-Xaq*ic.pu_iq0;
    end

end
