function filterKernelNet=elabFIRFilterKernel(this,...
    topNet,blockInfo,sigInfo)
















    CbInName={'Cb'};
    CrInName={'Cr'};
    for ii=1:2*(blockInfo.padL)
        CbInName=[CbInName,{['CbDelay',num2str(ii)]}];%#ok
        CrInName=[CrInName,{['CrDelay',num2str(ii)]}];%#ok
    end

    filterKernelNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','FIRKernel',...
    'InportNames',[CbInName,CrInName,'YIn','hStartIn','hEndIn','vStartIn','vEndIn','validIn'],...
    'InportTypes',[repmat(sigInfo.DataInType,1,(1+2*blockInfo.padL)*2+1),repmat(sigInfo.ctlType,1,5)],...
    'InportRates',repmat(sigInfo.inRate,1,(1+2*blockInfo.padL)*2+6),...
    'OutportNames',{'CbOut','CrOut','YOut','hStartOut','hEndOut','vStartout','vEndOut','validOut'},...
    'OutportTypes',[repmat(sigInfo.DataOutType,1,3),repmat(sigInfo.ctlType,1,5)]...
    );




    sigInfo.coeffType=filterKernelNet.getType('FixedPoint','Signed',blockInfo.coeffs.Signed,...
    'WordLength',blockInfo.coeffs.WordLength,...
    'FractionLength',-1*blockInfo.coeffs.FractionLength);





    inSig=filterKernelNet.PirInputSignals;
    outSig=filterKernelNet.PirOutputSignals;
    outSig(1).SimulinkRate=sigInfo.inRate;
    outSig(2).SimulinkRate=sigInfo.inRate;



    nonZeroCoeffIndex=(blockInfo.coeffs~=0);
    nonZeroCoeffs=blockInfo.coeffs(nonZeroCoeffIndex);

    if isempty(nonZeroCoeffs)


        pirelab.getConstComp(filterKernelNet,outSig(1),0,'CbZeroOut');
        pirelab.getConstComp(filterKernelNet,outSig(2),0,'CrZeroOut');

        for ii=3:numel(outSig)
            pirelab.getWireComp(filterKernelNet,inSig(ii+2*(numel(blockInfo.coeffs))-2),outSig(ii));
        end
        return;
    end







    multPreDelay=2;
    multPostDelay=2;


    sizeNonZeroCoeffs=size(nonZeroCoeffs);




    CbnonZeroTapOutSig=inSig(nonZeroCoeffIndex);
    CrnonZeroTapOutSig=inSig([false(1,numel(blockInfo.coeffs)),nonZeroCoeffIndex]);


    if all(sizeNonZeroCoeffs==1)

        this.elabOneCoeffMultiply(filterKernelNet,CbnonZeroTapOutSig,CrnonZeroTapOutSig,...
        nonZeroCoeffs,inSig,outSig,blockInfo,sigInfo,...
        multPreDelay,multPostDelay);
        return;
    end




    totalLatency=0;




    coeffsUniqueAbsNonZero=unique(abs(double(nonZeroCoeffs)));
    coeffsUniqueAbsNonZero=cast(coeffsUniqueAbsNonZero,'like',nonZeroCoeffs);












    [CbpreAddOutSig,CrpreAddOutSig,preAddLatency,coeffsUniqueAbsNonZero]=this.elabFIRPreAdder(...
    filterKernelNet,coeffsUniqueAbsNonZero,nonZeroCoeffs,CbnonZeroTapOutSig,CrnonZeroTapOutSig);


    [CbpreAddOutSig,CrpreAddOutSig,totalPreAddLatency]=this.elabFIRPreAdderBalanceLatency(...
    filterKernelNet,preAddLatency,CbpreAddOutSig,CrpreAddOutSig);








    totalLatency=totalLatency+totalPreAddLatency;





    [CbmultOutSig,CrmultOutSig,multLatency]=this.elabFIRGain(filterKernelNet,CbpreAddOutSig,CrpreAddOutSig,...
    coeffsUniqueAbsNonZero,multPreDelay,multPostDelay,blockInfo,sigInfo);


    totalLatency=totalLatency+multLatency;



    if numel(CbmultOutSig)==1
        CbfpFIROutSig=CbmultOutSig;
        CrfpFIROutSig=CrmultOutSig;
        addLatency=0;
    else
        sigNamePrefix='add';
        CbfpFIROutSig=this.elabAdderTree(filterKernelNet,CbmultOutSig,[],...
        sigNamePrefix,'PostAdder (along Cb data path)');


        CrfpFIROutSig=this.elabAdderTree(filterKernelNet,CrmultOutSig,[],...
        sigNamePrefix,'PostAdder (along Cr data path)');


        addLatency=ceil(log2(numel(CbmultOutSig)))+1;
    end


    totalLatency=totalLatency+addLatency;



    this.elabConnectToOutput(filterKernelNet,[CbfpFIROutSig;CrfpFIROutSig;inSig((1+2*blockInfo.padL)*2+1:end)],...
    totalLatency,blockInfo);

end
