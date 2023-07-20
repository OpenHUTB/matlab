function ic=updateSixPhaseSMInitialConditions(ic,SRated,VRated,nPolePairs,Lq,Rs,Ld,Lmd,Rfdp,Lfd,Lmq,axes_param)





    ic.pu_Ptabc0=ic.si_Ptabc0/SRated;
    ic.pu_Qtabc0=ic.si_Qtabc0/SRated;
    ic.pu_Vmag0=ic.si_Vmag0/VRated;
    ic.pu_Itabc0=sqrt(ic.pu_Ptabc0^2+ic.pu_Qtabc0^2)/ic.pu_Vmag0;

    if ic.pu_Ptabc0==0
        if ic.pu_Qtabc0==0
            ic.phiabc0=0;
        elseif ic.pu_Qtabc0>0
            ic.phiabc0=pi/2;
        else
            ic.phiabc0=-pi/2;
        end
    else
        ic.phiabc0=atan(ic.pu_Qtabc0/ic.pu_Ptabc0);
    end
    ic.phiabc0_deg=180*ic.phiabc0/pi;


    ic.pu_Ptxyz0=ic.si_Ptxyz0/SRated;
    ic.pu_Qtxyz0=ic.si_Qtxyz0/SRated;
    ic.pu_Vmag0=ic.si_Vmag0/VRated;
    ic.pu_Itxyz0=sqrt(ic.pu_Ptxyz0^2+ic.pu_Qtxyz0^2)/ic.pu_Vmag0;

    if ic.pu_Ptxyz0==0
        if ic.pu_Qtxyz0==0
            ic.phixyz0=0;
        elseif ic.pu_Qtxyz0>0
            ic.phixyz0=pi/2;
        else
            ic.phixyz0=-pi/2;
        end
    else
        ic.phixyz0=atan(ic.pu_Qtxyz0/ic.pu_Ptxyz0);
    end
    ic.phixyz0_deg=180*ic.phixyz0/pi;

    deltaabc0_numerator=Lq*ic.pu_Itabc0*cos(ic.phiabc0)-Rs*ic.pu_Itabc0*sin(ic.phiabc0)+Lmq*ic.pu_Itxyz0*cos(ic.phixyz0);
    deltaabc0_denominator=ic.pu_Vmag0+Rs*ic.pu_Itabc0*cos(ic.phiabc0)+Lq*ic.pu_Itabc0*sin(ic.phiabc0)+Lmq*ic.pu_Itxyz0*sin(ic.phixyz0);
    ic.deltaabc0=atan2(deltaabc0_numerator,deltaabc0_denominator);
    ic.deltaabc0_deg=180*ic.deltaabc0/pi;

    deltaxyz0_numerator=Lq*ic.pu_Itxyz0*cos(ic.phixyz0)-Rs*ic.pu_Itxyz0*sin(ic.phixyz0)+Lmq*ic.pu_Itabc0*cos(ic.phiabc0);
    deltaxyz0_denominator=ic.pu_Vmag0+Rs*ic.pu_Itxyz0*cos(ic.phixyz0)+Lq*ic.pu_Itxyz0*sin(ic.phixyz0)+Lmq*ic.pu_Itabc0*sin(ic.phiabc0);
    ic.deltaxyz0=atan2(deltaxyz0_numerator,deltaxyz0_denominator);
    ic.deltaxyz0_deg=180*ic.deltaxyz0/pi;


    ic.pu_vq10=ic.pu_Vmag0*cos(ic.deltaabc0);
    ic.pu_vd10=ic.pu_Vmag0*sin(ic.deltaabc0);
    ic.pu_vq20=ic.pu_Vmag0*cos(ic.deltaxyz0);
    ic.pu_vd20=ic.pu_Vmag0*sin(ic.deltaxyz0);


    ic.pu_iq10=-ic.pu_Itabc0*cos(ic.deltaabc0+ic.phiabc0);
    ic.pu_id10=-ic.pu_Itabc0*sin(ic.deltaabc0+ic.phiabc0);
    ic.pu_iq20=-ic.pu_Itxyz0*cos(ic.deltaxyz0+ic.phixyz0);
    ic.pu_id20=-ic.pu_Itxyz0*sin(ic.deltaxyz0+ic.phixyz0);

    ic.pu_ifdp0=(ic.pu_vq10-Rs*ic.pu_iq10-Ld*ic.pu_id10-Lmd*ic.pu_id20)/Lmd;
    ic.pu_vfdp0=ic.pu_ifdp0*Rfdp;


    switch axes_param
    case ee.enum.rotorangle.daxis
        ic.angular_position0=(ic.deltaabc0+ic.si_Vang0-pi)/nPolePairs;
    case ee.enum.rotorangle.qaxis
        ic.angular_position0=(ic.deltaabc0+ic.si_Vang0-pi/2)/nPolePairs;
    otherwise
    end
    ic.pu_psiq10=Rs*ic.pu_id10-ic.pu_vd10;
    ic.pu_psid10=ic.pu_vq10-Rs*ic.pu_iq10;
    ic.pu_psiq20=Rs*ic.pu_id20-ic.pu_vd20;
    ic.pu_psid20=ic.pu_vq20-Rs*ic.pu_iq20;
    ic.pu_psifd0=Lmd*(ic.pu_id10+ic.pu_id20)+Lfd*ic.pu_ifdp0;
    ic.pu_psikd0=Lmd*(ic.pu_id10+ic.pu_id20+ic.pu_ifdp0);
    ic.pu_psikq0=Lmq*(ic.pu_iq10+ic.pu_iq20);


    ic.pu_torque0=ic.pu_Ptabc0+ic.pu_Ptxyz0+Rs*(ic.pu_Itabc0^2+ic.pu_Itxyz0^2);

