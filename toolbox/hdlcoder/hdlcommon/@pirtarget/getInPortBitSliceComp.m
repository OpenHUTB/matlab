function getInPortBitSliceComp(hN,hInSignal,hOutSignal,sliceMSB,sliceLSB)








    bitWidth=sliceMSB-sliceLSB+1;
    tmpSigType=pir_ufixpt_t(bitWidth,0);
    sliceOutSignal=hN.addSignal(tmpSigType,sprintf('%s_slice',hInSignal.Name));


    pirelab.getBitSliceComp(hN,hInSignal,sliceOutSignal,sliceMSB,sliceLSB);


    pirelab.getDTCComp(hN,sliceOutSignal,hOutSignal,'Floor','Wrap','SI');

end