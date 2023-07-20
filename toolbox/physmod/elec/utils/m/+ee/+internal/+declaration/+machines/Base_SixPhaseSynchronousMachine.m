function ic_vector=Base_SixPhaseSynchronousMachine(initialization_option,SRated,VRated,nPolePairs,Lq,Rs,Ld,Lmd,Rfdp,Lfd,Lmq,Vmag0,Vang0,Ptabc0,Qtabc0,Ptxyz0,Qtxyz0,axes_param)%#codegen







    ic_vector=zeros(10,1);


    switch initialization_option
    case 1

    case 2
        ic=ee.internal.machines.createEmptySixPhaseSMInitialConditions();
        ic.si_Vmag0=Vmag0;
        ic.si_Vang0=Vang0;
        ic.si_Ptabc0=Ptabc0;
        ic.si_Qtabc0=Qtabc0;
        ic.si_Ptxyz0=Ptxyz0;
        ic.si_Qtxyz0=Qtxyz0;

        ic=ee.internal.machines.updateSixPhaseSMInitialConditions(ic,SRated,VRated,nPolePairs,Lq,Rs,Ld,Lmd,Rfdp,Lfd,Lmq,axes_param);


        ic_vector(1)=ic.angular_position0;
        ic_vector(2)=ic.pu_psiq10;
        ic_vector(3)=ic.pu_psid10;
        ic_vector(4)=ic.pu_psiq20;
        ic_vector(5)=ic.pu_psid20;
        ic_vector(6)=0;
        ic_vector(7)=0;

        ic_vector(8)=ic.pu_psifd0;
        ic_vector(9)=ic.pu_psikd0;
        ic_vector(10)=ic.pu_psikq0;

    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:declaration:machines:Base_SynchronousMachineFundamental:error_SpecifyInitializationBy')),'1','2');
    end

end
