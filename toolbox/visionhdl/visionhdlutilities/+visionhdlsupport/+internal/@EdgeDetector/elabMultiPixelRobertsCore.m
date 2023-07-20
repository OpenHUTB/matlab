function robertscoreNet=elabMultiPixelRobertsCore(~,topNet,blockInfo,dataRate)






    ctrlType=pir_boolean_t();
    robertscoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','RobertsCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'G45','G135'},...
    'OutportTypes',[blockInfo.gradMultiPixelType,blockInfo.gradMultiPixelType]);


    pixelInVec=robertscoreNet.PirInputSignals(1);
    processIn=robertscoreNet.PirInputSignals(2);


    pixelInSplit=pixelInVec.split;
    pixelIn1=pixelInSplit.PirOutputSignals(1);
    pixelIn2=pixelInSplit.PirOutputSignals(2);

    G45Out=robertscoreNet.PirOutputSignals(1);
    G135Out=robertscoreNet.PirOutputSignals(2);


    halfWidth=floor(blockInfo.KernelWidth/2);
    numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
    blockInfo.NumMatrices=numMatrices;
    dataVType=blockInfo.pixelInVecDT;

    if numMatrices==3
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+halfWidth*2;
    else
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+(halfWidth-((ceil(halfWidth/double(blockInfo.NumberOfPixels)))-1)*blockInfo.NumberOfPixels)*2;
    end

    for ii=1:1:numMatrices
        matrixDelay(ii)=robertscoreNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);
        if ii==1

            pirelab.getWireComp(robertscoreNet,pixelInVec,matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(robertscoreNet,matrixDelay(ii-1),matrixDelay(ii),processIn,1);
        end
    end


    partialColumn=(floor(double(blockInfo.KernelWidth/2)))-((ceil((floor(blockInfo.KernelWidth/2))/double(blockInfo.NumberOfPixels))-1)*double(blockInfo.NumberOfPixels));

    columnType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,1]);

    evenKernel=double(mod(blockInfo.KernelWidth,2)==0);

    windowCount=uint16(1);
    for ii=numMatrices:-1:1

        if ii==1

            for jj=1:1:partialColumn
                selectorIndex=(jj);
                columnArray(windowCount)=robertscoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);



                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(robertscoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;



            end
        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=robertscoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);




                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(robertscoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=robertscoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};


                pirelab.getSelectorComp(robertscoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,blockInfo.KernelWidth]);

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=robertscoreNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(robertscoreNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end




    for jj=1:1:blockInfo.NumberOfPixels


        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;
        for ii=1:1:blockInfo.KernelWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;
            tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);
        end
    end





    for ii=1:1:blockInfo.NumberOfPixels



        PInType=pixelIn1.Type.BaseType;
        p1S1(ii)=robertscoreNet.addSignal(PInType,'pixel1Shift');
        p2S1(ii)=robertscoreNet.addSignal(PInType,'pixel2Shift');
        pirelab.getUnitDelayComp(robertscoreNet,tapOutSig(ii,3),p1S1(ii));
        pirelab.getUnitDelayComp(robertscoreNet,tapOutSig(ii,4),p2S1(ii));

        p1S2(ii)=robertscoreNet.addSignal(PInType,'pixel1Shift2');
        p2S2(ii)=robertscoreNet.addSignal(PInType,'pixel2Shift2');
        pirelab.getUnitDelayComp(robertscoreNet,tapOutSig(ii,1),p1S2(ii));
        pirelab.getUnitDelayComp(robertscoreNet,tapOutSig(ii,2),p2S2(ii));






        SubType=robertscoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',PInType.WordLength+1,...
        'FractionLength',PInType.FractionLength);
        DTCType=robertscoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',PInType.WordLength+1,...
        'FractionLength',PInType.FractionLength-1);


        adder1(ii)=robertscoreNet.addSignal(SubType,'sub1');
        pirelab.getSubComp(robertscoreNet,[p2S2(ii),p1S1(ii)],adder1(ii));
        dtc1(ii)=robertscoreNet.addSignal(DTCType,'dtc1');
        G45Div2=pirelab.getDTCComp(robertscoreNet,adder1(ii),dtc1(ii),'Floor','Saturate','SI');
        G45Div2.addComment('G45: Right-shift 1 bit to perform division by 2');
        dtc1D(ii)=robertscoreNet.addSignal(DTCType,'dtc1Delay');
        pirelab.getUnitDelayComp(robertscoreNet,dtc1(ii),dtc1D(ii));

        G45OutSig(ii)=robertscoreNet.addSignal(blockInfo.gradType,'ghOutSig');


        G45=pirelab.getDTCComp(robertscoreNet,dtc1D(ii),G45OutSig(ii),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        G45.addComment('G45: Cast to the specified gradient data type. Full precision if outputing binary image only');


        adder2(ii)=robertscoreNet.addSignal(SubType,'sub2');
        pirelab.getSubComp(robertscoreNet,[p2S1(ii),p1S2(ii)],adder2(ii));
        dtc2(ii)=robertscoreNet.addSignal(DTCType,'dtc2');
        G135Div2=pirelab.getDTCComp(robertscoreNet,adder2(ii),dtc2(ii),'Floor','Saturate','SI');
        G135Div2.addComment('G135: Right-shift 1 bit to perform division by 2');
        dtc2D(ii)=robertscoreNet.addSignal(DTCType,'dtc2Delay');
        pirelab.getUnitDelayComp(robertscoreNet,dtc2(ii),dtc2D(ii));

        G135OutSig(ii)=robertscoreNet.addSignal(blockInfo.gradType,'ghOutSig');


        G135=pirelab.getDTCComp(robertscoreNet,dtc2D(ii),G135OutSig(ii),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        G135.addComment('G135: Cast to the specified gradient data type. Full precision if outputing binary image only');
    end


    pirelab.getMuxComp(robertscoreNet,G45OutSig(:),G45Out);
    pirelab.getMuxComp(robertscoreNet,G135OutSig(:),G135Out);






