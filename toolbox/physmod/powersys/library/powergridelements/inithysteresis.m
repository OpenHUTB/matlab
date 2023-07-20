function[InitialFlux_pu,Tolerances,HT,UpperFlux,LowerFlux,Current]=inithysteresis(matfile,fluxbase,currentbase,InitialFlux)







    HT=[];
    eval(['load ',matfile]);

    InitialFlux_pu=InitialFlux;
    Tolerances=[HT.Fs*HT.Tolerances(1)/100,HT.Ic*HT.Tolerances(2)/100];
    UpperFlux=[-HT.Fj_sat(end:-1:2),HT.Y_d',HT.Fj_sat(2:end)];
    LowerFlux=[-HT.Fj_sat(end:-1:2),HT.Y_a',HT.Fj_sat(2:end)];
    Current=[-HT.Ij_sat(end:-1:2),HT.X_i',HT.Ij_sat(2:end)];

    if HT.UnitsPopup==1

        UpperFlux=UpperFlux*fluxbase;
        LowerFlux=LowerFlux*fluxbase;
        Current=Current*currentbase;


        if~exist('InitialFlux','var')
            InitialFlux=0;
        end
        InitialFlux_pu=InitialFlux/fluxbase;
    end