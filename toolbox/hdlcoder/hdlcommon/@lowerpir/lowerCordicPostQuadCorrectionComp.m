function hNewC=lowerCordicPostQuadCorrectionComp(hN,hC)



    compName='cordic_postquadcorrection';%#ok<NASGU>
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    hNewC=hdlarch.cordic.getCordicQuadCorrectionAfterComp(hN,hInSignals,hOutSignals);
end
