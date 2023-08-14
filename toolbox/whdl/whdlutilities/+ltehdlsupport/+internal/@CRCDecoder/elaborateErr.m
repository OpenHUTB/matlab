function crcCompNet=elaborateErr(~,topNet,blockInfo,sigInfo,dataRate)





    dataType=sigInfo.dataType;
    ufix1Type=pir_ufixpt_t(1,0);

    inPortNames={'in1','in2','en','rst','gateErrIn'};

    inPortRates=dataRate*ones(1,length(inPortNames));

    inPortTypes=[dataType,dataType,ufix1Type,ufix1Type,ufix1Type];

    outPortNames={'err'};

    if blockInfo.RNTIPort
        outPortTypes=pir_ufixpt_t(blockInfo.CRClen,0);
    else
        outPortTypes=ufix1Type;
    end

    crcCompNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCCompNet',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    desc='CRCCompareFunction';

    fid=fopen(fullfile(matlabroot,'toolbox','whdl','whdlutilities',...
    '+ltehdlsupport','+internal','@CRCDecoder','cgireml','CRCCompare.m'),'r');
    fcnBody=fread(fid,Inf,'char=>char');
    fclose(fid);

    checksum_crcgen=crcCompNet.PirInputSignals(1);
    checksum_crcin=crcCompNet.PirInputSignals(2);
    enable=crcCompNet.PirInputSignals(3);
    rst=crcCompNet.PirInputSignals(4);
    gateErr=crcCompNet.PirInputSignals(5);

    errport=crcCompNet.PirOutputSignals;
    inports=[checksum_crcgen,checksum_crcin,enable,rst,gateErr];

    depth=round(blockInfo.CRClen/blockInfo.dlen);

    CRCComp=crcCompNet.addComponent2(...
    'kind','cgireml',...
    'Name','CRCComp',...
    'InputSignals',inports,...
    'OutputSignals',errport,...
    'EMLFileName','CRCCompare',...
    'EMLFileBody',fcnBody,...
    'EMLParams',{blockInfo.CRClen,blockInfo.dlen,depth,blockInfo.RNTIPort},...
    'EMLFlag_TreatInputIntsAsFixpt',true,...
    'EMLFlag_SaturateOnIntOverflow',false,...
    'BlockComment',desc);
    CRCComp.runConcurrencyMaximizer(0);
end