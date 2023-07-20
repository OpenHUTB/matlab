function lNet=addLineBuffer(~,topNet,blockInfo,inRate)





    boolType=pir_boolean_t();
    lbufVType=blockInfo.lbufVType;

    inportnames{1}='dataIn';
    inportnames{2}='hStartIn';
    inportnames{3}='hEndIn';
    inportnames{4}='vStartIn';
    inportnames{5}='vEndIn';
    inportnames{6}='validIn';

    outportnames{1}='dataOut';
    outportnames{2}='hStartOut';
    outportnames{3}='hEndOut';
    outportnames{4}='vStartOut';
    outportnames{5}='vEndOut';
    outportnames{6}='validOut';
    outportnames{7}='processDataOut';


    lNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','LineBuffer',...
    'InportNames',inportnames,...
    'InportTypes',[blockInfo.DataType,boolType,boolType,boolType,boolType,boolType],...
    'InportRates',[inRate,inRate,inRate,inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[lbufVType,boolType,boolType,boolType,boolType,boolType,boolType]...
    );




    lbufNet=visionhdlsupport.internal.LineBuffer;
    lbufNet.elaborateLineBuffer(lNet,blockInfo);
