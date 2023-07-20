function cNet=elaborateDecompositionDilation(this,topNet,blockInfo,sigInfo,inRate)










    inputWL=sigInfo.inputWL;
    inputFL=sigInfo.inputFL;
    inType=sigInfo.inType;
    boolType=pir_boolean_t();
    pixelVType=sigInfo.lbufVType;
    Neighborhood=blockInfo.Neighborhood;



    inPortNames={'DataIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn','processDataIn'};
    inPortTypes=[inType,boolType,boolType,boolType,boolType,boolType,boolType];
    inPortRates=[inRate,inRate,inRate,inRate,inRate,inRate,inRate];
    outPortNames={'dataOut','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};
    outPortTypes=[inType,boolType,boolType,boolType,boolType,boolType];


    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','VanHerkDilation',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes);

    cNet.addComment('Find local maxima in grayscale image');



    inSignals=cNet.PirInputSignals;
    dataIn=inSignals(1);
    hStartIn=inSignals(2);
    hEndIn=inSignals(3);
    vStartIn=inSignals(4);
    vEndIn=inSignals(5);
    validIn=inSignals(6);
    processDataIn=inSignals(7);

    outSignals=cNet.PirOutputSignals;
    dataOut=outSignals(1);
    hStartOut=outSignals(2);
    hEndOut=outSignals(3);
    vStartOut=outSignals(4);
    vEndOut=outSignals(5);
    validOut=outSignals(6);

    booleanT=pir_boolean_t();


    vanHerkNet=this.elaborateVanHerkDilation(cNet,blockInfo,sigInfo,inRate);

    vanHerkDataOut=cNet.addSignal2('Type',inType,'Name','VanHerkDataOut');
    hStartVH=cNet.addSignal2('Type',booleanT,'Name','HStartVH');
    hEndVH=cNet.addSignal2('Type',booleanT,'Name','HEndVH');
    vStartVH=cNet.addSignal2('Type',booleanT,'Name','VStartVH');
    vEndVH=cNet.addSignal2('Type',booleanT,'Name','VEndVH');
    validVH=cNet.addSignal2('Type',booleanT,'Name','ValidVH');


    vanHerkIn=[dataIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn,processDataIn];
    vanHerkOut=[vanHerkDataOut,hStartVH,hEndVH,vStartVH,vEndVH,validVH];

    VHCore=pirelab.instantiateNetwork(cNet,vanHerkNet,vanHerkIn,vanHerkOut,'VanHerkDilation');
    VHCore.addComment('VanHerkCore');

    lineBufferBlockInfo.KernelHeight=blockInfo.kHeight;
    lineBufferBlockInfo.KernelWidth=1;
    lineBufferBlockInfo.PaddingMethod='Constant';
    lineBufferBlockInfo.PaddingValue=0;
    lineBufferBlockInfo.MaxLineSize=blockInfo.LineBufferSize;
    lineBufferBlockInfo.Algorithm=blockInfo.Algorithm;
    lineBufferBlockInfo.BiasUp=false;
    lineBufNet=this.addLineBuffer(topNet,lineBufferBlockInfo,inRate,inType);

    dataOutLB=cNet.addSignal2('Type',pixelVType,'Name','DataOutLB');
    dataOutCol=cNet.addSignal2('Type',inType,'Name','DataOutCol');
    hStartLB=cNet.addSignal2('Type',booleanT,'Name','HStartLB');
    hEndLB=cNet.addSignal2('Type',booleanT,'Name','HEndLB');
    vStartLB=cNet.addSignal2('Type',booleanT,'Name','VStartLB');
    vEndLB=cNet.addSignal2('Type',booleanT,'Name','VEndLB');
    validLB=cNet.addSignal2('Type',booleanT,'Name','ValidLB');
    processDataLB=cNet.addSignal2('Type',booleanT,'Name','ProcessDataLB');

    LineBufferIn=[vanHerkDataOut,hStartVH,hEndVH,vStartVH,vEndVH,validVH];
    LineBufferOut=[dataOutLB,hStartLB,hEndLB,vStartLB,vEndLB,validLB,processDataLB];


    pirelab.instantiateNetwork(cNet,lineBufNet,LineBufferIn,LineBufferOut,'ColumnLineBuffer');


    MinMaxBlockInfo.compType='Max';
    MinMaxBlockInfo.rndMode='Floor';
    MinMaxBlockInfo.satMode='Wrap';

    columnMaxNet=this.addMinMaxTree(cNet,MinMaxBlockInfo,sigInfo,inRate,dataOutLB,dataOut,blockInfo.kHeight);
    pirelab.instantiateNetwork(cNet,columnMaxNet,dataOutLB,dataOutCol,'colMax');

    if mod(blockInfo.kWidth,2)==0
        pipeDelay=ceil(log2(blockInfo.kHeight))+3;
    else
        pipeDelay=ceil(log2(blockInfo.kHeight))+1;
    end

    if mod(blockInfo.kWidth,2)==0
        pirelab.getIntDelayComp(cNet,dataOutCol,dataOut,3);
    else
        pirelab.getUnitDelayComp(cNet,dataOutCol,dataOut);

    end
    pirelab.getIntDelayComp(cNet,hStartLB,hStartOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,hEndLB,hEndOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,vStartLB,vStartOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,vEndLB,vEndOut,pipeDelay);
    pirelab.getIntDelayComp(cNet,validLB,validOut,pipeDelay);































