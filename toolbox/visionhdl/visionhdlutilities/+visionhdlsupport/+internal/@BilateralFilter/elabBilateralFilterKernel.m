function filterKernelNet=elabBilateralFilterKernel(this,...
    topNet,blockInfo,sigInfo)
















    filterKernelNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BilatKernel',...
    'InportNames',{'dataIn','vStartIn','vEndIn','hStartIn','hEndIn',...
    'validIn','processData'},...
    'InportTypes',[sigInfo.DataInvType,repmat(sigInfo.ctlType,1,6)],...
    'InportRates',repmat(sigInfo.inRate,1,7),...
    'OutportNames',{'dataOut','hStartOut','hEndOut','vStartout','vEndOut','validOut'},...
    'OutportTypes',[sigInfo.DataOutType,repmat(sigInfo.ctlType,1,5)]...
    );


    inSig=filterKernelNet.PirInputSignals;


    inType=sigInfo.DataInType;
    inWL=inType.WordLength;
    inFL=inType.FractionLength;




    totalLatency=floor(blockInfo.KernelWidth/2);

    coeffType=getCoeffType(blockInfo,sigInfo,filterKernelNet);
    G=computeG(blockInfo.KernelHeight,blockInfo.KernelWidth,blockInfo.SpatialStdDev);
    LUTAddrWL=inWL+1;
    LUT=computeLUT(LUTAddrWL,blockInfo.IntensityStdDev,G,coeffType);



    tapOutSig=this.elabBilateralKernelTapDelay(filterKernelNet,...
    inSig,blockInfo,sigInfo);


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
    midH=floor(kH/2)+1;
    midW=floor(kW/2)+1;

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
    midSig=tapOutSig(midH,midW);
    for ii=1:blockInfo.KernelHeight
        for jj=1:blockInfo.KernelWidth
            if(ii==midH&&jj==midW)

                lutRegSigOut(ii,jj)=filterKernelNet.addSignal(coeffType,[lutName,'Reg']);%#ok
                inDlySig(ii,jj)=filterKernelNet.addSignal(inType,'multDataInReg');%#ok
                coeffDlySig(ii,jj)=filterKernelNet.addSignal(coeffType,'multCoeffInReg');%#ok
                multOutSig(ii,jj)=filterKernelNet.addSignal(multType,'multOut');%#ok
                multDlySig(ii,jj)=filterKernelNet.addSignal(multType,'multOut');%#ok

                pirelab.getConstComp(filterKernelNet,lutRegSigOut(ii,jj),LUT(ii+kH*(jj-1)),1);
                pirelab.getIntDelayComp(filterKernelNet,tapOutSig(ii,jj),inDlySig(ii,jj),...
                multPreDelay+subtractLatency+LUTLatency,'multDataInRegister');
                pirelab.getIntDelayComp(filterKernelNet,lutRegSigOut(ii,jj),coeffDlySig(ii,jj),...
                multPreDelay,'multCoeffInRegister');
                pirelab.getMulComp(filterKernelNet,[inDlySig(ii,jj),coeffDlySig(ii,jj)],multOutSig(ii,jj),...
                'Floor','Wrap');
                pirelab.getIntDelayComp(filterKernelNet,multOutSig(ii,jj),multDlySig(ii,jj),...
                multPostDelay,'multDataOutRegister');
            else

                subSigOut(ii,jj)=filterKernelNet.addSignal(subType,subName);%#ok
                pirelab.getSubComp(filterKernelNet,[tapOutSig(ii,jj),midSig],subSigOut(ii,jj));
                subRegSigOut(ii,jj)=filterKernelNet.addSignal(subType,subRegName);%#ok
                pirelab.getUnitDelayComp(filterKernelNet,subSigOut(ii,jj),subRegSigOut(ii,jj),'sub_reg');

                lutAddrSig(ii,jj)=filterKernelNet.addSignal(lutAddrType,[lutName,'addr']);%#ok
                lutSigOut(ii,jj)=filterKernelNet.addSignal(coeffType,[lutName,'Out']);%#ok
                lutRegSigOut(ii,jj)=filterKernelNet.addSignal(coeffType,[lutName,'Reg']);%#ok
                pirelab.getDTCComp(filterKernelNet,subRegSigOut(ii,jj),lutAddrSig(ii,jj),'Nearest','Wrap','SI');
                regcomp=pirelab.getLookupNDComp(filterKernelNet,lutAddrSig(ii,jj),lutSigOut(ii,jj),...
                LUT(ii+kH*(jj-1),:),0,bpType,oType,fType,0,tableidx,'Lookup Table',-1);
                regcomp.addComment(sprintf('Lookup Table(%d,%d)',ii,jj))
                pirelab.getUnitDelayComp(filterKernelNet,lutSigOut(ii,jj),lutRegSigOut(ii,jj),'LUTRegsiter',0,true);

                inDlySig(ii,jj)=filterKernelNet.addSignal(inType,'multDataInReg');%#ok
                coeffDlySig(ii,jj)=filterKernelNet.addSignal(coeffType,'multCoeffInReg');%#ok
                multOutSig(ii,jj)=filterKernelNet.addSignal(multType,'multOut');%#ok
                multDlySig(ii,jj)=filterKernelNet.addSignal(multType,'multOut');%#ok

                pirelab.getIntDelayComp(filterKernelNet,tapOutSig(ii,jj),inDlySig(ii,jj),...
                multPreDelay+subtractLatency+LUTLatency,'multDataInRegister');
                pirelab.getIntDelayComp(filterKernelNet,lutRegSigOut(ii,jj),coeffDlySig(ii,jj),...
                multPreDelay,'multCoeffInRegister');
                pirelab.getMulComp(filterKernelNet,[inDlySig(ii,jj),coeffDlySig(ii,jj)],multOutSig(ii,jj),...
                'Floor','Wrap');
                pirelab.getIntDelayComp(filterKernelNet,multOutSig(ii,jj),multDlySig(ii,jj),...
                multPostDelay,'multDataOutRegister');
            end
        end
    end


    normOutSig=this.elabAdderTree(filterKernelNet,lutRegSigOut,[],'normadd');

    fpFIROutSig=this.elabAdderTree(filterKernelNet,multDlySig,[],'add');

    addLatency=ceil(log2(numel(multDlySig)))+1;

    totalLatency=totalLatency+addLatency;


    normType=normOutSig.type;
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

    recipOutSig=filterKernelNet.addSignal(recipType,'recipOut');
    recipOutRegSig=filterKernelNet.addSignal(recipType,'recipOutReg');
    recipStripScaleSig=filterKernelNet.addSignal(recipScaleAddrType,'recipStripScale');
    recipAddrSig=filterKernelNet.addSignal(recipAddrType,'recipAddr');

    pirelab.getDTCComp(filterKernelNet,normOutSig,recipStripScaleSig,'Floor','Wrap','SI');
    pirelab.getBitSliceComp(filterKernelNet,recipStripScaleSig,recipAddrSig,normWL-1,normWL-recipAddrWL);

    recipbpType=fi(0,0,recipAddrType.WordLength,0);
    recipoType=fi(0,0,recipType.WordLength,-recipType.FractionLength);
    recipfType=fi(0,1,32,31);
    reciptableidx={fi((0:2^recipAddrWL-1),recipbpType.numerictype)};

    pirelab.getLookupNDComp(filterKernelNet,recipAddrSig,recipOutSig,...
    recipLUT,0,recipbpType,recipoType,recipfType,0,reciptableidx,'Recip Lookup Table',-1);
    regcomp.addComment('Reciprocal Lookup Table');
    pirelab.getUnitDelayComp(filterKernelNet,recipOutSig,recipOutRegSig,'RecipLUTRegsiter',0,true);


    sumType=fpFIROutSig.Type;
    fmultType=filterKernelNet.getType('FixedPoint','Signed',1,...
    'WordLength',normType.WordLength+sumType.WordLength,...
    'FractionLength',normType.FractionLength+sumType.FractionLength);
    finalMultDataDly=filterKernelNet.addSignal(sumType,'fmultDataInReg');
    finalMultNormDly=filterKernelNet.addSignal(recipType,'fmultNormInReg');
    finalMultOut=filterKernelNet.addSignal(fmultType,'fmultOut');
    finalMultOutDly=filterKernelNet.addSignal(fmultType,'fmultNormOutReg');
    pirelab.getIntDelayComp(filterKernelNet,fpFIROutSig,finalMultDataDly,...
    multPreDelay,'fmultDataInRegister');
    pirelab.getIntDelayComp(filterKernelNet,recipOutRegSig,finalMultNormDly,...
    multPreDelay+3,'fmultNormInRegister');
    pirelab.getMulComp(filterKernelNet,[finalMultDataDly,finalMultNormDly],finalMultOut,...
    'Floor','Wrap');
    pirelab.getIntDelayComp(filterKernelNet,finalMultOut,finalMultOutDly,...
    multPostDelay+1,'fmultOutRegister');
    recipLatency=1;
    totalLatency=totalLatency+recipLatency+multPreDelay+multPostDelay;



    this.elabConnectToOutput(filterKernelNet,[finalMultOutDly;inSig(2:end)],...
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
