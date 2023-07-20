function[CbpreAddOutSig,CrpreAddOutSig,totalPreAddLatency]=elabFIRPreAdderBalanceLatency(...
    this,filterKernelNet,preAddLatency,CbpreAddOutSig,CrpreAddOutSig)%#ok<INUSL>





    totalPreAddLatency=max(preAddLatency);


    if~all(preAddLatency==preAddLatency(1))

        for ii=1:numel(preAddLatency)
            if~(preAddLatency(ii)==totalPreAddLatency)

                extraLatency=totalPreAddLatency-preAddLatency(ii);
                CbcompName=['CbpreAdd',num2str(ii),'_balance'];
                CbsigName=[CbcompName,'_reg'];
                CbsigType=CbpreAddOutSig(ii).Type;
                CbsigOut=filterKernelNet.addSignal(CbsigType,CbsigName);
                pirelab.getIntDelayComp(filterKernelNet,CbpreAddOutSig(ii),...
                CbsigOut,extraLatency,CbcompName);
                CbpreAddOutSig(ii)=CbsigOut;

                CrcompName=['CrpreAdd',num2str(ii),'_balance'];
                CrsigName=[CrcompName,'_reg'];
                CrsigType=CrpreAddOutSig(ii).Type;
                CrsigOut=filterKernelNet.addSignal(CrsigType,CrsigName);
                pirelab.getIntDelayComp(filterKernelNet,CrpreAddOutSig(ii),...
                CrsigOut,extraLatency,CrcompName);
                CrpreAddOutSig(ii)=CrsigOut;
            end
        end
    end

end
