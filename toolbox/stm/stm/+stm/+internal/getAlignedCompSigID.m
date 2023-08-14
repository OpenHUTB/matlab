function cmpSigInRun2ID=getAlignedCompSigID(srcSigId,srcRunID,dstRunID)




    engine=Simulink.sdi.Instance.engine;


    algorithms=[Simulink.sdi.AlignType.BlockPath,Simulink.sdi.AlignType.SID...
    ,Simulink.sdi.AlignType.SignalName];
    EXPAND_MATRICES=true;
    Simulink.sdi.doAlignment(engine.sigRepository,srcRunID,dstRunID,int32(algorithms),EXPAND_MATRICES);


    cmpSigInDbgRunID=Simulink.sdi.getAlignedID(srcSigId);


    cmpSigInRun2ID=int32(cmpSigInDbgRunID);

end
