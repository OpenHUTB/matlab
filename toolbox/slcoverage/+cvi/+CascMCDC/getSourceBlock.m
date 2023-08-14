function srcH=getSourceBlock(blockH,inPortIdx)










    try
        portHandles=get_param(blockH,'PortHandles');
        inportH=portHandles.Inport(inPortIdx);
        eiInitVal=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
        eiCleanup=onCleanup(@()slfeature('EngineInterface',eiInitVal));
        inportObj=get(inportH,'Object');
        actSrcPortHTemp=inportObj.getActualSrc;
        actSrcPortH=actSrcPortHTemp(1);
        srcH=get(actSrcPortH(1),'ParentHandle');
    catch
        srcH=-1;
    end
