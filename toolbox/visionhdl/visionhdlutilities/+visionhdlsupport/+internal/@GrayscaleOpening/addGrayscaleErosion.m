function erNet=addGrayscaleErosion(~,topNet,blockInfo,sigInfo,inPortSignals,outPortSignals)




    inType=sigInfo.inType;




    erNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ErosionCore',...
    'InportSignals',inPortSignals,...
    'OutportSignals',outPortSignals);


    erosionInput=erNet.PirInputSignals;
    erosionOutput=erNet.PirOutputSignals;





    erodeNet=visionhdlsupport.internal.GrayscaleErosion;
    erodeNet.elaborateGrayscaleErosion(erNet,blockInfo,erosionInput,erosionOutput);



