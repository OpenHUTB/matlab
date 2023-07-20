function filterKernelNet=elabFIRFilterKernelMultiPixel(this,...
    topNet,blockInfo,sigInfo)














    dataVType=sigInfo.DataInvType;

    if~blockInfo.coeffFromPort
        filterKernelNet=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','FIR2DKernel',...
        'InportNames',{'dataIn','vStartIn','vEndIn','hStartIn','hEndIn',...
        'validIn','processData'},...
        'InportTypes',[sigInfo.DataInvType,repmat(sigInfo.ctlType,1,6)],...
        'InportRates',repmat(sigInfo.inRate,1,7),...
        'OutportNames',{'dataOut','vStartOut','vEndOut','hStartOut','hEndOut','validOut'},...
        'OutportTypes',[sigInfo.DataOutType,repmat(sigInfo.ctlType,1,5)]...
        );


        [coeffs,coeffType]=getCoeffValueandType(blockInfo,sigInfo,filterKernelNet);
        sigInfo.coeffType=coeffType;


        [blockInfo.gainOptimMode,blockInfo.gainMode]=getHDLGainSetting(this);
    else
        filterKernelNet=pirelab.createNewNetwork(...
        'Network',topNet,...
        'Name','FIR2DKernel',...
        'InportNames',{'dataIn','vStartIn','vEndIn','hStartIn','hEndIn',...
        'validIn','processData','coeffIn'},...
        'InportTypes',[sigInfo.DataInvType,repmat(sigInfo.ctlType,1,6),sigInfo.coeffType],...
        'InportRates',repmat(sigInfo.inRate,1,8),...
        'OutportNames',{'dataOut','vStartOut','vEndOut','hStartOut','hEndOut','validOut'},...
        'OutportTypes',[sigInfo.DataOutType,repmat(sigInfo.ctlType,1,5)]...
        );
        coeffs=blockInfo.Coefficients;

    end


    inSig=filterKernelNet.PirInputSignals;
    outSig=filterKernelNet.PirOutputSignals;

    if blockInfo.coeffFromPort


        vStartIn=inSig(2);
        validIn=inSig(6);
        coeffIn=inSig(8);
        vStartValidSig=filterKernelNet.addSignal(sigInfo.ctlType,'LBvStartValid');
        pirelab.getLogicComp(filterKernelNet,[vStartIn,validIn],vStartValidSig,'and');
        coeffInReg=filterKernelNet.addSignal(sigInfo.coeffType,'coeffInReg');

        pirelab.getIntDelayEnabledComp(filterKernelNet,coeffIn,coeffInReg,vStartValidSig,1,'LBvStartValid');
        nonZeroCoeffs=fliplr(coeffs);
        nonZeroCoeffs=nonZeroCoeffs(:);
        nonZeroCoeffIndex=1:numel(coeffs);
    else

        coeffInReg=[];
        nonZeroCoeffIndex=(coeffs~=0);
        nonZeroCoeffs=coeffs(nonZeroCoeffIndex);

        if isempty(nonZeroCoeffs)


            pirelab.getConstComp(filterKernelNet,outSig(1),0,'zeroOut');

            for ii=2:numel(inSig)-1
                pirelab.getWireComp(filterKernelNet,inSig(ii),outSig(ii));
            end
            return;
        end
    end

    processIn=inSig(7);




    halfWidth=floor(blockInfo.KernelWidth/2);
    numMatrices=(ceil(halfWidth/double(blockInfo.NumberOfPixels)))*2+1;
    blockInfo.NumMatrices=numMatrices;

    for ii=1:1:numMatrices
        matrixDelay(ii)=filterKernelNet.addSignal2('Type',dataVType,'Name',['MatrixDelay',num2str(ii)]);%#ok<AGROW>
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
        kernelWindow(kk)=filterKernelNet.addSignal2('Type',filterKernelType,'Name',['KernelWindow',num2str(kk)]);%#ok<AGROW>
        pirelab.getConcatenateComp(filterKernelNet,columnArray(kk+evenKernel:blockInfo.KernelWidth+(kk-1+evenKernel)),kernelWindow(kk),'FilterKernelConcat','2');
    end


    if all(size(nonZeroCoeffs)==1)
        for jj=1:1:blockInfo.NumberOfPixels
            KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;%#ok<AGROW>
            for ii=1:1:blockInfo.KernelWidth
                KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;%#ok<AGROW>
                tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);%#ok<AGROW>
            end
            nonZeroTapOutSig(jj,:)=tapOutSig(jj,nonZeroCoeffIndex);%#ok<AGROW>
        end

        multPreDelay=2;
        multPostDelay=2;


        this.elabOneCoeffMultiplyMultipixel(filterKernelNet,nonZeroTapOutSig,...
        nonZeroCoeffs,coeffInReg,inSig,outSig,blockInfo,sigInfo,...
        multPreDelay,multPostDelay);
        return;
    end

    for jj=1:1:blockInfo.NumberOfPixels

        KernelWindowMatrixToVectorSplit(jj,:)=kernelWindow(jj).split.PirOutputSignals;%#ok<AGROW>
        for ii=1:1:blockInfo.KernelWidth
            KernelWindowVectorToScalarSplit(jj,ii,:)=KernelWindowMatrixToVectorSplit(jj,ii).split.PirOutputSignals;%#ok<AGROW>
            tapOutSig(jj,((ii-1)*blockInfo.KernelHeight)+1:ii*blockInfo.KernelHeight)=KernelWindowVectorToScalarSplit(jj,ii,:);%#ok<AGROW>
        end




        multPreDelay=2;
        multPostDelay=2;




        nonZeroTapOutSig(jj,:)=tapOutSig(jj,nonZeroCoeffIndex);%#ok<AGROW>




        totalLatency=floor(blockInfo.KernelWidth/2);

        if blockInfo.coeffFromPort
            coeffsUniqueAbsNonZero=nonZeroCoeffs;


            preAddOutSig(jj,:)=nonZeroTapOutSig(jj,:);%#ok<AGROW>
            totalPreAddLatency=0;
        else



            coeffsUniqueAbsNonZero=unique(abs(double(nonZeroCoeffs)));
            coeffsUniqueAbsNonZero=cast(coeffsUniqueAbsNonZero,'like',nonZeroCoeffs);











            [preAddOutSig(jj,:),preAddLatency,coeffsUniqueAbsNonZero]=this.elabFIRPreAdder(...
            filterKernelNet,coeffsUniqueAbsNonZero,nonZeroCoeffs,nonZeroTapOutSig(jj,:));%#ok<AGROW>

            [preAddOutSig(jj,:),totalPreAddLatency]=this.elabFIRPreAdderBalanceLatency(...
            filterKernelNet,preAddLatency,preAddOutSig(jj,:));%#ok<AGROW>






        end


        totalLatency=totalLatency+totalPreAddLatency;





        [multOutSig(jj,:),multLatency]=this.elabFIRGain(filterKernelNet,preAddOutSig(jj,:),...
        coeffsUniqueAbsNonZero,coeffInReg,multPreDelay,multPostDelay,blockInfo,sigInfo);%#ok<AGROW>


        totalLatency=totalLatency+multLatency;



        if numel(multOutSig(jj,:))==1
            fpFIROutSig(jj)=multOutSig(jj,:);%#ok<AGROW>
            addLatency=0;
        else
            sigNamePrefix='add';
            fpFIROutSig(jj)=this.elabAdderTree(filterKernelNet,multOutSig(jj,:),[],...
            sigNamePrefix);%#ok<AGROW> % signal names will be add_stage1_1 and so on...

            addLatency=ceil(log2(numel(multOutSig(jj,:))))+1;
        end


        totalLatency=totalLatency+addLatency;



    end

    firVecType=pirelab.getPirVectorType(fpFIROutSig(1).Type,[blockInfo.NumberOfPixels,1],1);

    fpFIROutSigVec=filterKernelNet.addSignal2('Type',firVecType,'Name','FilterOut');
    pirelab.getMuxComp(filterKernelNet,fpFIROutSig(:),fpFIROutSigVec);

    this.elabConnectMultiToOutput(filterKernelNet,[fpFIROutSigVec;inSig(2:end)],...
    totalLatency,blockInfo);

end


function[coeffs,coeffType]=getCoeffValueandType(blockInfo,sigInfo,hN)

    if blockInfo.CoefficientsDataType==1
        coeffType=sigInfo.DataInType.BaseType;
        coeffs=fi(blockInfo.Coefficients,coeffType.Signed,...
        coeffType.WordLength,-1*coeffType.FractionLength);
    else
        coeffs=fi(blockInfo.Coefficients,blockInfo.CustomCoefficientsDataType);
        coeffType=hN.getType('FixedPoint','Signed',coeffs.Signed,...
        'WordLength',coeffs.WordLength,...
        'FractionLength',-1*coeffs.FractionLength);
    end
end

function[gainOptimMode,gainMode]=getHDLGainSetting(this)

    gainMode=3;

    gainParam=getImplParams(this,'ConstMultiplierOptimization');
    gainOptimMode=0;
    if~isempty(gainParam)
        if strcmpi(gainParam,'none')
            gainOptimMode=0;
        elseif strcmpi(gainParam,'csd')
            gainOptimMode=1;
        elseif strcmpi(gainParam,'fcsd')
            gainOptimMode=2;
        elseif strcmpi(gainParam,'auto')
            gainOptimMode=3;
        end
    end
end
