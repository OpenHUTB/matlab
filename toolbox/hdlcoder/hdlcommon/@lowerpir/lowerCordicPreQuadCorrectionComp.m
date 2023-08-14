function hNewC=lowerCordicPreQuadCorrectionComp(hN,hC)



    compName='cordic_prequadcorrection';%#ok<NASGU>
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    k_value=hC.getKConstant();
    hNewC=hdlarch.cordic.getCordicQuadCorrectionBeforeComp(hN,hInSignals,hOutSignals,...
    k_value);
end
