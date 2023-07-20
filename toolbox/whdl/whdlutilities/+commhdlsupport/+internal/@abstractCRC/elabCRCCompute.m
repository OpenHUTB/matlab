function cptNet=elabCRCCompute(this,topNet,blockInfo,inRate)




    ufix1Type=pir_ufixpt_t(1,0);


    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    if(clen==dlen)
        cntval=2*clen/dlen-1;
    else
        cntval=clen/dlen-1;
    end
    cntWL=floor(log2(double(cntval)))+1;
    cntType=pir_ufixpt_t(cntWL,0);

    dataType=pirelab.getPirVectorType(ufix1Type,dlen);
    crcType=pirelab.getPirVectorType(ufix1Type,clen);


    cptNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenCompute',...
    'InportNames',{'datainReg','validIn','processMsg','padZero','counter','regClr'},...
    'InportTypes',[dataType,ufix1Type,ufix1Type,ufix1Type,cntType,ufix1Type],...
    'InportRates',[inRate,inRate,inRate,inRate,inRate,inRate],...
    'OutportNames',{'crcChecksum'},...
    'OutportTypes',crcType...
    );


    datainReg=cptNet.PirInputSignals(1);
    validin=cptNet.PirInputSignals(2);
    processMsg=cptNet.PirInputSignals(3);
    padZero=cptNet.PirInputSignals(4);
    counter=cptNet.PirInputSignals(5);
    regClr=cptNet.PirInputSignals(6);

    crcchecksum=cptNet.PirOutputSignals(1);


    dvalidin=cptNet.addSignal(ufix1Type,'dvalidin');
    rpadZero=cptNet.addSignal(ufix1Type,'rpadZero');
    dataSel=cptNet.addSignal(ufix1Type,'dataSel');

    pirelab.getUnitDelayComp(cptNet,validin,dvalidin,'validin_register',0);
    pirelab.getLogicComp(cptNet,padZero,rpadZero,'not');
    dcomp=pirelab.getLogicComp(cptNet,[rpadZero,dvalidin],dataSel,'and');
    dcomp.addComment('Selection signal: Select input data or pad zeros');

    zerosclen=cptNet.addSignal(crcType,'padingzeros');
    datacpt=cptNet.addSignal(crcType,'datacpt');

    zcomp=pirelab.getConstComp(cptNet,zerosclen,0);
    zcomp.addComment('Padding zeros');


    if(blockInfo.ReflectInput)
        reflectdata=cptNet.addSignal(dataType,'reflectdata');
        idxarray=[];
        for i=1:round(dlen/8)
            sidx=8*i;
            eidx=1+8*(i-1);
            idxarray=[idxarray,sidx:-1:eidx];
        end
        idxarray={idxarray};

        scomp=pirelab.getSelectorComp(cptNet,datainReg,reflectdata,'One-based',...
        {'Index vector (dialog)'},idxarray,{'1'},'1');
        scomp.addComment('Input data bytewise reflection');
    else
        reflectdata=datainReg;
    end

    if(clen-dlen>0)
        inzeroType=pirelab.getPirVectorType(ufix1Type,clen-dlen);
        inputzeros=cptNet.addSignal(inzeroType,'inputzeros');
        pirelab.getConstComp(cptNet,inputzeros,0);
        datamux=cptNet.addSignal(crcType,'datamux');
        dcomp=pirelab.getMuxComp(cptNet,[inputzeros,reflectdata],datamux);
        dcomp.addComment('Prepare inputs for parallel CRC computation');
    else
        datamux=reflectdata;
    end
    dcomp=pirelab.getSwitchComp(cptNet,[datamux,zerosclen],datacpt,dataSel,'','~=',0);
    dcomp.addComment(' Switch between input data and padded zeros');


    F=zeros(clen,clen);
    I=eye(clen,clen);
    p=blockInfo.Polynomial(2:end);

    F=[p',I(:,1:clen-1)];

    for i=1:dlen-1
        c=GF2multiply(this,F,p');
        F=[c,F(:,1:clen-1)];
    end


    checksumReg=cptNet.addSignal(crcType,'checksumReg');
    tchecksum=cptNet.addSignal(crcType,'tchecksum');


    csarray=checksumReg.split;
    dataarray=datacpt.split;


    for i=1:clen
        tcsarray(i)=cptNet.addSignal(ufix1Type,['tcs_entry',num2str(i-1)]);
    end






    rregClr=cptNet.addSignal(ufix1Type,'rregClr');
    pirelab.getLogicComp(cptNet,regClr,rregClr,'not');
    csarrayR=cptNet.addSignal(crcType,'csarrayR');
    csarrayR.addComment('Make checksumReg as zero');
    csarrayRele=csarrayR.split;

    for j=1:clen
        xorins=[];
        for k=1:clen
            if F(j,k)==1




                xorins=[xorins,csarray.PirOutputSignals(clen-k+1)];
            end
        end
        xorins=[xorins,dataarray.PirOutputSignals(j)];
        dcomp=pirelab.getLogicComp(cptNet,xorins,tcsarray(clen-j+1),'xor');
        dcomp.addComment(['Compute checksum element',num2str(clen-j+1')]);
    end


    this.muxSignal(cptNet,tcsarray,tchecksum);


    tcsSel=cptNet.addSignal(ufix1Type,'tcsSel');
    csSel=cptNet.addSignal(ufix1Type,'csSel');
    newchecksum=cptNet.addSignal(crcType,'newChecksum');

    pirelab.getLogicComp(cptNet,[processMsg,dvalidin],tcsSel,'and');

    pirelab.getLogicComp(cptNet,[tcsSel,padZero],csSel,'or');

    dcomp.addComment('Checksum selection signal');
    dcomp=pirelab.getSwitchComp(cptNet,[tchecksum,checksumReg],newchecksum,csSel,'','~=',0);
    dcomp.addComment('Update checksum register for valid inputs');


    if~(blockInfo.ReflectCRCChecksum)
        refchecksum=cptNet.addSignal(crcType,'refelctCheckSum');
        idxarray={clen:-1:1};
        scomp=pirelab.getSelectorComp(cptNet,newchecksum,refchecksum,'One-based',...
        {'Index vector (dialog)'},idxarray,...
        {'1'},'1');
        scomp.addComment('Reflect Checksum and make checksum LSB first');
    else
        refchecksum=newchecksum;
    end


    finalxor=cptNet.addSignal(crcType,'finalXorValue');
    xoredCRC=cptNet.addSignal(crcType,'xoredChecksum');
    finalCRC=cptNet.addSignal(crcType,'finalChecksum');

    dcomp=pirelab.getConstComp(cptNet,finalxor,blockInfo.FinalXorValue);
    dcomp.addComment('Compute finalXor');

    pirelab.getLogicComp(cptNet,[refchecksum,finalxor],xoredCRC,'xor');
    if clen>dlen

        xoredSel=cptNet.addSignal(ufix1Type,'xoredSel');
        pirelab.getCompareToValueComp(cptNet,counter,xoredSel,'==',round(clen/dlen)-1);
    else
        xoredSel=padZero;
    end

    dcomp=pirelab.getSwitchComp(cptNet,[xoredCRC,newchecksum],finalCRC,xoredSel,'','~=',0);
    dcomp.addComment('Xor after computing the checksum');

    checksumRst=cptNet.addSignal(ufix1Type,'checksumRst');
    pirelab.getLogicComp(cptNet,[xoredSel,regClr],checksumRst,'or');


    pirelab.getUnitDelayResettableComp(cptNet,finalCRC,checksumReg,checksumRst,'checksum_register',blockInfo.InitialState,'',1);
    pirelab.getUnitDelayEnabledComp(cptNet,finalCRC,crcchecksum,xoredSel,'outputchecksum_register',0,'','',1);

end




