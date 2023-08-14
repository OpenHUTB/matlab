function hNewC=lowerCordicRotationComp(hN,hC)



    compName='cordic_rotation';%#ok<NASGU>
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    stageNum=hC.getIteration();
    lut_value=hC.getLookupTableConstant();
    hNewC=hdlarch.cordic.getCordicKernelComp(hN,hInSignals,hOutSignals,...
    lut_value,uint8(stageNum));
end
