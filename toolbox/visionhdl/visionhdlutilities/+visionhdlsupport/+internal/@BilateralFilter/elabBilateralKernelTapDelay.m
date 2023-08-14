function tapOutSig=elabBilateralKernelTapDelay(this,filterKernelNet,...
    inSig,blockInfo,sigInfo)%#ok<INUSL>






    tapInData=inSig(1).split;
    tapValidIn=inSig(7);
    tapOutvType=pirelab.getPirVectorType(sigInfo.DataInType,blockInfo.KernelWidth);
    tapDelayOrder=true;
    includeCurrent=true;
    booleanT=pir_boolean_t();




    for ii=1:blockInfo.KernelHeight
        iiStr=num2str(ii);

        tapOutSigVec(ii)=filterKernelNet.addSignal(tapOutvType,...
        ['tapOutData_',iiStr]);%#ok<AGROW>


        pirelab.getTapDelayEnabledComp(filterKernelNet,...
        tapInData.PirOutputSignals(ii),tapOutSigVec(ii),tapValidIn,...
        blockInfo.KernelWidth-1,['tapDelay_',iiStr],0,tapDelayOrder,...
        includeCurrent);




        tapOutSigSplit=tapOutSigVec(ii).split;
        for jj=1:numel(tapOutSigSplit.PirOutputSignals)

            tapOutSig(ii,jj)=tapOutSigSplit.PirOutputSignals(jj);%#ok<AGROW>
        end
    end

end
