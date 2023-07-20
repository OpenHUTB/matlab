function aircraft=map06ToAircraft(aircraft,datcomStruct,build)





    datcomStruct.build=build;


    if(datcomStruct.highasy)
        deltaname="deltal";
    else
        deltaname="delta";
    end


    staticCoeffStatesMap=[
    "alpha","Alpha";
    "mach","MachNumber";
    "alt","AltitudeMSL";
    "build","Build";
    "grndht","GroundHeight";
    deltaname,"Delta";
    ];
    staticCoeffLTMap=[
    ["cd","CD","Zero"];
    ["cl","CL","Zero"];
    ["cm","Cm","Zero"];
    ["cla","CL","Alpha"];
    ["cma","Cm","Alpha"];
    ["cyb","CY","Beta"];
    ["cnb","Cn","Beta"];
    ["clb","Cl","Beta"];
    ];

    aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,staticCoeffLTMap,staticCoeffStatesMap,aircraft.Properties.Name);


    dynamicCoeffLTMap=[
    ["clq","CL","Q"];
    ["cmq","Cm","Q"];
    ["clad","CL","AlphaDot"];
    ["cmad","Cm","AlphaDot"];
    ["clp","Cl","P"];
    ["cyp","CY","P"];
    ["cnp","Cn","P"];
    ["cnr","Cn","R"];
    ["clr","Cl","R"];
    ];
    dynamicCoeffStatesMap=[
    "alpha","Alpha";
    "mach","MachNumber";
    "alt","AltitudeMSL";
    "build","Build";
    ];

    aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,dynamicCoeffLTMap,dynamicCoeffStatesMap,aircraft.Properties.Name);





    if datcomStruct.highsym||datcomStruct.highasy

        aircraft.Surfaces(end+1)=Aero.FixedWing.Surface();
        aircraft.Surfaces(end).Coefficients.ReferenceFrame="Stability";
    end

    if(datcomStruct.highsym)
        aircraft.Surfaces(end).Properties.Name="Delta";
        aircraft.Surfaces(end).Controllable=true;

        controlCoeffMap=[
        ["dcl_sym","CL","Zero"];
        ["dcm_sym","Cm","Zero"];
        ];

        controlStatesMap=[
        ["delta","Delta"];
        ["mach","MachNumber"];
        ["alt","AltitudeMSL"];
        ];

        aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,controlCoeffMap,controlStatesMap,aircraft.Surfaces(end).Properties.Name);


        controlCoeffMap=["dcdi_sym","CD","Zero"];
        controlStatesMap=[
        ["alpha","Alpha"];
        ["delta","Delta"];
        ["mach","MachNumber"];
        ["alt","AltitudeMSL"];
        ];
        aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,controlCoeffMap,controlStatesMap,aircraft.Surfaces(end).Properties.Name);

    elseif(datcomStruct.highasy)

        aircraft.Surfaces(end).Properties.Name="Delta";
        aircraft.Surfaces(end).Controllable=true;
        aircraft.Surfaces(end).Symmetry="Asymmetric";

        clrollControlCoeffMap=["clroll","Cl","Zero"];

        cnControlCoeffMap=["cn_asy","Cn","Zero"];

        dmaControlStatesMap=[
        ["deltal","Delta"];
        ["mach","MachNumber"];
        ["alt","AltitudeMSL"];
        ];
        admaControlStatesMap=[
        ["alpha","Alpha"];
        ["deltal","Delta"];
        ["mach","MachNumber"];
        ["alt","AltitudeMSL"];
        ];

        if datcomStruct.stype==5
            aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,clrollControlCoeffMap,admaControlStatesMap,aircraft.Surfaces(end).Properties.Name);
        else
            aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,clrollControlCoeffMap,dmaControlStatesMap,aircraft.Surfaces(end).Properties.Name);
        end

        if datcomStruct.stype==4
            aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,cnControlCoeffMap,admaControlStatesMap,aircraft.Surfaces(end).Properties.Name);
        else
            aircraft=setMappedCoefficientLTData(aircraft,datcomStruct,cnControlCoeffMap,dmaControlStatesMap,aircraft.Surfaces(end).Properties.Name);
        end
    end


    aircraft=aircraft.update();

end