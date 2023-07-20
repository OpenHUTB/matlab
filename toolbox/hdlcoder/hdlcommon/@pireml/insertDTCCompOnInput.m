function dtcOutSignal=insertDTCCompOnInput(hN,hCInSignal,hCOutType,...
    rndMode,satMode,receivingCompName)






    if nargin<6
        receivingCompName='';
    else
        receivingCompName=[hN.getNameForReporting,'/',receivingCompName];
    end


    pireml.checkSignalTypeValidity(hCOutType,receivingCompName);



    [~,hBaseType]=pirelab.getVectorTypeInfo(hCInSignal,true);




    hT=hCInSignal.Type;


    if hT.isComplexType&&hT.isEqual(hCOutType)||...
        hBaseType.isEqual(hCOutType)||...
        hBaseType.is1BitType&&hCOutType.is1BitType
        dtcOutSignal=hCInSignal;
    else

        dtcOutSignal=hN.addSignal(hCOutType,[hCInSignal.Name,'_dtc']);
        pireml.getDTCComp(hN,hCInSignal,dtcOutSignal,rndMode,satMode);
    end
end


