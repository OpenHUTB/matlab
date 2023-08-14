function elaborateMedianFilter(this,topNet,blockInfo,insignals,outsignals)














    dataIn=insignals(1);
    inRate=dataIn.SimulinkRate;
    hstartIn=insignals(2);
    hendIn=insignals(3);
    vstartIn=insignals(4);
    vendIn=insignals(5);
    validIn=insignals(6);




    dataOut=outsignals(1);
    hstartOut=outsignals(2);
    hendOut=outsignals(3);
    vstartOut=outsignals(4);
    vendOut=outsignals(5);
    validOut=outsignals(6);




    dI=struct(dataIn.Type);

    if isfield(dI,'Dimensions')
        inputDim=dataIn.Type.Dimensions;
    else
        inputDim=1;
    end

    blockInfo.NumberOfPixels=inputDim;



    boolType=pir_boolean_t();
    dataInType=dataIn.Type;

    if inputDim==1
        lbufVType=pirelab.getPirVectorType(dataIn.Type,blockInfo.NSize);
    else
        lbufVType=pirelab.createPirArrayType(dataInType.BaseType,[blockInfo.NSize,dataInType.Dimensions]);
    end






    lbufData=topNet.addSignal(lbufVType,'lbufData');
    lbufhs=topNet.addSignal(boolType,'lbufhstart');
    lbufhe=topNet.addSignal(boolType,'lbufhend');
    lbufvs=topNet.addSignal(boolType,'lbufvstart');
    lbufve=topNet.addSignal(boolType,'lbufvend');
    lbufvalid=topNet.addSignal(boolType,'lbufvalid');
    processData=topNet.addSignal(boolType,'processData');



    lbufInfo.KernelHeight=blockInfo.NSize;
    lbufInfo.KernelWidth=blockInfo.NSize;
    lbufInfo.PaddingMethod=blockInfo.PaddingMethod;
    lbufInfo.PaddingValue=blockInfo.PaddingValue;
    lbufInfo.MaxLineSize=blockInfo.LineBufferSize;
    lbufInfo.BiasUp=true;
    lbufInfo.DataType=dataIn.Type;
    lbufInfo.lbufVType=lbufVType;
    blockInfo.lbufVType=lbufVType;
    lbufNet=this.addLineBuffer(topNet,lbufInfo,inRate);

    pirelab.instantiateNetwork(topNet,lbufNet,[dataIn,hstartIn,hendIn,vstartIn,vendIn,validIn],...
    [lbufData,lbufhs,lbufhe,lbufvs,lbufve,lbufvalid,processData],'LineBuffer');



    medianvalue=topNet.addSignal(dataIn.Type,'medianValue');


    if inputDim==1
        mcNet=this.elabMedianCore(topNet,blockInfo,inRate);
    else
        blockInfo.dataOutType=outsignals(1).Type;
        mcNet=this.elabMultiPixelMedianCore(topNet,blockInfo,inRate);
    end


    mcNet.addComment('Median Core');

    pirelab.instantiateNetwork(topNet,mcNet,[lbufData,processData],medianvalue,'mcNet_inst');




    if blockInfo.NumberOfPixels==1
        linebufferDelay=blockInfo.bSize;
    else
        halfWidth=floor(blockInfo.NSize/2);
        numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
        linebufferDelay=floor(numMatrices/2);
    end



    switch blockInfo.NSize
    case 3
        mcDelay=4;

    case 5
        mcDelay=11;

    case 7
        mcDelay=14;
    end


    outregDelay=1;


    if strcmpi(blockInfo.PaddingMethod,'None')



        validREG=topNet.addSignal(boolType,'validREG');
        hstartKernelOut=topNet.addSignal(boolType,'hstartKernelOut');
        hendKernelOut=topNet.addSignal(boolType,'hendKernelOut');
        vstartKernelOut=topNet.addSignal(boolType,'vstartKernelOut');
        vendKernelOut=topNet.addSignal(boolType,'vendKernelOut');
        validKernelOut=topNet.addSignal(boolType,'validKernelOut');
        pirelab.getIntDelayEnabledComp(topNet,lbufhs,hstartKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayComp(topNet,lbufhe,hendKernelOut,linebufferDelay);


        pirelab.getUnitDelayEnabledResettableComp(topNet,lbufhe,validREG,lbufhe,hendKernelOut,'validREG',0,'',true,'',-1,true);

        pirelab.getIntDelayEnabledComp(topNet,lbufvs,vstartKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayComp(topNet,lbufve,vendKernelOut,linebufferDelay);

        validEnbDelay=topNet.addSignal(boolType,'validEnbDelay');
        pirelab.getIntDelayEnabledResettableComp(topNet,lbufvalid,validEnbDelay,processData,lbufhe,linebufferDelay);

        pirelab.getLogicComp(topNet,[validEnbDelay,validREG],validKernelOut,'or');

        processOREndLine=topNet.addSignal(boolType,'processOREndLine');
        pirelab.getLogicComp(topNet,[processData,validREG],processOREndLine,'or');


        hstartKernelValidOut=topNet.addSignal(boolType,'hstartKernelValidOut');
        hendKernelValidOut=topNet.addSignal(boolType,'hendKernelValidOut');
        vstartKernelValidOut=topNet.addSignal(boolType,'vstartKernelValidOut');
        vendKernelValidOut=topNet.addSignal(boolType,'vendKernelValidOut');
        validKernelValidOut=topNet.addSignal(boolType,'validKernelValidOut');




        pirelab.getLogicComp(topNet,[hstartKernelOut,processOREndLine],hstartKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[hendKernelOut,processOREndLine],hendKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[vstartKernelOut,processOREndLine],vstartKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[vendKernelOut,processOREndLine],vendKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[validKernelOut,processOREndLine],validKernelValidOut,'and');


    else

        hstartKernelOut=topNet.addSignal(boolType,'hstartKernelOut');
        hendKernelOut=topNet.addSignal(boolType,'hendKernelOut');
        vstartKernelOut=topNet.addSignal(boolType,'vstartKernelOut');
        vendKernelOut=topNet.addSignal(boolType,'vendKernelOut');
        validKernelOut=topNet.addSignal(boolType,'validKernelOut');
        pirelab.getIntDelayEnabledComp(topNet,lbufhs,hstartKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayEnabledComp(topNet,lbufhe,hendKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayEnabledComp(topNet,lbufvs,vstartKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayEnabledComp(topNet,lbufve,vendKernelOut,processData,linebufferDelay);
        pirelab.getIntDelayEnabledComp(topNet,lbufvalid,validKernelOut,processData,linebufferDelay);

        hstartKernelValidOut=topNet.addSignal(boolType,'hstartKernelValidOut');
        hendKernelValidOut=topNet.addSignal(boolType,'hendKernelValidOut');
        vstartKernelValidOut=topNet.addSignal(boolType,'vstartKernelValidOut');
        vendKernelValidOut=topNet.addSignal(boolType,'vendKernelValidOut');
        validKernelValidOut=topNet.addSignal(boolType,'validKernelValidOut');
        pirelab.getLogicComp(topNet,[hstartKernelOut,processData],hstartKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[hendKernelOut,processData],hendKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[vstartKernelOut,processData],vstartKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[vendKernelOut,processData],vendKernelValidOut,'and');
        pirelab.getLogicComp(topNet,[validKernelOut,processData],validKernelValidOut,'and');
    end


    ctrlDelay=mcDelay+outregDelay;

    pirelab.getIntDelayComp(topNet,hstartKernelValidOut,hstartOut,ctrlDelay);
    pirelab.getIntDelayComp(topNet,hendKernelValidOut,hendOut,ctrlDelay);
    pirelab.getIntDelayComp(topNet,vstartKernelValidOut,vstartOut,ctrlDelay);
    pirelab.getIntDelayComp(topNet,vendKernelValidOut,vendOut,ctrlDelay);

    if blockInfo.NumberOfPixels==1

        if strcmpi(blockInfo.PaddingMethod,'None')
            pixelSel=topNet.addSignal(boolType,'pixelsel');
            psDataEnd=topNet.addSignal(boolType,'pixelselEnd');
            notEnd=topNet.addSignal(boolType,'notEnd');
            notEndREG=topNet.addSignal(boolType,'notEndReg');
            notEndREGD=topNet.addSignal(boolType,'notEndD');
            pirelab.getUnitDelayEnabledResettableComp(topNet,hendKernelValidOut,notEndREG,hendKernelValidOut,lbufhs,'validREG',0,'',true,'',-1,true);
            pirelab.getIntDelayComp(topNet,notEndREG,notEndREGD,mcDelay-(floor(blockInfo.NSize/2)));


            pirelab.getLogicComp(topNet,notEndREGD,notEnd,'not');

            valD=topNet.addSignal(boolType,'valD');

            switch blockInfo.NSize
            case 3
                psDelay=0;

            case 5
                psDelay=1;

            case 7
                psDelay=2;
            end


            pirelab.getIntDelayComp(topNet,validKernelValidOut,psDataEnd,mcDelay);
            pirelab.getLogicComp(topNet,[psDataEnd,notEnd],pixelSel,'and');
            pirelab.getIntDelayComp(topNet,validKernelValidOut,valD,mcDelay);
            pirelab.getIntDelayComp(topNet,valD,validOut,outregDelay);
        else
            pixelSel=topNet.addSignal(boolType,'pixelsel');
            pirelab.getIntDelayComp(topNet,validKernelValidOut,pixelSel,mcDelay);
            pirelab.getIntDelayComp(topNet,pixelSel,validOut,outregDelay);

        end
        falseout=topNet.addSignal(dataIn.Type,'falseout');
        comp=pirelab.getConstComp(topNet,falseout,0);
        comp.addComment('Constant zero');


        validpixel=topNet.addSignal(dataIn.Type,'validpixel');
        pirelab.getSwitchComp(topNet,[medianvalue,falseout],validpixel,pixelSel,'','==',1);


        pirelab.getIntDelayComp(topNet,validpixel,dataOut,outregDelay);
    else

        pixelSel=topNet.addSignal(boolType,'pixelsel');
        if blockInfo.NSize==3||blockInfo.NSize==7
            pirelab.getIntDelayComp(topNet,validKernelValidOut,pixelSel,mcDelay+1);
            pirelab.getIntDelayComp(topNet,pixelSel,validOut,outregDelay-1);
        else
            pirelab.getIntDelayComp(topNet,validKernelValidOut,pixelSel,mcDelay);
            pirelab.getIntDelayComp(topNet,pixelSel,validOut,outregDelay);
        end
        falseout=topNet.addSignal(dataIn.Type,'falseout');
        comp=pirelab.getConstComp(topNet,falseout,0);
        comp.addComment('Constant zero');


        validpixel=topNet.addSignal(dataIn.Type,'validpixel');
        pirelab.getSwitchComp(topNet,[medianvalue,falseout],validpixel,pixelSel,'','==',1);

        if blockInfo.NSize==3||blockInfo.NSize==7
            pirelab.getWireComp(topNet,validpixel,dataOut);
        else
            pirelab.getUnitDelayComp(topNet,validpixel,dataOut);

        end

    end

