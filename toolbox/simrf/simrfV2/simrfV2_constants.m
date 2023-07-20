function simrfV2consts=simrfV2_constants(rtnPar)




    persistent SimRFV2_Const
    if isempty(SimRFV2_Const)
        product='rf_blockset';
        key='6FCA0E8BB9A58FAE206AFE39E51334FC4C8BBA34C1C3B44896C5F9EF0C18119C';


        SimRFV2_Const.Boltz=simscape.Value(rf.physconst('Boltzmann'),'J/K',product,key);
        SimRFV2_Const.GMIN=simscape.Value(1e-12,'1/Ohm',product,key);
        SimRFV2_Const.Rmin=simscape.Value(1e-12,'Ohm',product,key);
        SimRFV2_Const.Cmin=simscape.Value(1e-18,'F',product,key);
        SimRFV2_Const.Lmin=simscape.Value(1e-18,'H',product,key);
        SimRFV2_Const.ParTol=simscape.Value(1e-12,'1',product,key);

        SimRFV2_Const.Plot.Parameters={};
        SimRFV2_Const.Plot.PlotType='';
        SimRFV2_Const.Plot.PlotFormat={};
        SimRFV2_Const.Plot.XAxisName='';
        SimRFV2_Const.Plot.XFormat='';
        SimRFV2_Const.Plot.PlotHandle=[];
    end
    switch nargin
    case 1
        simrfV2consts=SimRFV2_Const.(rtnPar);
    otherwise
        simrfV2consts=SimRFV2_Const;
    end

end
