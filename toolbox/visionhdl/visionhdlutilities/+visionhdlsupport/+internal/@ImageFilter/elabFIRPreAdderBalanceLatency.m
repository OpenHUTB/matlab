function[preAddOutSig,totalPreAddLatency]=elabFIRPreAdderBalanceLatency(...
    this,filterKernelNet,preAddLatency,preAddOutSig)%#ok<INUSL>





    totalPreAddLatency=max(preAddLatency);


    if~all(preAddLatency==preAddLatency(1))

        for ii=1:numel(preAddLatency)
            if~(preAddLatency(ii)==totalPreAddLatency)

                extraLatency=totalPreAddLatency-preAddLatency(ii);
                compName=['preAdd',num2str(ii),'_balance'];
                sigName=[compName,'_reg'];
                sigType=preAddOutSig(ii).Type;
                sigOut=filterKernelNet.addSignal(sigType,sigName);
                pirelab.getIntDelayComp(filterKernelNet,preAddOutSig(ii),...
                sigOut,extraLatency,compName);
                preAddOutSig(ii)=sigOut;
            end
        end
    end

end
