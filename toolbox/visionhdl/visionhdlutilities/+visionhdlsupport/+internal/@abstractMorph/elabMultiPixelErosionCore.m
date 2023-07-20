function cNet=elabMultiPixelErosionCore(this,topNet,blockInfo,inRate)





    boolType=pir_boolean_t();
    pixelVType=pirelab.getPirVectorType(boolType,blockInfo.kHeight);
    pixelInType=blockInfo.lbufVType;
    pixelOType=pirelab.getPirVectorType(boolType,blockInfo.NumberOfPixels);


    inportnames{1}='pixelInVec';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';
    inportnames{7}='processData';


    outportnames{1}='pixelOut';
    outportnames{2}='hStartOut';
    outportnames{3}='hEndOut';
    outportnames{4}='vStartOut';
    outportnames{5}='vEndOut';
    outportnames{6}='validOut';




    cNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','ErosionCore',...
    'InportNames',inportnames,...
    'InportTypes',[pixelInType,boolType,boolType,boolType,boolType,boolType,boolType],...
    'InportRates',[inRate,inRate,inRate,inRate,inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[pixelOType,boolType,boolType,boolType,boolType,boolType]...
    );
    cNet.addComment('Find local minima in binary image');


    data_in=cNet.PirInputSignals(1);
    hstartIn=cNet.PirInputSignals(2);
    hendIn=cNet.PirInputSignals(3);
    vstartIn=cNet.PirInputSignals(4);
    vendIn=cNet.PirInputSignals(5);
    validIn=cNet.PirInputSignals(6);
    enbIn=cNet.PirInputSignals(7);

    dataout=cNet.PirOutputSignals(1);
    hstartOut=cNet.PirOutputSignals(2);
    hendOut=cNet.PirOutputSignals(3);
    vstartOut=cNet.PirOutputSignals(4);
    vendOut=cNet.PirOutputSignals(5);
    validOut=cNet.PirOutputSignals(6);









    halfWidth=floor(blockInfo.kWidth/2);
    numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
    blockInfo.NumMatrices=numMatrices;


    if numMatrices==3
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+halfWidth*2;
    else
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+(halfWidth-((ceil(halfWidth/double(blockInfo.NumberOfPixels)))-1)*blockInfo.NumberOfPixels)*2;
    end

    for ii=1:1:numMatrices
        matrixDelay(ii)=cNet.addSignal2('Type',pixelInType,'Name',['MatrixDelay',num2str(ii)]);
        if ii==1

            pirelab.getWireComp(cNet,data_in,matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(cNet,matrixDelay(ii-1),matrixDelay(ii),enbIn,1);
        end
    end


    partialColumn=(floor(double(blockInfo.kWidth/2)))-((ceil((floor(blockInfo.kWidth/2))/double(blockInfo.NumberOfPixels))-1)*double(blockInfo.NumberOfPixels));

    columnType=pirelab.createPirArrayType(boolType,[blockInfo.kHeight,1]);

    evenKernel=double(mod(blockInfo.kWidth,2)==0);

    windowCount=uint16(1);
    for ii=numMatrices:-1:1

        if ii==1

            for jj=1:1:partialColumn
                selectorIndex=(jj);
                columnArray(windowCount)=cNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);



                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(cNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=cNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);




                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(cNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=cNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};


                pirelab.getSelectorComp(cNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(boolType,[blockInfo.kHeight,blockInfo.kWidth]);

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=cNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(cNet,columnArray(kk+evenKernel:blockInfo.kWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end



    kernelNet=this.elabMultiPixelErosionKernel(cNet,blockInfo,inRate);



    for jj=1:1:blockInfo.NumberOfPixels
        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;
        for ii=1:1:blockInfo.kWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;
            tapOutSig(jj,((ii-1)*blockInfo.kHeight)+1:ii*blockInfo.kHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);
        end


        kernelOut(jj)=cNet.addSignal2('Type',boolType,'Name','KernelOut');
        pirelab.instantiateNetwork(cNet,kernelNet,[kernelWindow(jj),enbIn],...
        kernelOut(jj),'ErosionKernel');

    end





    kW=blockInfo.kWidth;
    Nhood=blockInfo.Nhood;

    finalor=cNet.addSignal2('Type',pixelOType,'Name','KernelOut');



    pirelab.getConcatenateComp(cNet,kernelOut(:),finalor,'FilterKernelConcat','2');


    linebufferDelay=floor((numMatrices)/2);

    if blockInfo.kWidth==1&&blockInfo.kHeight==2
        hdlDelay=0;
    else
        hdlDelay=1;
    end

    if strcmpi(blockInfo.PaddingMethod,'None')


        hstartKernelOut=cNet.addSignal(boolType,'hStartKernelOut');
        hendKernelOut=cNet.addSignal(boolType,'hEndKernelOut');
        vstartKernelOut=cNet.addSignal(boolType,'vStartKernelOut');
        vendKernelOut=cNet.addSignal(boolType,'vEndKernelOut');
        pirelab.getIntDelayEnabledComp(cNet,hstartIn,hstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayComp(cNet,hendIn,hendKernelOut,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vstartIn,vstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayComp(cNet,vendIn,vendKernelOut,linebufferDelay);



        hstartKernelValidOut=cNet.addSignal(boolType,'hStartKernelValidOut');
        hendKernelValidOut=cNet.addSignal(boolType,'hEndKernelValidOut');
        vstartKernelValidOut=cNet.addSignal(boolType,'vStartKernelValidOut');
        vendKernelValidOut=cNet.addSignal(boolType,'vEndKernelValidOut');
        pirelab.getLogicComp(cNet,[hstartKernelOut,enbIn],hstartKernelValidOut,'and');
        pirelab.getWireComp(cNet,hendKernelOut,hendKernelValidOut);
        pirelab.getLogicComp(cNet,[vstartKernelOut,enbIn],vstartKernelValidOut,'and');
        pirelab.getWireComp(cNet,vendKernelOut,vendKernelValidOut);



        pirelab.getIntDelayComp(cNet,hstartKernelValidOut,hstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,hendKernelValidOut,hendOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vstartKernelValidOut,vstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vendKernelValidOut,vendOut,hdlDelay);



        validREG=cNet.addSignal(boolType,'validREG');
        pirelab.getUnitDelayEnabledResettableComp(cNet,hendIn,validREG,hendIn,hendKernelOut,'validREG',0,'',true,'',-1,true);


        pixelSel=cNet.addSignal(boolType,'pixelsel');
        pixelSelEnb=cNet.addSignal(boolType,'pixelsel');
        pirelab.getIntDelayEnabledResettableComp(cNet,validIn,pixelSel,enbIn,hendIn,linebufferDelay);
        pixelSelValidOut=cNet.addSignal(boolType,'validKernelValidOut');
        pirelab.getLogicComp(cNet,[pixelSel,enbIn],pixelSelEnb,'and');
        pirelab.getLogicComp(cNet,[pixelSelEnb,validREG],pixelSelValidOut,'or');
        pirelab.getIntDelayComp(cNet,pixelSelValidOut,validOut,hdlDelay);

        falseout=cNet.addSignal(pixelOType,'falseout');
        comp=pirelab.getConstComp(cNet,falseout,false);
        comp.addComment('Constant zero');


        validpixel=cNet.addSignal(pixelOType,'validpixel');
        pirelab.getSwitchComp(cNet,[finalor,falseout],validpixel,pixelSelValidOut,'','==',1);
        pirelab.getUnitDelayComp(cNet,validpixel,dataout);


    else



        hstartKernelOut=cNet.addSignal(boolType,'hStartKernelOut');
        hendKernelOut=cNet.addSignal(boolType,'hEndKernelOut');
        vstartKernelOut=cNet.addSignal(boolType,'vStartKernelOut');
        vendKernelOut=cNet.addSignal(boolType,'vEndKernelOut');
        pirelab.getIntDelayEnabledComp(cNet,hstartIn,hstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,hendIn,hendKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vstartIn,vstartKernelOut,enbIn,linebufferDelay);
        pirelab.getIntDelayEnabledComp(cNet,vendIn,vendKernelOut,enbIn,linebufferDelay);



        hstartKernelValidOut=cNet.addSignal(boolType,'hStartKernelValidOut');
        hendKernelValidOut=cNet.addSignal(boolType,'hEndKernelValidOut');
        vstartKernelValidOut=cNet.addSignal(boolType,'vStartKernelValidOut');
        vendKernelValidOut=cNet.addSignal(boolType,'vEndKernelValidOut');
        pirelab.getLogicComp(cNet,[hstartKernelOut,enbIn],hstartKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[hendKernelOut,enbIn],hendKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[vstartKernelOut,enbIn],vstartKernelValidOut,'and');
        pirelab.getLogicComp(cNet,[vendKernelOut,enbIn],vendKernelValidOut,'and');


        pirelab.getIntDelayComp(cNet,hstartKernelValidOut,hstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,hendKernelValidOut,hendOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vstartKernelValidOut,vstartOut,hdlDelay);
        pirelab.getIntDelayComp(cNet,vendKernelValidOut,vendOut,hdlDelay);

        pixelSel=cNet.addSignal(boolType,'pixelsel');

        pirelab.getIntDelayEnabledComp(cNet,validIn,pixelSel,enbIn,linebufferDelay);
        pixelSelValidOut=cNet.addSignal(boolType,'validKernelValidOut');
        pirelab.getLogicComp(cNet,[pixelSel,enbIn],pixelSelValidOut,'and');
        pirelab.getIntDelayComp(cNet,pixelSelValidOut,validOut,hdlDelay);

        falseout=cNet.addSignal(pixelOType,'falseout');
        comp=pirelab.getConstComp(cNet,falseout,false);
        comp.addComment('Constant zero');


        validpixel=cNet.addSignal(pixelOType,'validpixel');
        pirelab.getSwitchComp(cNet,[finalor,falseout],validpixel,pixelSelValidOut,'','==',1);
        pirelab.getUnitDelayComp(cNet,validpixel,dataout);
    end
