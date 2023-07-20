function filterKernelNet=elabBilateralFilterKernelMultiPixel(this,...
    topNet,blockInfo,sigInfo)














    dataVType=sigInfo.DataInvType;

    filterKernelNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BilatKernel',...
    'InportNames',{'dataIn','hStartIn','hEndIn','vStartIn','vEndIn'...
    ,'validIn','processData'},...
    'InportTypes',[sigInfo.DataInvType,repmat(sigInfo.ctlType,1,6)],...
    'InportRates',repmat(sigInfo.inRate,1,7),...
    'OutportNames',{'dataOut','hStartOut','hEndOut','vStartout','vEndOut','validOut'},...
    'OutportTypes',[sigInfo.DataOutType,repmat(sigInfo.ctlType,1,5)]...
    );


    inSig=filterKernelNet.PirInputSignals;

    inType=sigInfo.DataInType.BaseType;
    inWL=inType.BaseType.WordLength;
    inFL=inType.BaseType.FractionLength;

    coeffType=getCoeffType(blockInfo,sigInfo,filterKernelNet);
    G=computeG(blockInfo.KernelHeight,blockInfo.KernelWidth,blockInfo.SpatialStdDev);
    LUTAddrWL=inWL+1;
    LUT=computeLUT(LUTAddrWL,blockInfo.IntensityStdDev,G,coeffType);

    processIn=inSig(7);






    halfWidth=floor(blockInfo.KernelWidth/2);


    numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
    blockInfo.NumMatrices=numMatrices;

    for ii=1:1:numMatrices
        matrixDelay(ii)=filterKernelNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);%#ok<*AGROW> 
        if ii==1

            pirelab.getWireComp(filterKernelNet,inSig(1),matrixDelay(ii));
        else
            pirelab.getIntDelayEnabledComp(filterKernelNet,matrixDelay(ii-1),matrixDelay(ii),processIn,1);
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
                columnArray(windowCount)=filterKernelNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(filterKernelNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;



            end
        elseif ii==numMatrices

            for jj=1:1:partialColumn
                selectorIndex=((blockInfo.NumberOfPixels-partialColumn)+jj);
                columnArray(windowCount)=filterKernelNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(filterKernelNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        else

            for jj=1:1:blockInfo.NumberOfPixels
                selectorIndex=(jj);
                columnArray(windowCount)=filterKernelNet.addSignal2('Type',columnType,'Name',['ColumnArray',num2str(windowCount)]);

                selIndices={[1,2],double(selectorIndex)};

                pirelab.getSelectorComp(filterKernelNet,matrixDelay(ii),columnArray(windowCount),...
                'one-based',{'Select all','Index vector (dialog)'},selIndices,{'1','1'}','2','Select',[5,4]);
                windowCount=windowCount+1;
            end

        end

    end

    filterKernelType=pirelab.createPirArrayType(dataVType.BaseType,[blockInfo.KernelHeight,blockInfo.KernelWidth]);

    for kk=1:1:blockInfo.NumberOfPixels
        kernelWindow(kk)=filterKernelNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);
        pirelab.getConcatenateComp(filterKernelNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end

    for jj=1:1:blockInfo.NumberOfPixels
        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;


        for ii=1:1:blockInfo.KernelWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;




            tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);
        end






        totalLatency=floor(blockInfo.KernelWidth/2);


        subtractLatency=1;
        totalLatency=totalLatency+subtractLatency;
        LUTLatency=1;
        totalLatency=totalLatency+LUTLatency;

        multPreDelay=2;
        multPostDelay=2;
        multLatency=multPreDelay+multPostDelay;
        totalLatency=totalLatency+multLatency;

        kH=blockInfo.KernelHeight;
        kW=blockInfo.KernelWidth;

        subType=filterKernelNet.getType('FixedPoint','Signed',1,...
        'WordLength',inWL+1,'FractionLength',inFL);
        subName='sub';
        subRegName='subreg';
        lutAddrType=filterKernelNet.getType('FixedPoint','Signed',0,...
        'WordLength',inWL+1,'FractionLength',0);
        lutName='LUT';
        multType=filterKernelNet.getType('FixedPoint',...
        'Signed',1,...
        'WordLength',inWL+1+coeffType.WordLength,...
        'FractionLength',inFL+coeffType.FractionLength);
        bpType=fi(0,0,LUTAddrWL,0);
        oType=fi(0,coeffType.Signed,coeffType.WordLength,-1*coeffType.FractionLength);
        fType=fi(0,1,32,31);
        tableidx={fi((0:2^LUTAddrWL-1),bpType.numerictype)};


        kernel_size=kH*kW;
        midSig=tapOutSig(jj,ceil(kernel_size/2));


        for ll=1:kernel_size
            if(ll==ceil(kernel_size/2))

                lutRegSigOut(jj,ll)=filterKernelNet.addSignal(coeffType,[lutName,'Reg']);
                inDlySig(jj,ll)=filterKernelNet.addSignal(inType,['multDataInReg',num2str(jj),num2str(ll)]);
                coeffDlySig(jj,ll)=filterKernelNet.addSignal(coeffType,['multCoeffInReg',num2str(jj),num2str(ll)]);
                multOutSig(jj,ll)=filterKernelNet.addSignal(multType,['multOut',num2str(jj),num2str(ll)]);
                multDlySig(jj,ll)=filterKernelNet.addSignal(multType,['multDly',num2str(jj),num2str(ll)]);

                pirelab.getConstComp(filterKernelNet,lutRegSigOut(jj,ll),LUT(ll),1);
                pirelab.getIntDelayComp(filterKernelNet,tapOutSig(jj,ll),inDlySig(jj,ll),...
                multPreDelay+subtractLatency+LUTLatency,['multDataInRegister',num2str(jj),num2str(ll)]);
                pirelab.getIntDelayComp(filterKernelNet,lutRegSigOut(jj,ll),coeffDlySig(jj,ll),...
                multPreDelay,['multCoeffInRegister',num2str(jj),num2str(ll)]);
                pirelab.getMulComp(filterKernelNet,[inDlySig(jj,ll),coeffDlySig(jj,ll)],multOutSig(jj,ll),...
                'Floor','Wrap');
                pirelab.getIntDelayComp(filterKernelNet,multOutSig(jj,ll),multDlySig(jj,ll),...
                multPostDelay,['multDataOutRegister',num2str(jj),num2str(ll)]);
            else

                subSigOut(jj,ll)=filterKernelNet.addSignal(subType,subName);
                pirelab.getSubComp(filterKernelNet,[tapOutSig(jj,ll),midSig],subSigOut(jj,ll));
                subRegSigOut(jj,ll)=filterKernelNet.addSignal(subType,subRegName);
                pirelab.getUnitDelayComp(filterKernelNet,subSigOut(jj,ll),subRegSigOut(jj,ll),['sub_reg',num2str(jj),num2str(ll)]);


                lutAddrSig(jj,ll)=filterKernelNet.addSignal(lutAddrType,[lutName,'addr',num2str(jj),num2str(ll)]);
                lutSigOut(jj,ll)=filterKernelNet.addSignal(coeffType,[lutName,'Out',num2str(jj),num2str(ll)]);
                lutRegSigOut(jj,ll)=filterKernelNet.addSignal(coeffType,[lutName,'Reg',num2str(jj),num2str(ll)]);
                pirelab.getDTCComp(filterKernelNet,subRegSigOut(jj,ll),lutAddrSig(jj,ll),'Nearest','Wrap','SI');
                regcomp=pirelab.getLookupNDComp(filterKernelNet,lutAddrSig(jj,ll),lutSigOut(jj,ll),...
                LUT(ll,:),0,bpType,oType,fType,0,tableidx,['Lookup Table',num2str(jj),num2str(ll)],-1);
                regcomp.addComment(sprintf('Lookup Table(%d,%d)',jj,ll))
                pirelab.getUnitDelayComp(filterKernelNet,lutSigOut(jj,ll),lutRegSigOut(jj,ll),['LUTRegister',num2str(jj),num2str(ll)],0,true);


                inDlySig(jj,ll)=filterKernelNet.addSignal(inType,['multDataInReg',num2str(jj),num2str(ll)]);
                coeffDlySig(jj,ll)=filterKernelNet.addSignal(coeffType,['multCoeffInReg',num2str(jj),num2str(ll)]);
                multOutSig(jj,ll)=filterKernelNet.addSignal(multType,['multOut',num2str(jj),num2str(ll)]);
                multDlySig(jj,ll)=filterKernelNet.addSignal(multType,['multDly',num2str(jj),num2str(ll)]);

                pirelab.getIntDelayComp(filterKernelNet,tapOutSig(jj,ll),inDlySig(jj,ll),...
                multPreDelay+subtractLatency+LUTLatency,['multDataInRegister',num2str(jj),num2str(ll)]);
                pirelab.getIntDelayComp(filterKernelNet,lutRegSigOut(jj,ll),coeffDlySig(jj,ll),...
                multPreDelay,['multCoeffInRegister',num2str(jj),num2str(ll)]);
                pirelab.getMulComp(filterKernelNet,[inDlySig(jj,ll),coeffDlySig(jj,ll)],multOutSig(jj,ll),...
                'Floor','Wrap');
                pirelab.getIntDelayComp(filterKernelNet,multOutSig(jj,ll),multDlySig(jj,ll),...
                multPostDelay,['multDataOutRegister',num2str(jj),num2str(ll)]);
            end
        end


        normOutSig(jj)=this.elabAdderTree(filterKernelNet,lutRegSigOut(jj,:),[],'normadd');

        fpFIROutSig(jj)=this.elabAdderTree(filterKernelNet,multDlySig(jj,:),[],'add');

        addLatency=ceil(log2(numel(multDlySig(jj,:))))+1;

        totalLatency=totalLatency+addLatency;


        normType=normOutSig(jj).type;
        normWL=normType.WordLength;
        normFL=normType.FractionLength;
        [recipLUT,recipWL,recipFL]=computeRecipLUT(normWL,normFL);

        recipType=filterKernelNet.getType('FixedPoint','Signed',0,...
        'WordLength',recipWL,'FractionLength',recipFL);
        recipScaleAddrType=filterKernelNet.getType('FixedPoint','Signed',0,...
        'WordLength',normWL,'FractionLength',0);
        recipAddrWL=min(11,normWL);
        recipAddrType=filterKernelNet.getType('FixedPoint','Signed',0,...
        'WordLength',recipAddrWL,'FractionLength',0);

        recipOutSig(jj)=filterKernelNet.addSignal(recipType,['recipOut',num2str(jj)]);
        recipOutRegSig(jj)=filterKernelNet.addSignal(recipType,['recipOutReg',num2str(jj)]);
        recipStripScaleSig(jj)=filterKernelNet.addSignal(recipScaleAddrType,['recipStripScale',num2str(jj)]);
        recipAddrSig(jj)=filterKernelNet.addSignal(recipAddrType,['recipAddr',num2str(jj)]);

        pirelab.getDTCComp(filterKernelNet,normOutSig(jj),recipStripScaleSig(jj),'Floor','Wrap','SI');
        pirelab.getBitSliceComp(filterKernelNet,recipStripScaleSig(jj),recipAddrSig(jj),normWL-1,normWL-recipAddrWL);

        recipbpType=fi(0,0,recipAddrType.WordLength,0);
        recipoType=fi(0,0,recipType.WordLength,-recipType.FractionLength);
        recipfType=fi(0,1,32,31);
        reciptableidx={fi((0:2^recipAddrWL-1),recipbpType.numerictype)};

        pirelab.getLookupNDComp(filterKernelNet,recipAddrSig(jj),recipOutSig(jj),...
        recipLUT,0,recipbpType,recipoType,recipfType,0,reciptableidx,['Recip Lookup Table',num2str(jj)],-1);
        regcomp.addComment('Reciprocal Lookup Table');
        pirelab.getUnitDelayComp(filterKernelNet,recipOutSig(jj),recipOutRegSig(jj),['RecipLUTRegsiter',num2str(jj)],0,true);


        sumType=fpFIROutSig(jj).Type;
        fmultType=filterKernelNet.getType('FixedPoint','Signed',1,...
        'WordLength',normType.WordLength+sumType.WordLength,...
        'FractionLength',normType.FractionLength+sumType.FractionLength);
        finalMultDataDly(jj)=filterKernelNet.addSignal(sumType,['fmultDataInReg',num2str(jj)]);
        finalMultNormDly(jj)=filterKernelNet.addSignal(recipType,['fmultNormInReg',num2str(jj)]);
        finalMultOut(jj)=filterKernelNet.addSignal(fmultType,['fmultOut',num2str(jj)]);
        finalMultOutDly(jj)=filterKernelNet.addSignal(fmultType,['fmultNormOutReg',num2str(jj)]);
        pirelab.getIntDelayComp(filterKernelNet,fpFIROutSig(jj),finalMultDataDly(jj),...
        multPreDelay,['fmultDataInRegister',num2str(jj)]);
        pirelab.getIntDelayComp(filterKernelNet,recipOutRegSig(jj),finalMultNormDly(jj),...
        multPreDelay+3,['fmultNormInRegister',num2str(jj)]);
        pirelab.getMulComp(filterKernelNet,[finalMultDataDly(jj),finalMultNormDly(jj)],finalMultOut(jj),...
        'Floor','Wrap');
        pirelab.getIntDelayComp(filterKernelNet,finalMultOut(jj),finalMultOutDly(jj),...
        multPostDelay+1,['fmultOutRegister',num2str(jj)]);
        recipLatency=1;
        totalLatency=totalLatency+recipLatency+multPreDelay+multPostDelay;

    end




    finalOutVecType=pirelab.getPirVectorType(finalMultOutDly(1).Type,[blockInfo.NumberOfPixels,1],1);

    finalMultOutDlyVec=filterKernelNet.addSignal2('Type',finalOutVecType,'Name','FilterOut');
    pirelab.getMuxComp(filterKernelNet,finalMultOutDly(:),finalMultOutDlyVec);

    this.elabConnectMultiToOutput(filterKernelNet,[finalMultOutDlyVec;inSig(2:end)],...
    totalLatency,blockInfo);


end


function coeffType=getCoeffType(blockInfo,sigInfo,hN)

    if blockInfo.CoefficientsDataType==1
        coeffType=sigInfo.DataInType;
    else
        coeffs=fi(0,blockInfo.CustomCoefficientsDataType);
        coeffType=hN.getType('FixedPoint','Signed',coeffs.Signed,...
        'WordLength',coeffs.WordLength,...
        'FractionLength',-1*coeffs.FractionLength);
    end

end

function G=computeG(kH,kW,spatialStdDev)
    w=floor(kW/2);
    h=floor(kH/2);
    [Xcoord,Ycoord]=meshgrid(-w:w,-h:h);
    G=exp(-(Xcoord.^2+Ycoord.^2)/(2*spatialStdDev.^2));
    G(G<eps(max(G(:))))=0;
    sumG=sum(G(:));
    if sumG~=0
        G=G/sumG;
    end
end

function[LUT,zeroLUT]=computeLUT(LUTAddrWL,intensityStdDev,G,coeffType)
    range=[0:((2^(LUTAddrWL-1))-1),(-(2^(LUTAddrWL-1))):-1]./(2^(LUTAddrWL-1));
    intensityCoeff=exp((range.^2)./(-2*intensityStdDev.^2));
    H=G(:);
    coeffExampleType=fi(0,coeffType.Signed,coeffType.WordLength,-1*coeffType.FractionLength);
    tempLUT=zeros(length(H),length(range),'like',coeffExampleType);
    tempZero=false(length(H),1);
    for ii=1:length(H)
        tempLUT(ii,:)=H(ii).*intensityCoeff;
        tempZero(ii)=all(tempLUT(ii,:)==0);
    end
    LUT=tempLUT;
    zeroLUT=tempZero;
end


function[recipLUT,recipWL,recipFL]=computeRecipLUT(normWL,normFL)
    RLUTAddrNBits=max(2,min(normWL,11));
    RLUTAddr=0:((2^RLUTAddrNBits)-1);
    RLUTDataNBits=max(normWL,(-normFL)+2);
    recipWL=RLUTDataNBits;
    recipFL=normFL;
    sumMSPart=RLUTAddr./2.^(RLUTAddrNBits-max((normWL-(-normFL)),0));
    recipMSPart=1./sumMSPart;
    infParts=isinf(recipMSPart);
    recipMSPart(infParts)=1.0;
    tmpRecipLUT=fi(recipMSPart,0,RLUTDataNBits,-normFL);
    tmpRecipLUT(infParts)=realmax(tmpRecipLUT);
    recipLUT=tmpRecipLUT;
end
