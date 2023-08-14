function mcNet=elabMultiPixelMedianCore(this,topNet,blockInfo,dataRate)





    bankWL=ceil(log2(blockInfo.NSize));
    bankType=pir_ufixpt_t(bankWL,0);
    ctlType=pir_boolean_t();
    NSize=blockInfo.NSize;
    bSize=blockInfo.bSize;
    blockInfo.KernelHeight=NSize;
    blockInfo.KernelWidth=NSize;
    dinType=blockInfo.lbufVType;
    dim=dinType.Dimensions;
    NumPixels=dim(2);
    dinvType=pirelab.getPirVectorType(dinType.BaseType,NSize);
    dColType=pirelab.getPirVectorType(dinType.BaseType,NSize);
    dataOutType=blockInfo.dataOutType;
    dataVTransposeType=pirelab.createPirArrayType(dinType.BaseType,[NumPixels,NSize]);
    blockInfo.dataVTransposeType=dataVTransposeType;

    dataVType=blockInfo.lbufVType;

    mcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','MedianCore',...
    'InportNames',{'dataCol','processData'},...
    'InportTypes',[dataVType,ctlType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'medianValue'},...
    'OutportTypes',dataOutType...
    );


    dataCol=mcNet.PirInputSignals(1);
    processData=mcNet.PirInputSignals(2);
    medianOut=mcNet.PirOutputSignals(1);

















    dataColsplit=dataCol.split.PirOutputSignals;


    for ii=1:NumPixels
        d(:,ii)=dataColsplit(ii).split.PirOutputSignals;
    end



    t3=[1,2;2,3;1,2];
    t5=[1,2,3,4;2,4,3,5;1,3,2,5;2,3,4,5;3,4,0,0];
    t7=[1,2,3,4,5,6;1,3,2,4,5,7;1,5,2,6,3,7;2,5,4,7,0,0;3,5,4,6,0,0;2,3,4,5,6,7];

    switch NSize
    case 3
        sTable=t3;
    case 5
        sTable=t5;
    case 7
        sTable=t7;
    otherwise
        sTable=t3;

    end



    msNet=this.elabSort2(mcNet,dataRate,dinType.BaseType);
    msNet.addComment('Compare two value');
    msiNet=this.elabSort2_Idx(mcNet,dataRate,NSize,dinType.BaseType);
    msiNet.addComment('Compare two value with Idx');

    for ii=1:1:NumPixels
        [scol(ii),addDelay,sortNdelay]=sortN(mcNet,msNet,d(:,ii),NSize,sTable,'sortedIn');








        dcol(ii)=scol(ii);

    end





    dataMatSorted=mcNet.addSignal2('Type',dinType,'Name','dataMatSorted');

    if(numel(size(dataMatSorted.Type.Dimensions))==2&&...
        dcol(1).Type.Dimensions==dataMatSorted.Type.Dimension(1))


        pirelab.getConcatenateComp(mcNet,dcol(:),dataMatSorted,'SortedColumnConcat','2');
    else

        pirelab.getConcatenateComp(mcNet,dcol(:),dataMatSorted,'SortedColumnConcat','1');
    end








    halfWidth=floor(blockInfo.KernelWidth/2);
    numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
    blockInfo.NumMatrices=numMatrices;

    processDataD=mcNet.addSignal2('Type',ctlType,'Name','processDataD');

    pirelab.getUnitDelayComp(mcNet,processData,processDataD);

    if numMatrices==3
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+halfWidth*2;
    else
        windowLength=((numMatrices-2)*blockInfo.NumberOfPixels)+(halfWidth-((ceil(halfWidth/double(blockInfo.NumberOfPixels)))-1)*blockInfo.NumberOfPixels)*2;
    end

    for ii=1:1:numMatrices
        matrixDelay(ii)=mcNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);
        if ii==1

            pirelab.getWireComp(mcNet,dataMatSorted,matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(mcNet,matrixDelay(ii-1),matrixDelay(ii),processDataD,1);
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
                columnArray(windowCount)=mcNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);



                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(mcNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;



            end
        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=mcNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);




                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(mcNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=mcNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};


                pirelab.getSelectorComp(mcNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,blockInfo.KernelWidth]);
    blockInfo.filterKernelType=filterKernelType;

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=mcNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(mcNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end





    multiPixelKernelNet=this.elabMultiPixelKernel(mcNet,blockInfo,dataRate);

    for ii=1:1:blockInfo.NumberOfPixels
        medianValue(ii)=mcNet.addSignal2('Type',dataVType.BaseType,'Name','medianValue');
        pirelab.instantiateNetwork(mcNet,multiPixelKernelNet,[kernelWindow(ii),processDataD],medianValue(ii),'mcNet_inst');
    end


    medianVec=mcNet.addSignal2('Type',dataOutType,'Name','MedianVec');
    pirelab.getConcatenateComp(mcNet,medianValue(:),medianVec,'MedianConcat','1');
    pirelab.getWireComp(mcNet,medianVec,medianOut);



end





function[sortCol,addDelay,sortNdelay]=sortN(mcNet,msNet,ins,NSize,sTable,sname)

    [stages,pcoms]=size(sTable);
    dinType=ins(1).Type;
    dinvType=pirelab.getPirVectorType(dinType,NSize);
    sIn=ins;
    m=1;
    sortNdelay=0;
    for i=1:stages
        for j=1:NSize
            if isempty(find(sTable(i,:)==j))
                sOut(i,j)=sIn(j);
            else
                sOut(i,j)=mcNet.addSignal(dinType,[sname,'_',num2str(i),'_',num2str(j)]);
            end
        end

        for k=1:2:pcoms
            t1=sTable(i,k);
            t2=sTable(i,k+1);
            if t1~=0
                pirelab.instantiateNetwork(mcNet,msNet,[sIn(t1),sIn(t2)],[sOut(i,t1),sOut(i,t2)],'msNet_inst');
            end
        end

        if rem(i,3)==0

            for jj=1:NSize
                sortColReg(m,jj)=mcNet.addSignal(dinType,[sname,'ColReg_',num2str(i),'_',num2str(jj)]);
                pirelab.getUnitDelayComp(mcNet,sOut(i,jj),sortColReg(m,jj),'sorted ColRegister');
            end
            sIn=sortColReg(m,:);
            m=m+1;
            sortNdelay=sortNdelay+1;
        else

            sIn=sOut(i,:);
        end
    end

    sortCol=mcNet.addSignal(dinvType,[sname,'ColVector']);
    pirelab.getMuxComp(mcNet,sIn,sortCol);
    addDelay=(rem(stages,3)~=0);
end









