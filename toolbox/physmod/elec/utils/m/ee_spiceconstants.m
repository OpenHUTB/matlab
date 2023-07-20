function spiceconsts=ee_spiceconstants()




    persistent SpiConst
    if isempty(SpiConst)
        SpiConst.EGmin=simscape.Value(.1,'eV');
        SpiConst.MGmax=simscape.Value(.9,'1');
        SpiConst.FCmax=simscape.Value(.95,'1');
        SpiConst.VJmin=simscape.Value(.01,'V');
        SpiConst.Rmin=simscape.Value(1e-12,'Ohm*m^2');
        SpiConst.Cmin=simscape.Value(1e-18,'F/m^2');
        SpiConst.Lmin=simscape.Value(1e-18,'H/m^2');
        SpiConst.Boltz=simscape.Value(1.3806226e-23,'J/K');
        SpiConst.Charge=simscape.Value(1.6021918e-19,'c');

        SpiConst.KoverQ=SpiConst.Boltz/SpiConst.Charge;
        SpiConst.SiDope300=simscape.Value(1.45e10,'1/cm^3');
        SpiConst.RiseFallTime=simscape.Value(1e-9,'s');




        SpiConst.REFTEMP=simscape.Value(300.15,'K');
        SpiConst.EG_Si300=simscape.Value(1.11,'V');
        SpiConst.EG_SBD300=simscape.Value(0.69,'V');
        SpiConst.EG_GE300=simscape.Value(0.67,'V');
        SpiConst.EG_ZeroK=simscape.Value(1.16,'V');
        SpiConst.EG_Alpha=simscape.Value(7.02e-4,'V/K');
        SpiConst.EG_Beta=simscape.Value(1108.,'K');

        SpiConst.EG_300=SpiConst.EG_ZeroK-...
        (SpiConst.EG_Alpha*SpiConst.REFTEMP^2)/...
        (SpiConst.REFTEMP+SpiConst.EG_Beta);
        SpiConst.CJO_Cnst=simscape.Value(4.e-4,'1/K');


        SpiConst.EPSO=simscape.Value(8.854214871e-12,'F/m');


        SpiConst.EPSOX=3.9*SpiConst.EPSO;
        SpiConst.EPSOXbsim3=simscape.Value(3.453133e-11,'F/m');


        SpiConst.EPSSIL=11.7*SpiConst.EPSO;
        SpiConst.EPSSIbsim3=simscape.Value(1.03594e-10,'F/m');

        SpiConst.EXP80=simscape.Value(exp(80),'1');
        SpiConst.EXP1=simscape.Value(exp(1),'1');
        SpiConst.MAX_EXP=simscape.Value(5.834617425e14,'1');
        SpiConst.MIN_EXP=simscape.Value(1.713908431e-15,'1');
        SpiConst.EXP_THRESHOLD=simscape.Value(34.0,'1');

    end
    spiceconsts=SpiConst;

end


