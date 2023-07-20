function[multOutDlySig,multLatency]=elabFIRGain(this,filterKernelNet,...
    preAddOutSig,coeffs,coeffIn,multPreDelay,multPostDelay,blockInfo,...
    sigInfo)%#ok<INUSL>









    if~blockInfo.coeffFromPort
        mult2Type=sigInfo.coeffType;
        mult2size=[mult2Type.WordLength,mult2Type.FractionLength,mult2Type.Signed];
        numCoeffs=numel(coeffs);
    else
        mult2size=hdlsignalsizes(coeffIn);
        mult2size(2)=-1*mult2size(2);

        st=hdlissignaltype(coeffIn,'all');
        if st.isscalar
            coeffInSig=coeffIn;
        elseif st.isvector
            coeffInSig=coeffIn.split.PirOutputSignals;
        elseif st.ismatrix
            cvec=coeffIn.split.PIROutputSignals;
            coeffInSig=[];
            for ii=1:numel(cvec)
                coeffInSig=[coeffInSig,cvec(ii).split.PIROutputSignals(end:-1:1)];%#ok<AGROW>
            end
        end

        coeffInSigType=coeffInSig(1).Type;
        numCoeffs=numel(coeffInSig);
    end


    for ii=1:numCoeffs


        inSig=preAddOutSig(ii);
        if~hdlsignalisdouble(inSig)
            mult1Type=inSig.Type;
            multWL=mult1Type.WordLength+mult2size(1);
            multFL=mult1Type.FractionLength+mult2size(2);
            multS=any([mult1Type.Signed,mult2size(3)]==1);
            multType=filterKernelNet.getType('FixedPoint','Signed',multS,...
            'WordLength',multWL,'FractionLength',multFL);
        else
            multType=inSig.Type;
        end




        inDlySig=filterKernelNet.addSignal(mult1Type,['multInReg',num2str(ii)]);
        pirelab.getIntDelayComp(filterKernelNet,inSig,inDlySig,...
        multPreDelay,['multInDelay',num2str(ii)]);
        multOutSig=filterKernelNet.addSignal(multType,['multOut',num2str(ii)]);

        if blockInfo.coeffFromPort

            coeffDlySig=filterKernelNet.addSignal(coeffInSigType,['coeffMultInReg',num2str(ii)]);
            pirelab.getIntDelayComp(filterKernelNet,coeffInSig(ii),coeffDlySig,...
            multPreDelay,'multCoeffInDelay');

            pirelab.getMulComp(filterKernelNet,[inDlySig,coeffDlySig],multOutSig);
        else

            pirelab.getGainComp(filterKernelNet,inDlySig,multOutSig,coeffs(ii),...
            blockInfo.gainMode,blockInfo.gainOptimMode);
        end


        multOutDlySig(ii)=filterKernelNet.addSignal(multType,...
        ['multOutReg',num2str(ii)]);%#ok<AGROW>
        pirelab.getIntDelayComp(filterKernelNet,multOutSig,multOutDlySig(ii),...
        multPostDelay,['multOutDelay',num2str(ii)]);
    end


    multLatency=4;

end
