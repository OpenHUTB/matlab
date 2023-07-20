function BMetNet=elabBMet(this,topNet,blockInfo)






    inTop=topNet.PirInputSignals(1);



    BMoutWL=blockInfo.nsDec+blockInfo.n-1;
    BMoutType=pir_ufixpt_t(BMoutWL,0);
    t=blockInfo.trellis;
    BMvType=pirelab.getPirVectorType(BMoutType,t.numOutputSymbols);


    BMetNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','BranchMetric',...
    'InportNames',{'din'},...
    'InportTypes',inTop.Type,...
    'InportRates',inTop.SimulinkRate,...
    'OutportNames',{'bMet'},...
    'OutportTypes',BMvType);


    din=BMetNet.PirInputSignals(1);
    bmout=BMetNet.PirOutputSignals(1);


    [indim,hBT]=pirelab.getVectorTypeInfo(din);
    dins=demuxSignal(this,BMetNet,din,'din_entry');





    nsDecmax=BMetNet.addSignal(hBT,'nsDecmax');
    maxValue=realmax(fi(0,0,blockInfo.nsDec,0));
    constcomp=pirelab.getConstComp(BMetNet,nsDecmax,maxValue);
    constcomp.addComment('Max value of nsDec data type');



    for i=1:indim

        weights(i)=BMetNet.addSignal(hBT,['maxsubin',num2str(i)]);
        if(blockInfo.nsDec>1)
            pirelab.getSubComp(BMetNet,[nsDecmax,dins(i)],weights(i),'Floor','Wrap');
        else
            pirelab.getBitwiseOpComp(BMetNet,[nsDecmax,dins(i)],weights(i),'XOR');
        end

    end



    [outdim,outBT]=pirelab.getVectorTypeInfo(bmout);
    n=blockInfo.n;
    bmmuxin=[];
    for idx=1:outdim

        tbmout(idx)=BMetNet.addSignal(outBT,['bMet_entry',num2str(idx)]);
        tmpIdx=idx-1;
        adderIns=[];
        for idx2=1:n
            inIdx=n-idx2+1;
            if(rem(tmpIdx,2))
                adderIns=[adderIns,weights(inIdx)];

            else

                adderIns=[adderIns,dins(inIdx)];
            end
            tmpIdx=floor(tmpIdx/2);
        end




        if(n==2)

            pirelab.getAddComp(BMetNet,adderIns,tbmout(idx),'Floor','Wrap','BMet adders');
            bmmuxin=[bmmuxin,tbmout(idx)];
        else

            pirelab.getTreeArch(BMetNet,adderIns,tbmout(idx),'sum','Floor','Wrap','BMet adders');

            pipedepth=ceil(log2(n))-1;
            dtbmout(idx)=BMetNet.addSignal(outBT,['dbMet_entry',num2str(idx)]);
            pirelab.getIntDelayComp(BMetNet,tbmout(idx),dtbmout(idx),pipedepth,'adderpipelineRegister');
            bmmuxin=[bmmuxin,dtbmout(idx)];
        end
    end


    if(n==2)
        this.muxSignal(BMetNet,tbmout,bmout);
    else
        this.muxSignal(BMetNet,dtbmout,bmout);
    end

end
