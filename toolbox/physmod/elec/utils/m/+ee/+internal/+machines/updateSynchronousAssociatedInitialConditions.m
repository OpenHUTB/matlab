function ic=updateSynchronousAssociatedInitialConditions(ic,b,f,rc,fd)%#codegen






    coder.allowpcode('plain');


    si_efd0=ic.pu_rc_efd0*rc.v;
    si_ifd0=ic.pu_rc_ifd0*rc.i;
    pu_fd_Efd0=si_efd0/fd.v;
    pu_fd_Ifd0=si_ifd0/fd.i;
    pu_torque0=ic.pu_Pt0+f.Ra*ic.pu_It0^2;
    si_torque0=pu_torque0*b.torque;
    si_Pm0=si_torque0*b.wMechanical;

    ic.si_efd0=si_efd0;
    ic.si_ifd0=si_ifd0;
    ic.si_torque0=si_torque0;
    ic.si_Pm0=si_Pm0;
    ic.pu_torque0=pu_torque0;
    ic.pu_fd_Efd0=pu_fd_Efd0;
    ic.pu_fd_Ifd0=pu_fd_Ifd0;

end