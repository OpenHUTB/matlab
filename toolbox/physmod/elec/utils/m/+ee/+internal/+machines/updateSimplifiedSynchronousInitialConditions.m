function ic=updateSimplifiedSynchronousInitialConditions(ic,b,Rpu,Lpu)%#codegen






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
    delta0_numerator=Lpu*ic.pu_It0*cos(ic.phi0)-Rpu*ic.pu_It0*sin(ic.phi0);
    delta0_denominator=ic.pu_Vmag0+Rpu*ic.pu_It0*cos(ic.phi0)+Lpu*ic.pu_It0*sin(ic.phi0);
    ic.delta0=atan2(delta0_numerator,delta0_denominator);
    ic.delta0_deg=180*ic.delta0/pi;

    ic.pu_vd0=ic.pu_Vmag0*sin(ic.delta0);
    ic.pu_vq0=ic.pu_Vmag0*cos(ic.delta0);
    ic.pu_id0=ic.pu_It0*sin(ic.delta0+ic.phi0);
    ic.pu_iq0=ic.pu_It0*cos(ic.delta0+ic.phi0);
    ic.pu_ed0=Rpu*ic.pu_id0-Lpu*ic.pu_iq0+ic.pu_vd0;
    ic.pu_eq0=Rpu*ic.pu_iq0+Lpu*ic.pu_id0+ic.pu_vq0;
    ic.pu_Emag0=sqrt(ic.pu_ed0^2+ic.pu_eq0^2);
    ic.si_Emag0=ic.pu_Emag0*b.v;


    ic.angular_position0=(ic.delta0+ic.si_Vang0)/b.nPolePairs;
    ic.pu_psid0=Lpu*ic.pu_id0;
    ic.pu_psiq0=Lpu*ic.pu_iq0;
    ic.pu_psi00=0;

    shift_3ph=2*pi*[0,-1/3,1/3];
    electrical_angle_vec0=ic.angular_position0*b.nPolePairs+shift_3ph-pi/2;
    dq2a=[sin(electrical_angle_vec0(1)),cos(electrical_angle_vec0(1))];
    dq2b=[sin(electrical_angle_vec0(2)),cos(electrical_angle_vec0(2))];
    dq2c=[sin(electrical_angle_vec0(3)),cos(electrical_angle_vec0(3))];
    ic.si_ia0=-b.i*dq2a*[ic.pu_id0;ic.pu_iq0];
    ic.si_ib0=-b.i*dq2b*[ic.pu_id0;ic.pu_iq0];
    ic.si_ic0=-b.i*dq2c*[ic.pu_id0;ic.pu_iq0];

    ic.pu_torque0=ic.pu_ed0*ic.pu_id0+ic.pu_eq0*ic.pu_iq0;
    ic.si_torque0=ic.pu_torque0*b.torque;
    ic.pu_Pm0=ic.pu_torque0;
    ic.si_Pm0=ic.pu_Pm0*b.SRated;


