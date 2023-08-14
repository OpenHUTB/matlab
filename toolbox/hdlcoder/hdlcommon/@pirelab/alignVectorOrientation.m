function orientedSignal=alignVectorOrientation(hN,hInSignal,vecOrientation)




    narginchk(3,3);







    inSigType=hInSignal.Type;
    sigType=hN.getType('Array','BaseType',inSigType.BaseType,...
    'Dimensions',inSigType.Dimensions,'VectorOrientation',vecOrientation);
    orientedSignal=hN.addSignal(sigType,[hInSignal(1).Name,'_reshape']);
    orientedSignal.SimulinkRate=hInSignal(1).SimulinkRate;
    pirelab.getReshapeComp(hN,hInSignal,orientedSignal);
end
