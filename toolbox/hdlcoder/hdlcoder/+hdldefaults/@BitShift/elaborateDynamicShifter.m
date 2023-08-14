function hNewC=elaborateDynamicShifter(this,hN,hC)



    blkInfo=this.getBlockInfo(hC);
    compName=lower(hC.Name);

    hOutSignals=hC.PirOutputSignals;
    hInSignals=hC.PirInputSignals;

    switch lower(blkInfo.shiftDirection)
    case 'right'
        shift_mode='right';
    case 'left'
        shift_mode='left';
    case 'bidirectional'
        shift_mode='bidi';
    otherwise
        error(message('hdlcoder:validate:unsupportedBitshiftBinPt'));
    end

    [hNewC,hDs]=pirelab.getDynamicBitShiftComp(hN,hInSignals,hOutSignals,shift_mode,compName);


    if isempty(hDs)

        hNewC.setOriginalComponentTag(getfullname(hC.SimulinkHandle));
    else


        for ii=1:numel(hDs)
            hDs(ii).OrigModelHandle=hC.SimulinkHandle;
            hDs(ii).setOriginalComponentTag(getfullname(hC.SimulinkHandle));
        end
    end

end
