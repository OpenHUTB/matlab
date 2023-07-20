function cmpNet=elabCRCCompare(~,topNet,blockInfo,inRate)




    ufix1Type=pir_ufixpt_t(1,0);


    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    tpinfo=blockInfo.tpinfo;
    ratio=round(clen/dlen);

    datain=topNet.PirInputSignals(1);
    dataType=datain.Type;

    inportnames={'dataRef','endIn','dataOutgen','startOutgen','endOutgen','validOutgen'};
    inporttypes=[dataType,ufix1Type,dataType,ufix1Type,ufix1Type,ufix1Type];
    inportrates=inRate*ones(1,6);

    if(ratio==1)
        cntval=2*clen/dlen-1;
    else
        cntval=clen/dlen-1;
        inportnames=[inportnames,{'outputCRC'}];
        inporttypes=[inporttypes,ufix1Type];
        inportrates=[inportrates,inRate];
    end

    cntWL=floor(log2(double(cntval)))+1;
    cntType=pir_ufixpt_t(cntWL,0);



    cmpNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCCompare',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'dataOut','startOut','endOut','validOut','err'},...
    'OutportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type,ufix1Type]...
    );
    cmpNet.addComment('Checksum Comparison');


    dataref=cmpNet.PirInputSignals(1);
    endin=cmpNet.PirInputSignals(2);
    dataoutgen=cmpNet.PirInputSignals(3);
    startoutgen=cmpNet.PirInputSignals(4);
    endoutgen=cmpNet.PirInputSignals(5);
    validoutgen=cmpNet.PirInputSignals(6);

    dataout=cmpNet.PirOutputSignals(1);
    startout=cmpNet.PirOutputSignals(2);
    endout=cmpNet.PirOutputSignals(3);
    validout=cmpNet.PirOutputSignals(4);
    err=cmpNet.PirOutputSignals(5);



    cnt1out=cmpNet.addSignal(cntType,'cnt1out');
    cnt1rst=cmpNet.addSignal(ufix1Type,'cnt1rst');
    pirelab.getCounterComp(cmpNet,[cnt1rst,endin],cnt1out,...
    'Count limited',0,1,cntval,1,0,1,0);
    checksumreg=cmpNet.addSignal(dataType,'checksumreg');


    if(ratio==1)

        pirelab.getCompareToValueComp(cmpNet,cnt1out,cnt1rst,'==',1);

        comp=pirelab.getUnitDelayEnabledComp(cmpNet,dataref,checksumreg,cnt1rst,'inputchecksumck_register',0,'','',1);
        comp.addComment('Buffer input Checksum');
        outdataSel=endoutgen;

    else

        outputCRC=cmpNet.addSignal(ufix1Type,'outputCRC');
        comp=pirelab.getUnitDelayComp(cmpNet,cmpNet.PirInputSignals(7),outputCRC,'outputCRC_register',0);
        comp.addComment('Buffer Checksum output control signal');

        outdataSel=outputCRC;

        cnt2enb=cmpNet.addSignal(ufix1Type,'cnt2enb');
        comp=pirelab.getCompareToValueComp(cmpNet,cnt1out,cnt2enb,'>=',1);
        comp.addComment('Generate Checksum buffer enable');

        cnt2out=cmpNet.addSignal(cntType,'cnt2out');

        pirelab.getCounterComp(cmpNet,[cnt1rst,cnt2enb],cnt2out,...
        'Count limited',0,1,cntval,1,0,1,0);
        pirelab.getCompareToValueComp(cmpNet,cnt2out,cnt1rst,'==',cntval);

        bufferenb=cmpNet.addSignal(ufix1Type,'bufferenb');
        pirelab.getLogicComp(cmpNet,[cnt2enb,outputCRC],bufferenb,'or');

        [~,clkEnb,~]=cmpNet.getClockBundle(dataref,1,1,0);



        delayComp=pirelab.getIntDelayEnabledComp(cmpNet,dataref,checksumreg,[clkEnb,bufferenb],...
        ratio,'',0,0);
        delayComp.addComment(' Buffer input Checksum');


    end

    isequal=cmpNet.addSignal(ufix1Type,'isequal');

    if tpinfo.isscalar&&dlen~=1
        comp=pirelab.getRelOpComp(cmpNet,[dataoutgen,checksumreg],isequal,'~=');
    else

        xorcrc=cmpNet.addSignal(dataType,'xorchecksums');
        comp=pirelab.getRelOpComp(cmpNet,[dataoutgen,checksumreg],xorcrc,'~=');
        pirelab.getBitwiseOpComp(cmpNet,xorcrc,isequal,'OR');
    end
    comp.addComment('Compare Checksum');

    const0=cmpNet.addSignal(ufix1Type,'const0ctl');
    pirelab.getConstComp(cmpNet,const0,0);

    if(ratio==1)
        pirelab.getSwitchComp(cmpNet,[isequal,const0],err,outdataSel,'','~=',0);
    else
        cmpresult=cmpNet.addSignal(ufix1Type,'cmpresult');
        pirelab.getSwitchComp(cmpNet,[isequal,const0],cmpresult,outdataSel,'','~=',0);

        numErr=cmpNet.addSignal(cntType,'numerr');
        totalErr=cmpNet.addSignal(cntType,'totalerr');
        dtotalErr=cmpNet.addSignal(cntType,'dtotalerr');
        const0cnt=cmpNet.addSignal(cntType,'const0cnt');
        pirelab.getConstComp(cmpNet,const0cnt,0);

        acomp=pirelab.getAddComp(cmpNet,[cmpresult,dtotalErr],numErr,'Floor','Saturate');
        acomp.addComment('Count number of errors');
        pirelab.getSwitchComp(cmpNet,[const0cnt,numErr],totalErr,endoutgen,'','~=',0);
        pirelab.getUnitDelayComp(cmpNet,totalErr,dtotalErr,'totalErr_register',0);

        hasErr=cmpNet.addSignal(ufix1Type,'hadErr');
        comp=pirelab.getCompareToValueComp(cmpNet,numErr,hasErr,'>',0);
        comp.addComment(' Detectot error');
        pirelab.getSwitchComp(cmpNet,[hasErr,const0],err,endoutgen,'','~=',0);


    end




    const0data=cmpNet.addSignal(dataType,'const0data');
    comp=pirelab.getConstComp(cmpNet,const0data,0);
    comp.addComment('Constant 0');

    tdataout=cmpNet.addSignal(dataType,'tdataout');
    comp=pirelab.getSwitchComp(cmpNet,[const0data,dataoutgen],tdataout,outdataSel,'','~=',0);
    comp.addComment('Data output');
    pirelab.getIntDelayComp(cmpNet,tdataout,dataout,ratio,'dataout_delay_register',0);


    comp=pirelab.getIntDelayComp(cmpNet,startoutgen,startout,ratio,'startout_delay_register',0);
    comp.addComment('startOut');


    comp=pirelab.getDTCComp(cmpNet,endoutgen,endout,'floor','Wrap');
    comp.addComment('endOut');


    tvalidout=cmpNet.addSignal(ufix1Type,'tvalidout');
    comp=pirelab.getSwitchComp(cmpNet,[const0,validoutgen],tvalidout,outdataSel,'','~=',0);
    pirelab.getIntDelayComp(cmpNet,tvalidout,validout,ratio,'validout_delay_register',0);
    comp.addComment('validOut');
end
