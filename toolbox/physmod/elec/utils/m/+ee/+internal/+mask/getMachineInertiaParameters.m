function parameters=getMachineInertiaParameters(blockName)





    import ee.internal.mask.getValue;


    SRated=getValue(blockName,'SRated','V*A');
    FRated=getValue(blockName,'FRated','Hz');
    nPolePairs=getValue(blockName,'nPolePairs','1');


    b=ee.internal.perunit.MachineBase(SRated,nan,FRated,nan,nPolePairs);


    inertia_option=getValue(blockName,'inertia_option','1');
    switch inertia_option
    case 1
        J=getValue(blockName,'J','kg*m^2');
        H=J*b.wMechanical.^2/(2*SRated);
    case 2
        H=getValue(blockName,'H','(W*s)/(V*A)');
        J=2*H*SRated/b.wMechanical.^2;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:getMachineInertiaParameters:error_SpecifyInertiaParameterizationBy')),'1','2');
    end


    damper_option=getValue(blockName,'damper_option','1');
    switch damper_option
    case 1
        D=getValue(blockName,'D','N*m/(rad/s)');
        pu_D=D*b.wMechanical/b.torque;
    case 2
        pu_D=getValue(blockName,'pu_D','1');
        D=pu_D*b.torque/b.wMechanical;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:getMachineInertiaParameters:error_SpecifyDamperParameterizationBy')),'1','2');
    end


    initialization_option=getValue(blockName,'initialization_option','1');
    switch initialization_option
    case 1
        fMechanical0=getValue(blockName,'fMechanical0','Hz');
        fElectrical0=fMechanical0*nPolePairs;
    case 2
        fElectrical0=getValue(blockName,'fElectrical0','Hz');
        fMechanical0=fElectrical0/nPolePairs;
    otherwise
        pm_error('physmod:ee:library:IntegerOption',getString(message('physmod:ee:library:comments:utils:mask:getMachineInertiaParameters:error_SpecifyInitializationBy')),'1','2');
    end


    parameters.b=b;
    parameters.J=J;
    parameters.H=H;
    parameters.D=D;
    parameters.pu_D=pu_D;
    parameters.pu_velocity0=fElectrical0/b.FRated;
    parameters.fElectrical0=fElectrical0;
    parameters.fMechanical0=fMechanical0;
    parameters.wElectrical0=2*pi*fElectrical0;
    parameters.wMechanical0=2*pi*fMechanical0;
end