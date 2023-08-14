function validSig=findSignalWithValidRate(this,hN,hC,hSignals)





    hCoder=hdlcurrentdriver;

    if isempty(hCoder)
        error(message('hdlcoder:validate:NoDriver'));
    end

    if hC.SimulinkHandle>0&&isempty(hCoder.ModelConnection)
        error(message('hdlcoder:validate:BadConnectionState'));
    end



    for ii=1:length(hSignals)
        hS=hSignals(ii);
        rate=hS.SimulinkRate;
        if~isinf(rate)&&rate>0
            validSig=hS;
            return;
        else

        end
    end

    if hC.SimulinkHandle>0
        errName=getfullname(hC.SimulinkHandle);
    else
        errName=[hC.Owner.Name,'/',hC.Name];
    end

    error(message('hdlcoder:validate:CannotFindValidRate',errName));






