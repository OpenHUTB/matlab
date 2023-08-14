function topNet=elaborateEdgeDetector(this,topNet,blockInfo,insignals,outsignals)









    pixelIn=insignals(1);
    hStartIn=insignals(2);
    hEndIn=insignals(3);
    vStartIn=insignals(4);
    vEndIn=insignals(5);
    validIn=insignals(6);

    inRate=pixelIn.SimulinkRate;




    if blockInfo.BinaryImageOutputPort&&blockInfo.GradientComponentOutputPorts
        Edge=outsignals(1);
        Grad1=outsignals(2);
        Grad2=outsignals(3);
        Edge.SimulinkRate=inRate;
        Grad1.SimulinkRate=inRate;
        Grad2.SimulinkRate=inRate;
        IX=4;
    elseif~blockInfo.BinaryImageOutputPort&&blockInfo.GradientComponentOutputPorts
        Grad1=outsignals(1);
        Grad2=outsignals(2);
        Grad1.SimulinkRate=inRate;
        Grad2.SimulinkRate=inRate;
        IX=3;
    elseif blockInfo.BinaryImageOutputPort&&~blockInfo.GradientComponentOutputPorts
        Edge=outsignals(1);
        Edge.SimulinkRate=inRate;
        IX=2;
    else

    end

    hStartOut=outsignals(IX);
    hEndOut=outsignals(IX+1);
    vStartOut=outsignals(IX+2);
    vEndOut=outsignals(IX+3);
    validOut=outsignals(IX+4);
    hStartOut.SimulinkRate=inRate;
    hEndOut.SimulinkRate=inRate;
    vStartOut.SimulinkRate=inRate;
    vEndOut.SimulinkRate=inRate;
    validOut.SimulinkRate=inRate;


    dataType=pixelIn.Type;
    ctrlType=pir_boolean_t();

















    switch blockInfo.Method
    case 'Sobel'
        fracLen=3;
        wordLen=3;
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,3);
    case 'Prewitt'
        fracLen=18;
        wordLen=19;
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,3);
    otherwise
        fracLen=1;
        wordLen=1;
        blockInfo.pixelInVecDT=pirelab.getPirVectorType(dataType,2);
    end
    blockInfo.gradType=topNet.getType('FixedPoint',...
    'Signed',true,...
    'WordLength',dataType.WordLength+wordLen,...
    'FractionLength',dataType.FractionLength-fracLen);


    if blockInfo.GradientComponentOutputPorts
        if strcmp(blockInfo.GradientDataType,'Same as first input')
            blockInfo.gradType=dataType;
        elseif strcmp(blockInfo.GradientDataType,'Custom')
            blockInfo.gradType=topNet.getType('FixedPoint',...
            'Signed',strcmp(blockInfo.CustomGradientDataType.Signedness,'Signed'),...
            'WordLength',blockInfo.CustomGradientDataType.WordLength,...
            'FractionLength',-blockInfo.CustomGradientDataType.FractionLength);

        end
    end


    if blockInfo.BinaryImageOutputPort
        if blockInfo.gradType.builtin
            blockInfo.thresqType=blockInfo.gradType;
        else
            blockInfo.thresqType=topNet.getType('FixedPoint',...
            'Signed',false,...
            'WordLength',blockInfo.gradType.WordLength*2+1,...
            'FractionLength',blockInfo.gradType.FractionLength*2);
        end

        threshsq=topNet.addSignal(blockInfo.thresqType,'threshold_const');
        if strcmp(blockInfo.ThresholdSource,'Property')
            pirelab.getConstComp(topNet,threshsq,blockInfo.Threshold^2);
        else
            newFrame=topNet.addSignal(ctrlType,'NewFrame');
            pirelab.getLogicComp(topNet,[hStartIn,vStartIn],newFrame,'and');


            assert(~isa(insignals(7).Type,'hdlcoder.tp_double'));
            threshinput=topNet.addSignal(insignals(7).Type,'LatchThreshold');
            pirelab.getUnitDelayEnabledComp(topNet,insignals(7),threshinput,newFrame,'threshold',false,'',false);


            thresqMulType=topNet.getType('FixedPoint',...
            'Signed',false,...
            'WordLength',insignals(7).Type.WordLength*2,...
            'FractionLength',insignals(7).Type.FractionLength*2);

            thPreDelay=topNet.addSignal(insignals(7).Type,'threshPreDelay');
            pirelab.getIntDelayComp(topNet,threshinput,thPreDelay,2);
            threshsqNext=topNet.addSignal(thresqMulType,'inputThreshSq');
            pirelab.getMulComp(topNet,[thPreDelay,thPreDelay],threshsqNext);
            thPostDelay=topNet.addSignal(thresqMulType,'threshPostDelay');
            pirelab.getIntDelayComp(topNet,threshsqNext,thPostDelay,2);

            pirelab.getDTCComp(topNet,thPostDelay,threshsq,'Floor','Saturate');
        end
    end


    LMKData=topNet.addSignal(blockInfo.pixelInVecDT,'LMKDataOut');
    LMKhs=topNet.addSignal(ctrlType,'LMKhStartOut');
    LMKhe=topNet.addSignal(ctrlType,'LMKhEndOut');
    LMKvs=topNet.addSignal(ctrlType,'LMKvStartOut');
    LMKve=topNet.addSignal(ctrlType,'LMKvEndOut');
    LMKvl=topNet.addSignal(ctrlType,'LMKvalidOut');
    ShiftEnb=topNet.addSignal(ctrlType,'LMKShiftEnb');

    LMKInfo.KernelHeight=blockInfo.KernelHeight;
    LMKInfo.KernelWidth=blockInfo.KernelWidth;
    LMKInfo.MaxLineSize=blockInfo.MaxLineSize;
    LMKInfo.PaddingMethod=blockInfo.PaddingMethodString;
    LMKInfo.PaddingValue=0;
    LMKInfo.DataType=dataType;
    LMKInfo.BiasUp=true;

    LMKNet=this.addLineBuffer(topNet,LMKInfo,inRate);

    pirelab.instantiateNetwork(topNet,LMKNet,[pixelIn,hStartIn,hEndIn,vStartIn,vEndIn,validIn],...
    [LMKData,LMKhs,LMKhe,LMKvs,LMKve,LMKvl,ShiftEnb],'LineBuffer');



    g1Out=topNet.addSignal(blockInfo.gradType,'gradcomp1');
    g2Out=topNet.addSignal(blockInfo.gradType,'gradcomp2');
    switch blockInfo.Method
    case 'Sobel'
        sobelcoreNet=this.elabSobelCore(topNet,blockInfo,inRate);
        sobelcoreNet.addComment('Sobel Core');
        pirelab.instantiateNetwork(topNet,sobelcoreNet,[LMKData,ShiftEnb],...
        [g1Out,g2Out],'SobelCoreNet_inst');

        coreDelayBal=5;
    case 'Prewitt'
        prewittcoreNet=this.elabPrewittCore(topNet,blockInfo,inRate);
        prewittcoreNet.addComment('Prewitt Core');
        pirelab.instantiateNetwork(topNet,prewittcoreNet,[LMKData,ShiftEnb],...
        [g1Out,g2Out],'PrewittCoreNet_inst');

        coreDelayBal=9;
    case 'Roberts'
        robertscoreNet=this.elabRobertsCore(topNet,blockInfo,inRate);
        robertscoreNet.addComment('Roberts Core');
        pirelab.instantiateNetwork(topNet,robertscoreNet,[LMKData,ShiftEnb],...
        [g1Out,g2Out],'RobertsCoreNet_inst');

        coreDelayBal=3;
    end


    if blockInfo.BinaryImageOutputPort
        BImageOut=topNet.addSignal(ctrlType,'edge');
        bimageNet=this.elabBinaryImage(topNet,blockInfo,inRate);
        bimageNet.addComment('Generate Binary Image');
        pirelab.instantiateNetwork(topNet,bimageNet,[g1Out,g2Out,threshsq],...
        BImageOut,'BinaryImageNet_inst');
        binaryDelayBal=6;
    else
        binaryDelayBal=0;
    end





    totalDelay=coreDelayBal+binaryDelayBal;
    kernelDelay=1;
    nonKernelDelay=totalDelay-kernelDelay;



    if strcmpi(blockInfo.PaddingMethodString,'None')

        validREG=topNet.addSignal(ctrlType,'validREG');


        hsOKDelay=topNet.addSignal(ctrlType,'hStartOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKhs,hsOKDelay,ShiftEnb,kernelDelay);
        heOKDelay=topNet.addSignal(ctrlType,'hEndOutKernelDelay');
        pirelab.getIntDelayComp(topNet,LMKhe,heOKDelay,kernelDelay);

        pirelab.getUnitDelayEnabledResettableComp(topNet,LMKhe,validREG,LMKhe,heOKDelay,'validREG',0,'',true,'',-1,true);

        vsOKDelay=topNet.addSignal(ctrlType,'vStartOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKvs,vsOKDelay,ShiftEnb,kernelDelay);
        veOKDelay=topNet.addSignal(ctrlType,'vEndOutKernelDelay');
        pirelab.getIntDelayComp(topNet,LMKve,veOKDelay,kernelDelay);
        vlOKDelay=topNet.addSignal(ctrlType,'validOutKernelDelay');
        validEnbDelay=topNet.addSignal(ctrlType,'validEnbDelay');
        pirelab.getIntDelayEnabledResettableComp(topNet,LMKvl,validEnbDelay,ShiftEnb,LMKhe,kernelDelay);


        pirelab.getLogicComp(topNet,[validEnbDelay,validREG],vlOKDelay,'or');

        processOREndLine=topNet.addSignal(ctrlType,'processOREndLine');
        pirelab.getLogicComp(topNet,[ShiftEnb,validREG],processOREndLine,'or');



        hsOKVDelay=topNet.addSignal(ctrlType,'hStartOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[hsOKDelay,processOREndLine],hsOKVDelay,'and');
        heOKVDelay=topNet.addSignal(ctrlType,'hEndOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[heOKDelay,processOREndLine],heOKVDelay,'and');
        vsOKVDelay=topNet.addSignal(ctrlType,'vStartOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[vsOKDelay,processOREndLine],vsOKVDelay,'and');
        veOKVDelay=topNet.addSignal(ctrlType,'vEndOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[veOKDelay,processOREndLine],veOKVDelay,'and');
        vlOKVDelay=topNet.addSignal(ctrlType,'validOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[vlOKDelay,processOREndLine],vlOKVDelay,'and');



    else
        hsOKDelay=topNet.addSignal(ctrlType,'hStartOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKhs,hsOKDelay,ShiftEnb,kernelDelay);
        heOKDelay=topNet.addSignal(ctrlType,'hEndOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKhe,heOKDelay,ShiftEnb,kernelDelay);
        vsOKDelay=topNet.addSignal(ctrlType,'vStartOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKvs,vsOKDelay,ShiftEnb,kernelDelay);
        veOKDelay=topNet.addSignal(ctrlType,'vEndOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKve,veOKDelay,ShiftEnb,kernelDelay);
        vlOKDelay=topNet.addSignal(ctrlType,'validOutKernelDelay');
        pirelab.getIntDelayEnabledComp(topNet,LMKvl,vlOKDelay,ShiftEnb,kernelDelay);


        hsOKVDelay=topNet.addSignal(ctrlType,'hStartOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[hsOKDelay,ShiftEnb],hsOKVDelay,'and');
        heOKVDelay=topNet.addSignal(ctrlType,'hEndOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[heOKDelay,ShiftEnb],heOKVDelay,'and');
        vsOKVDelay=topNet.addSignal(ctrlType,'vStartOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[vsOKDelay,ShiftEnb],vsOKVDelay,'and');
        veOKVDelay=topNet.addSignal(ctrlType,'vEndOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[veOKDelay,ShiftEnb],veOKVDelay,'and');
        vlOKVDelay=topNet.addSignal(ctrlType,'validOutValidKernelDelay');
        pirelab.getLogicComp(topNet,[vlOKDelay,ShiftEnb],vlOKVDelay,'and');
    end

    hsODelay=topNet.addSignal(ctrlType,'hStartOutDelay');
    pirelab.getIntDelayComp(topNet,hsOKVDelay,hsODelay,nonKernelDelay);
    heODelay=topNet.addSignal(ctrlType,'hEndOutDelay');
    pirelab.getIntDelayComp(topNet,heOKVDelay,heODelay,nonKernelDelay);
    vsODelay=topNet.addSignal(ctrlType,'vStartOutDelay');
    pirelab.getIntDelayComp(topNet,vsOKVDelay,vsODelay,nonKernelDelay);
    veODelay=topNet.addSignal(ctrlType,'vEndOutDelay');
    pirelab.getIntDelayComp(topNet,veOKVDelay,veODelay,nonKernelDelay);
    vlODelay=topNet.addSignal(ctrlType,'validOutDelay');
    pirelab.getIntDelayComp(topNet,vlOKVDelay,vlODelay,nonKernelDelay);


    hStartNext=topNet.addSignal(ctrlType,'hsNext');
    pirelab.getLogicComp(topNet,[vlODelay,hsODelay],hStartNext,'and');
    hEndNext=topNet.addSignal(ctrlType,'heNext');
    pirelab.getLogicComp(topNet,[vlODelay,heODelay],hEndNext,'and');
    vStartNext=topNet.addSignal(ctrlType,'vsNext');
    pirelab.getLogicComp(topNet,[vlODelay,vsODelay],vStartNext,'and');
    vEndNext=topNet.addSignal(ctrlType,'veNext');
    pirelab.getLogicComp(topNet,[vlODelay,veODelay],vEndNext,'and');

    pirelab.getUnitDelayComp(topNet,hStartNext,hStartOut);
    pirelab.getUnitDelayComp(topNet,hEndNext,hEndOut);
    pirelab.getUnitDelayComp(topNet,vStartNext,vStartOut);
    pirelab.getUnitDelayComp(topNet,vEndNext,vEndOut);
    pirelab.getUnitDelayComp(topNet,vlODelay,validOut);

    if blockInfo.GradientComponentOutputPorts
        g1OutDelay=topNet.addSignal(blockInfo.gradType,'g1OutDelay');
        g2OutDelay=topNet.addSignal(blockInfo.gradType,'g2OutDelay');
        if binaryDelayBal>0
            pirelab.getIntDelayComp(topNet,g1Out,g1OutDelay,binaryDelayBal);
            pirelab.getIntDelayComp(topNet,g2Out,g2OutDelay,binaryDelayBal);
        else
            pirelab.getWireComp(topNet,g1Out,g1OutDelay);
            pirelab.getWireComp(topNet,g2Out,g2OutDelay);
        end
        zeroconst=topNet.addSignal(blockInfo.gradType,'const_zero');
        pirelab.getConstComp(topNet,zeroconst,0);

        switchout1=topNet.addSignal(blockInfo.gradType,'g1OutNext');
        pirelab.getSwitchComp(topNet,[zeroconst,g1OutDelay],switchout1,vlODelay);
        pirelab.getUnitDelayComp(topNet,switchout1,Grad1);

        switchout2=topNet.addSignal(blockInfo.gradType,'g2OutNext');
        pirelab.getSwitchComp(topNet,[zeroconst,g2OutDelay],switchout2,vlODelay);
        pirelab.getUnitDelayComp(topNet,switchout2,Grad2);
    end

    if blockInfo.BinaryImageOutputPort
        edgeNext=topNet.addSignal(ctrlType,'edgeNext');
        pirelab.getLogicComp(topNet,[vlODelay,BImageOut],edgeNext,'and');
        pirelab.getUnitDelayComp(topNet,edgeNext,Edge);
    end
