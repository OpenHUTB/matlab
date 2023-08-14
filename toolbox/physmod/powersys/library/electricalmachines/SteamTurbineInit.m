function[Ts,WantBlockChoice,q0,FA,Ha,Ka,Da,dtha,t,errorFlag,ctrl1,sel,massNumber]=SteamTurbineInit(block,gentype,reg1,reg2,reg3,turb1,turb2,HA,KA,DA,ini1,ini2);





    power_initmask();

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if gentype==1
        HA=[];
        DA=[];
        KA=[];
        ini2=[];
    end

    [q0,FA,Ha,Ka,Da,dtha,t,errorFlag,ctrl1,sel,massNumber]=psbstginit(gentype,reg1,reg2,reg3,turb1,turb2,HA,KA,DA,ini1,ini2);

    Erreur.identifier='SpecializedPowerSystems:SteamTrubineBlock:InvalidParameters';

    switch errorFlag
    case 1
        Erreur.message='Torque fractions total (gen.A)  is not 1 p.u.';
        psberror(Erreur);
    case 3
        Erreur.message='You requested the multi-mass shaft but set all mass inertia constants to zero. Please use the single-mass option.';
        psberror(Erreur);
    case 4
        Erreur.message=['Inconsistent mass inertias and power fractions. Mass #',...
        num2str(massNumber),' has inertia set to zero but the ',...
        'corresponding torque fraction is not zero.'];
        psberror(Erreur);
    case 5
        Erreur.message='Parameters error';
        psberror(Erreur);
    end


    if PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor
        WantBlockChoice='Discrete';
    else
        WantBlockChoice='Continuous';
    end