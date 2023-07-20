function prewittcoreNet=elabMultiPixelPrewittCore(~,topNet,blockInfo,dataRate)





    pixelInType=topNet.PirInputSignals(1).Type.BaseType;
    ctrlType=pir_boolean_t();
    prewittcoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','PrewittCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'Gv','Gh'},...
    'OutportTypes',[blockInfo.gradMultiPixelType,blockInfo.gradMultiPixelType]);


    pixelInVec=prewittcoreNet.PirInputSignals(1);
    processIn=prewittcoreNet.PirInputSignals(2);







    GvOut=prewittcoreNet.PirOutputSignals(1);
    GhOut=prewittcoreNet.PirOutputSignals(2);



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
        matrixDelay(ii)=prewittcoreNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);
        if ii==1

            pirelab.getWireComp(prewittcoreNet,pixelInVec,matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(prewittcoreNet,matrixDelay(ii-1),matrixDelay(ii),processIn,1);
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
                columnArray(windowCount)=prewittcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);



                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(prewittcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;



            end
        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=prewittcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);




                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(prewittcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=prewittcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};


                pirelab.getSelectorComp(prewittcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,blockInfo.KernelWidth]);

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=prewittcoreNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(prewittcoreNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end




    for jj=1:1:blockInfo.NumberOfPixels


        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;
        for ii=1:1:blockInfo.KernelWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;
            tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);
        end
    end



    for ii=1:1:blockInfo.NumberOfPixels




        p1S1(ii)=prewittcoreNet.addSignal(pixelInType,'pixel1Shift');
        p2S1(ii)=prewittcoreNet.addSignal(pixelInType,'pixel2Shift');
        p3S1(ii)=prewittcoreNet.addSignal(pixelInType,'pixel3Shift');
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,7),p1S1(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,8),p2S1(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,9),p3S1(ii));


        p1S2(ii)=prewittcoreNet.addSignal(pixelInType,'pixel1Shift2');
        p2S2(ii)=prewittcoreNet.addSignal(pixelInType,'pixel2Shift2');
        p3S2(ii)=prewittcoreNet.addSignal(pixelInType,'pixel3Shift2');
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,4),p1S2(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,5),p2S2(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,6),p3S2(ii));


        p1S3(ii)=prewittcoreNet.addSignal(pixelInType,'pixel1Shift3');
        p2S3(ii)=prewittcoreNet.addSignal(pixelInType,'pixel2Shift3');
        p3S3(ii)=prewittcoreNet.addSignal(pixelInType,'pixel3Shift3');
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,1),p1S3(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,2),p2S3(ii));
        pirelab.getUnitDelayComp(prewittcoreNet,tapOutSig(ii,3),p3S3(ii));
        Adder1Type=prewittcoreNet.getType('FixedPoint',...
        'Signed',pixelInType.Signed,...
        'WordLength',pixelInType.WordLength+1,...
        'FractionLength',pixelInType.FractionLength);

        Adder2Type=prewittcoreNet.getType('FixedPoint',...
        'Signed',pixelInType.Signed,...
        'WordLength',pixelInType.WordLength+2,...
        'FractionLength',pixelInType.FractionLength);

        SubDT=prewittcoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',pixelInType.WordLength+3,...
        'FractionLength',pixelInType.FractionLength);

        MulDT=prewittcoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',SubDT.WordLength+16,...
        'FractionLength',SubDT.FractionLength-18);


        Gvadder1(ii)=prewittcoreNet.addSignal(Adder1Type,'GvAdder1');
        pirelab.getAddComp(prewittcoreNet,[p1S3(ii),p2S3(ii)],Gvadder1(ii));
        Gvadder1Delay(ii)=prewittcoreNet.addSignal(Adder1Type,'GvAdder1Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Gvadder1(ii),Gvadder1Delay(ii));
        p3S3Delay(ii)=prewittcoreNet.addSignal(pixelInType,'pixel3Shift3Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,p3S3(ii),p3S3Delay(ii));
        Gvadder2(ii)=prewittcoreNet.addSignal(Adder2Type,'GvAdder2');
        pirelab.getAddComp(prewittcoreNet,[Gvadder1Delay(ii),p3S3Delay(ii)],Gvadder2(ii));
        Gvadder2Delay(ii)=prewittcoreNet.addSignal(Adder2Type,'GvAdder2Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Gvadder2(ii),Gvadder2Delay(ii));

        Gvadder3(ii)=prewittcoreNet.addSignal(Adder1Type,'GvAdder3');
        pirelab.getAddComp(prewittcoreNet,[p2S1(ii),p3S1(ii)],Gvadder3(ii));
        Gvadder3Delay(ii)=prewittcoreNet.addSignal(Adder1Type,'GvAdder3Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Gvadder3(ii),Gvadder3Delay(ii));
        p1S1Delay(ii)=prewittcoreNet.addSignal(pixelInType,'pixel1ShiftDelay');
        pirelab.getUnitDelayComp(prewittcoreNet,p1S1(ii),p1S1Delay(ii));
        Gvadder4(ii)=prewittcoreNet.addSignal(Adder2Type,'GvAdder4');
        pirelab.getAddComp(prewittcoreNet,[Gvadder3Delay(ii),p1S1Delay(ii)],Gvadder4(ii));
        Gvadder4Delay(ii)=prewittcoreNet.addSignal(Adder2Type,'GvAdder4Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Gvadder4(ii),Gvadder4Delay(ii));

        Gvadder5(ii)=prewittcoreNet.addSignal(SubDT,'GvAdder5');
        pirelab.getSubComp(prewittcoreNet,[Gvadder2Delay(ii),Gvadder4Delay(ii)],Gvadder5(ii));
        Gvadder5Delay(ii)=prewittcoreNet.addSignal(SubDT,'GvAdder5Delay');
        pirelab.getIntDelayComp(prewittcoreNet,Gvadder5(ii),Gvadder5Delay(ii),3);


        Ghadder1(ii)=prewittcoreNet.addSignal(Adder1Type,'GhAdder1');
        pirelab.getAddComp(prewittcoreNet,[p3S1(ii),p3S2(ii)],Ghadder1(ii));
        Ghadder1Delay(ii)=prewittcoreNet.addSignal(Adder1Type,'GhAdder1Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Ghadder1(ii),Ghadder1Delay(ii));
        Ghadder2(ii)=prewittcoreNet.addSignal(Adder2Type,'GhAdder2');
        pirelab.getAddComp(prewittcoreNet,[Ghadder1Delay(ii),p3S3Delay(ii)],Ghadder2(ii));
        Ghadder2Delay(ii)=prewittcoreNet.addSignal(Adder2Type,'GhAdder2Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Ghadder2(ii),Ghadder2Delay(ii));

        Ghadder3(ii)=prewittcoreNet.addSignal(Adder1Type,'GhAdder3');
        pirelab.getAddComp(prewittcoreNet,[p1S2(ii),p1S3(ii)],Ghadder3(ii));
        Ghadder3Delay(ii)=prewittcoreNet.addSignal(Adder1Type,'GhAdder3Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Ghadder3(ii),Ghadder3Delay(ii));
        Ghadder4(ii)=prewittcoreNet.addSignal(Adder2Type,'GhAdder4');
        pirelab.getAddComp(prewittcoreNet,[Ghadder3Delay(ii),p1S1Delay(ii)],Ghadder4(ii));
        Ghadder4Delay(ii)=prewittcoreNet.addSignal(Adder2Type,'GhAdder4Delay');
        pirelab.getUnitDelayComp(prewittcoreNet,Ghadder4(ii),Ghadder4Delay(ii));

        Ghadder5(ii)=prewittcoreNet.addSignal(SubDT,'GhAdder5');
        pirelab.getSubComp(prewittcoreNet,[Ghadder2Delay(ii),Ghadder4Delay(ii)],Ghadder5(ii));
        Ghadder5Delay(ii)=prewittcoreNet.addSignal(SubDT,'GhAdder5Delay');
        pirelab.getIntDelayComp(prewittcoreNet,Ghadder5(ii),Ghadder5Delay(ii),3);


        coeffvalue=fi(1/6,0,16,18,'RoundingMethod',blockInfo.RoundingMethod,'OverflowAction',blockInfo.OverflowAction);


        GvMul(ii)=prewittcoreNet.addSignal(MulDT,'GvMul');

        pirelab.getGainComp(prewittcoreNet,Gvadder5Delay(ii),GvMul(ii),coeffvalue,3,blockInfo.gainOptimMode);

        GhMul(ii)=prewittcoreNet.addSignal(MulDT,'GhMul');

        pirelab.getGainComp(prewittcoreNet,Ghadder5Delay(ii),GhMul(ii),coeffvalue,3,blockInfo.gainOptimMode);

        GvMulDelay(ii)=prewittcoreNet.addSignal(MulDT,'GvMulDelay');
        pirelab.getIntDelayComp(prewittcoreNet,GvMul(ii),GvMulDelay(ii),2);
        GhMulDelay(ii)=prewittcoreNet.addSignal(MulDT,'GhMulDelay');
        pirelab.getIntDelayComp(prewittcoreNet,GhMul(ii),GhMulDelay(ii),2);

        GvOutSig(ii)=prewittcoreNet.addSignal(blockInfo.gradType,'gvOutSig');
        GhOutSig(ii)=prewittcoreNet.addSignal(blockInfo.gradType,'ghOutSig');



        Gv=pirelab.getDTCComp(prewittcoreNet,GvMulDelay(ii),GvOutSig(ii),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        Gv.addComment('Gv: Cast to the specified gradient data type. Full precision if outputing binary image only');
        Gh=pirelab.getDTCComp(prewittcoreNet,GhMulDelay(ii),GhOutSig(ii),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        Gh.addComment('Gh: Cast to the specified gradient data type. Full precision if outputing binary image only');

    end





    pirelab.getMuxComp(prewittcoreNet,GvOutSig(:),GvOut);
    pirelab.getMuxComp(prewittcoreNet,GhOutSig(:),GhOut);




