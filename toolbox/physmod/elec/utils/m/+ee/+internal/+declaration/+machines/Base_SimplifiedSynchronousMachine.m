function[base_vector,ic_vector]=Base_SimplifiedSynchronousMachine(SRated,VRated,FRated,connection_option,nPolePairs,Rpu,Lpu,initialization_option,Vmag0,Vang0,Pt0,Qt0)%#codegen







    base_vector=zeros(9,1);
    ic_vector=zeros(4,1);

    b=ee.internal.perunit.MachineBase(SRated,VRated,FRated,connection_option,nPolePairs);

    base_vector(1)=b.v;
    base_vector(2)=b.i;
    base_vector(3)=b.torque;
    base_vector(4)=b.wMechanical;
    base_vector(5)=b.wElectrical;
    base_vector(6)=b.R;
    base_vector(7)=b.L;
    base_vector(8)=b.C;
    base_vector(9)=b.psi;


    switch initialization_option
    case 1

    case 2
        ic=ee.internal.machines.createEmptySimplifiedSynchronousInitialConditions();
        ic.si_Vmag0=Vmag0;
        ic.si_Vang0=Vang0;
        ic.si_Pt0=Pt0;
        ic.si_Qt0=Qt0;
        ic=ee.internal.machines.updateSimplifiedSynchronousInitialConditions(ic,b,Rpu,Lpu);


        ic_vector(1)=ic.angular_position0;
        ic_vector(2)=ic.pu_psid0;
        ic_vector(3)=ic.pu_psiq0;
        ic_vector(4)=ic.pu_psi00;

    case 3

    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:declaration:machines:Base_SynchronousMachineFundamentalSimplified:error_SpecifyInitializationBy')),'1','3');
    end

end
