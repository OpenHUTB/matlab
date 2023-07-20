function ramtbNet=elabRAMTracebackUnit(this,topNet,blockInfo,dataRate)




    ufix1Type=pir_ufixpt_t(1,0);
    ramWL=blockInfo.ramWL;
    idxWL=blockInfo.idxWL;
    ramType=pir_ufixpt_t(ramWL,0);
    idxType=pir_ufixpt_t(idxWL,0);
    addrType=pir_ufixpt_t(blockInfo.addrWL,0);


    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ResetPort)
            if(blockInfo.ConstraintLength==9)
                ramtbinsignals={'decBitsL','decBitsH','minValid','minStateIdx','contrst'};
                ramtbintypes=[ramType,ramType,ufix1Type,idxType,ufix1Type];
                ramtbinrates=[dataRate,dataRate,dataRate,dataRate,dataRate];
            else
                ramtbinsignals={'decBits','minValid','minStateIdx','contrst'};
                ramtbintypes=[ramType,ufix1Type,idxType,ufix1Type];
                ramtbinrates=[dataRate,dataRate,dataRate,dataRate];
            end
        else
            if(blockInfo.ConstraintLength==9)
                ramtbinsignals={'decBitsL','decBitsH','minValid','minStateIdx'};
                ramtbintypes=[ramType,ramType,ufix1Type,idxType];
                ramtbinrates=[dataRate,dataRate,dataRate,dataRate];
            else
                ramtbinsignals={'decBits','minValid','minStateIdx'};
                ramtbintypes=[ramType,ufix1Type,idxType];
                ramtbinrates=[dataRate,dataRate,dataRate];
            end
        end
        ramtboutsignals={'decodeBit','lifoValid'};
        ramtbouttypes=[ufix1Type,ufix1Type];
    else
        if(blockInfo.ConstraintLength==9)
            ramtbinsignals={'decBitsL','decBitsH','minValid','minStateIdx'};
            ramtbintypes=[ramType,ramType,ufix1Type,idxType];
            ramtbinrates=[dataRate,dataRate,dataRate,dataRate];
        else
            ramtbinsignals={'decBits','minValid','minStateIdx'};
            ramtbintypes=[ramType,ufix1Type,idxType];
            ramtbinrates=[dataRate,dataRate,dataRate];
        end
        ramtboutsignals={'decodeBit','lifoValid'};
        ramtbouttypes=[ufix1Type,ufix1Type];
    end


    ramtbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','RAMTracebackUnit',...
    'Inportnames',ramtbinsignals,...
    'InportTypes',ramtbintypes,...
    'InportRates',ramtbinrates,...
    'Outportnames',ramtboutsignals,...
    'OutportTypes',ramtbouttypes...
    );

    if(blockInfo.ConstraintLength==9)
        dataL=ramtbNet.PirInputSignals(1);
        dataH=ramtbNet.PirInputSignals(2);
        idx=3;
    else
        data=ramtbNet.PirInputSignals(1);
        idx=2;
    end
    enb=ramtbNet.PirInputSignals(idx);
    minindx=ramtbNet.PirInputSignals(idx+1);

    if(strcmpi(blockInfo.OperationMode,'Continuous'))
        if(blockInfo.ResetPort)
            rst=ramtbNet.PirInputSignals(idx+2);
        end
        decodedout=ramtbNet.PirOutputSignals(1);
        validout=ramtbNet.PirOutputSignals(2);
    else
        decodedout=ramtbNet.PirOutputSignals(1);
        validout=ramtbNet.PirOutputSignals(2);
    end

    wr_addrs=ramtbNet.addSignal(addrType,'wr_addrs');
    rd_addrs=ramtbNet.addSignal(addrType,'tb_addrs');
    addr_valid=ramtbNet.addSignal(ufix1Type,'addr_valid');
    addrunitout=[wr_addrs,addr_valid,rd_addrs];

    if(blockInfo.ResetPort)
        tbdelay=3;
        lifodelay=1;
        addrunitin=[enb,rst];

        tbrst=ramtbNet.addSignal(ufix1Type,'tbrst');
        liforst=ramtbNet.addSignal(ufix1Type,'liforst');

        tbrcomp=pirelab.getIntDelayComp(ramtbNet,rst,tbrst,tbdelay,'tb_rst',0);
        tbrcomp.addComment('Delaying Reset Signal for Traceback Unit');

        lrcomp=pirelab.getIntDelayComp(ramtbNet,tbrst,liforst,lifodelay,'lifo_rst',0);
        lrcomp.addComment('Delaying Reset Signal for LIFO Unit');
    else
        addrunitin=enb;
    end


    addrNet=this.elabAddressGenerator(ramtbNet,blockInfo,dataRate);



    acomp=pirelab.instantiateNetwork(ramtbNet,addrNet,addrunitin,...
    addrunitout,'AddrsUnitTop_inst');
    acomp.addComment('Instantiation of Address Generation Unit');

    minindxd=ramtbNet.addSignal(idxType,'minIndxd');
    mindelay=3;
    mcomp=pirelab.getIntDelayComp(ramtbNet,minindx,minindxd,mindelay,'minIndx_d',0);
    mcomp.addComment('Delaying MinIndex Signal for TB Unit');

    if(blockInfo.ConstraintLength==9)
        dataLreg=ramtbNet.addSignal(ramType,'dataLreg');
        dataHreg=ramtbNet.addSignal(ramType,'dataHreg');

        ddcomp1=pirelab.getUnitDelayComp(ramtbNet,dataL,dataLreg,'dataL_reg',0);
        ddcomp1.addComment('Delaying dataL Signal ');

        ddcomp2=pirelab.getUnitDelayComp(ramtbNet,dataH,dataHreg,'dataH_reg',0);
        ddcomp2.addComment('Delaying dataH Signal ');

        decdataL=ramtbNet.addSignal(ramType,'decdataL');
        decdataH=ramtbNet.addSignal(ramType,'decdataH');
        tbdataL=ramtbNet.addSignal(ramType,'tbdataL');
        tbdataH=ramtbNet.addSignal(ramType,'tbdataH');

        decdataL_tmp=ramtbNet.addSignal(ramType,'decdataL_tmp');
        decdataH_tmp=ramtbNet.addSignal(ramType,'decdataH_tmp');
        tbdataL_tmp=ramtbNet.addSignal(ramType,'tbdataL_tmp');
        tbdataH_tmp=ramtbNet.addSignal(ramType,'tbdataH_tmp');


        ramcomp1=pirelab.getDualPortRamComp(ramtbNet,[dataLreg,addrunitout],[decdataL_tmp,tbdataL_tmp],...
        'Traceback_RAM_L',1,0);
        ramcomp1.addComment('Dualport RAM instantiation for lower part of data');
        ramcomp2=pirelab.getDualPortRamComp(ramtbNet,[dataHreg,addrunitout],[decdataH_tmp,tbdataH_tmp],...
        'Traceback_RAM_H',1,0);
        ramcomp2.addComment('Dualport RAM instantiation for upper part of data');


        rdcomp1=pirelab.getUnitDelayComp(ramtbNet,decdataL_tmp,decdataL,'decdataL_reg',0);
        pirelab.getUnitDelayComp(ramtbNet,tbdataL_tmp,tbdataL,'tbdataL_reg',0);
        rdcomp2=pirelab.getUnitDelayComp(ramtbNet,decdataH_tmp,decdataH,'decdataH_reg',0);
        pirelab.getUnitDelayComp(ramtbNet,tbdataH_tmp,tbdataH,'tbdataH_reg',0);
        rdcomp1.addComment('decdataL and tbdataL reg');
        rdcomp2.addComment('decdataH and tbdataH reg');
    else
        datareg=ramtbNet.addSignal(ramType,'datareg');
        ddcomp=pirelab.getUnitDelayComp(ramtbNet,data,datareg,'data_reg',0);
        ddcomp.addComment('Delaying data Signal ');

        decdata=ramtbNet.addSignal(ramType,'decdata');
        tbdata=ramtbNet.addSignal(ramType,'tbdata');

        decdata_temp=ramtbNet.addSignal(ramType,'decdata_temp');
        tbdata_temp=ramtbNet.addSignal(ramType,'tbdata_temp');

        ramcomp=pirelab.getDualPortRamComp(ramtbNet,[datareg,addrunitout],[decdata_temp,tbdata_temp],...
        'Traceback_RAM',1,0);
        ramcomp.addComment('Dualport RAM instantiation of data');
        rdcomp1=pirelab.getUnitDelayComp(ramtbNet,decdata_temp,decdata,'decdata_reg',0);
        pirelab.getUnitDelayComp(ramtbNet,tbdata_temp,tbdata,'tbdata_reg',0);
        rdcomp1.addComment('decdata and tbdata reg');
    end

    ram_valid=ramtbNet.addSignal(ufix1Type,'ram_valid');
    ramdelay=2;
    pirelab.getIntDelayComp(ramtbNet,addr_valid,ram_valid,ramdelay,'ram_data_valid',0);


    tbout=ramtbNet.addSignal(ufix1Type,'tbout');
    tbvalid=ramtbNet.addSignal(ufix1Type,'tbvalid');
    tbunitout=[tbout,tbvalid];

    if(blockInfo.ResetPort)
        if(blockInfo.ConstraintLength==9)
            tbunitin=[tbdataL,tbdataH,decdataL,decdataH,minindxd,ram_valid,tbrst];
        else
            tbunitin=[tbdata,decdata,minindxd,ram_valid,tbrst];
        end
        lifounitin=[tbunitout,liforst];
    else
        if(blockInfo.ConstraintLength==9)
            tbunitin=[tbdataL,tbdataH,decdataL,decdataH,minindxd,ram_valid];
        else
            tbunitin=[tbdata,decdata,minindxd,ram_valid];
        end
        lifounitin=tbunitout;
    end


    if(blockInfo.ConstraintLength==9)
        tbNet=this.elabTracebackEngine9(ramtbNet,blockInfo,dataRate);
    else
        tbNet=this.elabTracebackEngine(ramtbNet,blockInfo,dataRate);
    end



    tbcomp=pirelab.instantiateNetwork(ramtbNet,tbNet,tbunitin,...
    tbunitout,'TracebackUnitTop_inst');
    tbcomp.addComment('TracebackUnit unit instance');



    dectmp=ramtbNet.addSignal(ufix1Type,'dectmp');
    valtmp=ramtbNet.addSignal(ufix1Type,'validtmp');
    lifounitout=[dectmp,valtmp];


    LIFONet=this.elabLIFORAMEngine(ramtbNet,blockInfo,dataRate);



    lifocomp=pirelab.instantiateNetwork(ramtbNet,LIFONet,lifounitin,...
    lifounitout,'LIFOUnitTop_inst');
    lifocomp.addComment('LIFO unit instantiation');

    pirelab.getWireComp(ramtbNet,dectmp,decodedout);

    pirelab.getWireComp(ramtbNet,valtmp,validout);
end
