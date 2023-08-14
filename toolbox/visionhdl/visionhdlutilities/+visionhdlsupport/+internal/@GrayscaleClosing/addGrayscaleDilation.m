function dilNet=addGrayscaleDilation(~,topNet,blockInfo,sigInfo,inPortSignals,outPortSignals)




    inType=sigInfo.inType;




    dilNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','DilationCore',...
    'InportSignals',inPortSignals,...
    'OutportSignals',outPortSignals);


    dilationInput=dilNet.PirInputSignals;
    dilationOutput=dilNet.PirOutputSignals;



    dilateNet=visionhdlsupport.internal.GrayscaleDilation;
    dilateNet.elaborateGrayscaleDilation(dilNet,blockInfo,dilationInput,dilationOutput);



