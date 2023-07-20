function hNewC=elaborate(this,hN,blockComp)


    slbh=blockComp.SimulinkHandle;
    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;


    fname=lower(get_param(slbh,'ModOrRem'));
    nfpOptions=getNFPBlockInfo(this);

    nfpModRemCheckResetToZeroStr=getImplParams(this,'CheckResetToZero');
    if isempty(nfpModRemCheckResetToZeroStr)||strcmp(nfpModRemCheckResetToZeroStr,'on')
        nfpOptions.ModRemCheckResetToZero=true;
    elseif strcmp(nfpModRemCheckResetToZeroStr,'off')
        nfpOptions.ModRemCheckResetToZero=false;
    end

    nfpOptions.ModRemMaxIterations=uint8(str2double(get_param(slbh,'MaxIterations')));

    hNewC=pirelab.getMathComp(hN,hInSignals,hOutSignals,blockComp.Name,...
    slbh,fname,nfpOptions);
end
