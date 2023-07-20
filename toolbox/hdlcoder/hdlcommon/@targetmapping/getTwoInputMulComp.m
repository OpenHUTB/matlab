function mulComp=getTwoInputMulComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,inputSigns,desc,slbh,nfpOptions)




    newInputSignals=targetmapping.makeInputsUniformInDimension(hN,hInSignals,compName);

    mulKind='Element-wise(.*)';
    mulComp=pircore.getMulComp(hN,newInputSignals,hOutSignals,...
    rndMode,satMode,compName,inputSigns,desc,slbh,nfpOptions,mulKind);
end

