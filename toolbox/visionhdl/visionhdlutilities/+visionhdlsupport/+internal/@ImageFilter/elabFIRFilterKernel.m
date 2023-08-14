function filterKernelNet=elabFIRFilterKernel(this,...
    topNet,blockInfo,sigInfo)
















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



    tapOutSig=this.elabFIRKernelTapDelay(filterKernelNet,...
    inSig,blockInfo,sigInfo);


    multPreDelay=2;
    multPostDelay=2;


    sizeNonZeroCoeffs=size(nonZeroCoeffs);




    nonZeroTapOutSig=tapOutSig(nonZeroCoeffIndex);


    if all(sizeNonZeroCoeffs==1)


        this.elabOneCoeffMultiply(filterKernelNet,nonZeroTapOutSig,...
        nonZeroCoeffs,coeffInReg,inSig,outSig,blockInfo,sigInfo,...
        multPreDelay,multPostDelay);
        return;
    end




    totalLatency=floor(blockInfo.KernelWidth/2);

    if blockInfo.coeffFromPort
        coeffsUniqueAbsNonZero=nonZeroCoeffs;


        preAddOutSig=nonZeroTapOutSig;
        totalPreAddLatency=0;
    else



        coeffsUniqueAbsNonZero=unique(abs(double(nonZeroCoeffs)));
        coeffsUniqueAbsNonZero=cast(coeffsUniqueAbsNonZero,'like',nonZeroCoeffs);











        [preAddOutSig,preAddLatency,coeffsUniqueAbsNonZero]=this.elabFIRPreAdder(...
        filterKernelNet,coeffsUniqueAbsNonZero,nonZeroCoeffs,nonZeroTapOutSig);

        [preAddOutSig,totalPreAddLatency]=this.elabFIRPreAdderBalanceLatency(...
        filterKernelNet,preAddLatency,preAddOutSig);






    end


    totalLatency=totalLatency+totalPreAddLatency;





    [multOutSig,multLatency]=this.elabFIRGain(filterKernelNet,preAddOutSig,...
    coeffsUniqueAbsNonZero,coeffInReg,multPreDelay,multPostDelay,blockInfo,sigInfo);


    totalLatency=totalLatency+multLatency;



    if numel(multOutSig)==1
        fpFIROutSig=multOutSig;
        addLatency=0;
    else
        sigNamePrefix='add';
        fpFIROutSig=this.elabAdderTree(filterKernelNet,multOutSig,[],...
        sigNamePrefix);

        addLatency=ceil(log2(numel(multOutSig)))+1;
    end


    totalLatency=totalLatency+addLatency;



    this.elabConnectToOutput(filterKernelNet,[fpFIROutSig;inSig(2:end)],...
    totalLatency,blockInfo);
end

function[coeffs,coeffType]=getCoeffValueandType(blockInfo,sigInfo,hN)

    if blockInfo.CoefficientsDataType==1
        coeffType=sigInfo.DataInType;
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

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
