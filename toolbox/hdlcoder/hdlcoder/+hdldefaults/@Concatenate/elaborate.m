function hNewC=elaborate(~,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    slbh=hC.SimulinkHandle;
    mode=get_param(slbh,'Mode');
    dim=get_param(slbh,'ConcatenateDimension');





    if strcmpi(mode,'Vector')
        dim='1';
    end

    hNewC=pirelab.getConcatenateComp(hN,hCInSignals,hCOutSignals,mode,dim);

end
