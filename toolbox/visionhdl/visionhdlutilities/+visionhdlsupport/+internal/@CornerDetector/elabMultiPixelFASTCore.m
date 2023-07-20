function FASTcoreNet=elabMultiPixelFASTCore(~,topNet,blockInfo,dataRate)





    pixelInType=topNet.PirInputSignals(1).Type.BaseType;
    ctrlType=pir_boolean_t();
    FASTcoreNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FASTCore',...
    'InportNames',{'pixelInVec','ShiftEnb'},...
    'InportTypes',[blockInfo.pixelInVecDT,ctrlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'Gv','Gh'},...
    'OutportTypes',[blockInfo.gradMultiPixelType,blockInfo.gradMultiPixelType]);


    pixelInVec=FASTcoreNet.PirInputSignals(1);
    processIn=FASTcoreNet.PirInputSignals(2);


    GvOut=FASTcoreNet.PirOutputSignals(1);
    GhOut=FASTcoreNet.PirOutputSignals(2);



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
        matrixDelay(ii)=FASTcoreNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);
        if ii==1

            pirelab.getWireComp(FASTcoreNet,pixelInVec,matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(FASTcoreNet,matrixDelay(ii-1),matrixDelay(ii),processIn,1);
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
                columnArray(windowCount)=FASTcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);



                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(FASTcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;



            end
        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=FASTcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);




                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(FASTcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=FASTcoreNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};


                pirelab.getSelectorComp(FASTcoreNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,blockInfo.KernelWidth]);

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=FASTcoreNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(FASTcoreNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end




    for jj=1:1:blockInfo.NumberOfPixels


        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;
        for ii=1:1:blockInfo.KernelWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;
            tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);
        end




        Adder1Type=FASTcoreNet.getType('FixedPoint',...
        'Signed',pixelInType.Signed,...
        'WordLength',pixelInType.WordLength+1,...
        'FractionLength',pixelInType.FractionLength);

        Adder2Type=FASTcoreNet.getType('FixedPoint',...
        'Signed',pixelInType.Signed,...
        'WordLength',pixelInType.WordLength+2,...
        'FractionLength',pixelInType.FractionLength);

        Adder3Type=FASTcoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',pixelInType.WordLength+3,...
        'FractionLength',pixelInType.FractionLength);

        DTCx2Type=FASTcoreNet.getType('FixedPoint',...
        'Signed',pixelInType.Signed,...
        'WordLength',pixelInType.WordLength,...
        'FractionLength',pixelInType.FractionLength+1);

        DTCd8Type=FASTcoreNet.getType('FixedPoint',...
        'Signed',true,...
        'WordLength',Adder3Type.WordLength,...
        'FractionLength',Adder3Type.FractionLength-3);







        p1S1(jj)=FASTcoreNet.addSignal(pixelInType,['Line1Col1Pixel',num2str(jj)]);
        p2S1(jj)=FASTcoreNet.addSignal(pixelInType,['Line1Col2Pixel',num2str(jj)]);
        p3S1(jj)=FASTcoreNet.addSignal(pixelInType,['Line1Col3Pixel',num2str(jj)]);
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,7),p1S1(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,8),p2S1(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,9),p3S1(jj));


        p1S2(jj)=FASTcoreNet.addSignal(pixelInType,['Line2Col1Pixel',num2str(jj)]);
        p2S2(jj)=FASTcoreNet.addSignal(pixelInType,['Line2Col2Pixel',num2str(jj)]);
        p3S2(jj)=FASTcoreNet.addSignal(pixelInType,['Line2Col3Pixel',num2str(jj)]);
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,4),p1S2(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,5),p2S2(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,6),p3S2(jj));


        p1S3(jj)=FASTcoreNet.addSignal(pixelInType,['Line3Col1Pixel',num2str(jj)]);
        p2S3(jj)=FASTcoreNet.addSignal(pixelInType,['Line3Col2Pixel',num2str(jj)]);
        p3S3(jj)=FASTcoreNet.addSignal(pixelInType,['Line3Col3Pixel',num2str(jj)]);
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,1),p1S3(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,2),p2S3(jj));
        pirelab.getUnitDelayComp(FASTcoreNet,tapOutSig(jj,3),p3S3(jj));




        Gvadder1(jj)=FASTcoreNet.addSignal(Adder1Type,'GvAdder1');
        pirelab.getAddComp(FASTcoreNet,[p1S3(jj),p3S3(jj)],Gvadder1(jj));
        Gvadder1Delay(jj)=FASTcoreNet.addSignal(Adder1Type,'GvAdder1Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Gvadder1(jj),Gvadder1Delay(jj));

        p2S3x2(jj)=FASTcoreNet.addSignal(DTCx2Type,'p2S3x2');
        pirelab.getDTCComp(FASTcoreNet,p2S3(jj),p2S3x2(jj),'Floor','Saturate','SI');
        p2S3x2Delay(jj)=FASTcoreNet.addSignal(DTCx2Type,'p2S3x2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,p2S3x2(jj),p2S3x2Delay(jj));

        Gvadder2(jj)=FASTcoreNet.addSignal(Adder2Type,'GvAdder2');
        pirelab.getAddComp(FASTcoreNet,[Gvadder1Delay(jj),p2S3x2Delay(jj)],Gvadder2(jj));
        Gvadder2Delay(jj)=FASTcoreNet.addSignal(Adder2Type,'GvAdder2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Gvadder2(jj),Gvadder2Delay(jj));

        Gvadder3(jj)=FASTcoreNet.addSignal(Adder1Type,'GvAdder3');
        pirelab.getAddComp(FASTcoreNet,[p1S1(jj),p3S1(jj)],Gvadder3(jj));
        Gvadder3Delay(jj)=FASTcoreNet.addSignal(Adder1Type,'GvAdder3Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Gvadder3(jj),Gvadder3Delay(jj));

        p2S1x2(jj)=FASTcoreNet.addSignal(DTCx2Type,'p2Sx2');
        pirelab.getDTCComp(FASTcoreNet,p2S1(jj),p2S1x2(jj),'Floor','Saturate','SI');
        p2S1x2Delay(jj)=FASTcoreNet.addSignal(DTCx2Type,'p2Sx2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,p2S1x2(jj),p2S1x2Delay(jj));

        Gvadder4(jj)=FASTcoreNet.addSignal(Adder2Type,'GvAdder4');
        pirelab.getAddComp(FASTcoreNet,[p2S1x2Delay(jj),Gvadder3Delay(jj)],Gvadder4(jj));
        Gvadder4Delay(jj)=FASTcoreNet.addSignal(Adder2Type,'GvAdder4Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Gvadder4(jj),Gvadder4Delay(jj));

        Gvadder5(jj)=FASTcoreNet.addSignal(Adder3Type,'GvAdder5');
        pirelab.getSubComp(FASTcoreNet,[Gvadder2Delay(jj),Gvadder4Delay(jj)],Gvadder5(jj));

        Gvdtc1(jj)=FASTcoreNet.addSignal(DTCd8Type,'gvdtc1');
        GvDiv8=pirelab.getDTCComp(FASTcoreNet,Gvadder5(jj),Gvdtc1(jj),'Floor','Saturate','SI');
        GvDiv8.addComment('Gv: Right-shift 3 bit to perform divided by 8');
        Gvdtc1Delay(jj)=FASTcoreNet.addSignal(DTCd8Type,'gvdtc1Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Gvdtc1(jj),Gvdtc1Delay(jj));

        GvOutSig(jj)=FASTcoreNet.addSignal(blockInfo.gradType,'gvOutSig');


        Gv=pirelab.getDTCComp(FASTcoreNet,Gvdtc1Delay(jj),GvOutSig(jj),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        Gv.addComment('Gv: Cast to the specified gradient data type. Full precision if outputing binary image only');


        Ghadder1(jj)=FASTcoreNet.addSignal(Adder1Type,'GhAdder1');
        pirelab.getAddComp(FASTcoreNet,[p1S1(jj),p1S3(jj)],Ghadder1(jj));
        Ghadder1Delay(jj)=FASTcoreNet.addSignal(Adder1Type,'GhAdder1Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Ghadder1(jj),Ghadder1Delay(jj));

        p1S2x2(jj)=FASTcoreNet.addSignal(DTCx2Type,'p1S2x2');
        pirelab.getDTCComp(FASTcoreNet,p1S2(jj),p1S2x2(jj),'Floor','Saturate','SI');
        p1S2x2Delay(jj)=FASTcoreNet.addSignal(DTCx2Type,'p1S2x2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,p1S2x2(jj),p1S2x2Delay(jj));

        Ghadder2(jj)=FASTcoreNet.addSignal(Adder2Type,'GhAdder2');
        pirelab.getAddComp(FASTcoreNet,[p1S2x2Delay(jj),Ghadder1Delay(jj)],Ghadder2(jj));
        Ghadder2Delay(jj)=FASTcoreNet.addSignal(Adder2Type,'GhAdder2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Ghadder2(jj),Ghadder2Delay(jj));

        Ghadder3(jj)=FASTcoreNet.addSignal(Adder1Type,'GhAdder3');
        pirelab.getAddComp(FASTcoreNet,[p3S1(jj),p3S3(jj)],Ghadder3(jj));
        Ghadder3Delay(jj)=FASTcoreNet.addSignal(Adder1Type,'GhAdder3Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Ghadder3(jj),Ghadder3Delay(jj));

        p3S2x2(jj)=FASTcoreNet.addSignal(DTCx2Type,'p3S2x2');
        pirelab.getDTCComp(FASTcoreNet,p3S2(jj),p3S2x2(jj),'Floor','Saturate','SI');
        p3S2x2Delay(jj)=FASTcoreNet.addSignal(DTCx2Type,'p3S2x2Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,p3S2x2(jj),p3S2x2Delay(jj));

        Ghadder4(jj)=FASTcoreNet.addSignal(Adder2Type,'GhAdder4');
        pirelab.getAddComp(FASTcoreNet,[p3S2x2Delay(jj),Ghadder3Delay(jj)],Ghadder4(jj));
        Ghadder4Delay(jj)=FASTcoreNet.addSignal(Adder2Type,'GhAdder4Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Ghadder4(jj),Ghadder4Delay(jj));

        Ghadder5(jj)=FASTcoreNet.addSignal(Adder3Type,'GhAdder5');
        pirelab.getSubComp(FASTcoreNet,[Ghadder4Delay(jj),Ghadder2Delay(jj)],Ghadder5(jj));

        Ghdtc1(jj)=FASTcoreNet.addSignal(DTCd8Type,'ghdtc1');
        GhDiv8=pirelab.getDTCComp(FASTcoreNet,Ghadder5(jj),Ghdtc1(jj),'Floor','Saturate','SI');
        GhDiv8.addComment('Gh: Right-shift 3 bit to perform divided by 8');
        Ghdtc1Delay(jj)=FASTcoreNet.addSignal(DTCd8Type,'ghdtc1Delay');
        pirelab.getUnitDelayComp(FASTcoreNet,Ghdtc1(jj),Ghdtc1Delay(jj));


        GhOutSig(jj)=FASTcoreNet.addSignal(blockInfo.gradType,'ghOutSig');

        Gh=pirelab.getDTCComp(FASTcoreNet,Ghdtc1Delay(jj),GhOutSig(jj),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        Gh.addComment('Gh: Cast to the specified gradient data type. Full precision if outputing binary image only');


    end



    pirelab.getMuxComp(FASTcoreNet,GvOutSig(:),GvOut);
    pirelab.getMuxComp(FASTcoreNet,GhOutSig(:),GhOut);





