function crcNet=addCRCDecoder(~,topNet,crcBlockInfo,inRate)
    boolType=pir_boolean_t();
    crcErrType=crcBlockInfo.crcErrType;

    inportnames{1}='dataIn';
    inportnames{2}='startIn';
    inportnames{3}='endIn';
    inportnames{4}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='startOut';
    outportnames{3}='endOut';
    outportnames{4}='validOut';
    outportnames{5}='err';



    crcNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRC Decoder',...
    'InportNames',inportnames,...
    'InportTypes',[boolType,boolType,boolType,boolType],...
    'InportRates',[inRate,inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[boolType,boolType,boolType,boolType,crcErrType]...
    );


    crcDecNet=ltehdlsupport.internal.CRCDecoder;
    crcDecNet.elaborateCRCDecoder(crcNet,crcBlockInfo,crcNet.PirInputSignals,crcNet.PirOutputSignals);
end
