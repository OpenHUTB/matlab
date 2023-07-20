function elaborateNRCRCEncoder(this,topNet,blockInfo,insignals,outsignals)







    ufix1Type=pir_ufixpt_t(1,0);
    y=24/blockInfo.dlen;
    ufixNType=pir_ufixpt_t(blockInfo.dlen,0);
    if blockInfo.Parallel
        mType=pirelab.getPirVectorType(ufixNType,y);
    else
        mType=pirelab.getPirVectorType(ufix1Type,24);
    end



    datain=insignals(1);
    startin=insignals(2);
    endin=insignals(3);
    validin=insignals(4);

    dataType=datain.Type;
    ctrlType=startin.Type;

    sof_vld=topNet.addSignal(ctrlType,'startVld');
    pirelab.getLogicComp(topNet,[startin,validin],sof_vld,'and');

    if strcmpi(blockInfo.CRCType,'CRC24C')

        if blockInfo.EnableCRCMaskPort

            finxorval=insignals(5);
            maskType=finxorval.Type;



            mask=topNet.addSignal(maskType,'crcMask');
            pirelab.getUnitDelayEnabledComp(topNet,finxorval,mask,sof_vld,'Sampling of mask',0);


            i=0;
            for idx=24:-1:1
                i=i+1;
                maskbit(i)=topNet.addSignal(ufix1Type,['maskBit_',num2str(i)]);%#ok<*AGROW>
                pirelab.getBitSliceComp(topNet,mask,maskbit(i),idx-1,idx-1,'extract maskbits');
            end
            crcmask=topNet.addSignal(mType,'maskBits');
            if blockInfo.Parallel
                for i=1:blockInfo.dlen:24
                    x=[];
                    for p=1:blockInfo.dlen
                        x=[x,maskbit(i+p-1)];
                    end
                    cmaskarr((i-1)/blockInfo.dlen+1)=topNet.addSignal(ufixNType,['cMaskArr_',num2str(idx)]);%#ok<*AGROW>
                    pirelab.getBitConcatComp(topNet,x,cmaskarr((i-1)/blockInfo.dlen+1),'bitConcat');
                end
                this.muxSignal(topNet,cmaskarr,crcmask);
            else
                this.muxSignal(topNet,maskbit,crcmask);
            end
        end
    end

    inRate=datain.SimulinkRate;


    dataout=outsignals(1);
    startout=outsignals(2);
    endout=outsignals(3);
    validout=outsignals(4);

    insig=[datain,startin,endin,validin];
    outsig=[dataout,startout,endout,validout];

    dataoutgen=topNet.addSignal(dataType,'dataOutGen');
    dataout1=topNet.addSignal(dataType,'dataOut1');
    dataout2=topNet.addSignal(dataType,'dataOut2');
    xordata=topNet.addSignal(dataType,'xorData');
    zero_data=topNet.addSignal(dataType,'zeroData');
    pirelab.getConstComp(topNet,zero_data,0);

    startoutgen=topNet.addSignal(ctrlType,'startOutGen');
    endoutgen=topNet.addSignal(ctrlType,'endOutGen');
    validoutgen=topNet.addSignal(ctrlType,'validOutGen');


    genNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenerator',...
    'InportNames',{'dataIn','startIn','endIn','validIn'},...
    'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[inRate,inRate,inRate,inRate],...
    'OutportNames',{'dataOut','startOut','endOut','validOut'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type]...
    );


    datain_gen=genNet.PirInputSignals(1);
    sofin_gen=genNet.PirInputSignals(2);
    eofin_gen=genNet.PirInputSignals(3);
    validin_gen=genNet.PirInputSignals(4);

    dataout_gen=genNet.PirOutputSignals(1);
    sofout_gen=genNet.PirOutputSignals(2);
    eofout_gen=genNet.PirOutputSignals(3);
    validout_gen=genNet.PirOutputSignals(4);

    insig=[datain_gen,sofin_gen,eofin_gen,validin_gen];
    outsig=[dataout_gen,sofout_gen,eofout_gen,validout_gen];


    this.elaborateCRCGen(genNet,blockInfo,insig,outsig,false);
    gcomp=pirelab.instantiateNetwork(topNet,genNet,[datain,startin,endin,validin],...
    [dataoutgen,startoutgen,endoutgen,validoutgen],'HDL CRC Generator');
    gcomp.addComment('HDL CRC Generator');

    if strcmpi(blockInfo.CRCType,'CRC24C')
        if blockInfo.EnableCRCMaskPort

            fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
            '+nrhdlsupport','+internal','@CRCEncoder','cgireml','maskControl.m'),'r');
            maskControl=fread(fid,Inf,'char=>char');
            fclose(fid);

            WL=log2(double(24/blockInfo.dlen)+3)+1;
            enbmask=topNet.addSignal(ctrlType,'dataMask');
            maskreg=topNet.addSignal(ufixNType,'maskReg');

            latency=blockInfo.latency;
            masklen=blockInfo.maskLen;

            topNet.addComponent2(...
            'kind','cgireml',...
            'Name','maskControl',...
            'InputSignals',[sof_vld,endin,validin,crcmask],...
            'OutputSignals',[enbmask,maskreg],...
            'ExternalSynchronousResetSignal','',...
            'EMLFileName','maskControl',...
            'EMLFileBody',maskControl,...
            'EmlParams',{latency,masklen,WL},...
            'EMLFlag_TreatInputIntsAsFixpt',true);

            if blockInfo.Scalar
                pirelab.getBitwiseOpComp(topNet,[dataoutgen,maskreg],xordata,'xor');
            else
                for idx=1:blockInfo.dlen
                    maskreg_arr(idx)=topNet.addSignal(ufix1Type,['maskRegArr_',num2str(idx)]);
                end
                for idx=1:blockInfo.dlen
                    pirelab.getBitSliceComp(topNet,maskreg,maskreg_arr(blockInfo.dlen-idx+1),idx-1,idx-1);
                end
                maskvec=topNet.addSignal(dataType,'maskVec');
                this.muxSignal(topNet,maskreg_arr,maskvec);

                pirelab.getLogicComp(topNet,[dataoutgen,maskvec],xordata,'xor');
            end
            pirelab.getSwitchComp(topNet,[xordata,dataoutgen],dataout1,enbmask,'sel','~=',0,'Floor','Wrap');
            pirelab.getSwitchComp(topNet,[dataout1,zero_data],dataout2,validoutgen,'sel','~=',0,'Floor','Wrap');

        else
            pirelab.getSwitchComp(topNet,[dataoutgen,zero_data],dataout2,validoutgen,'sel','~=',0,'Floor','Wrap');
        end
    else
        pirelab.getSwitchComp(topNet,[dataoutgen,zero_data],dataout2,validoutgen,'sel','~=',0,'Floor','Wrap');
    end

    pirelab.getIntDelayComp(topNet,dataout2,dataout,1,'dataReg',0);
    pirelab.getIntDelayComp(topNet,startoutgen,startout,1,'startReg',0);
    pirelab.getIntDelayComp(topNet,endoutgen,endout,1,'endReg',0);
    pirelab.getIntDelayComp(topNet,validoutgen,validout,1,'validReg',0);

end