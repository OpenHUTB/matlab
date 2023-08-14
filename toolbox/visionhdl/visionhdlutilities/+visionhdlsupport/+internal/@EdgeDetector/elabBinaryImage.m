function bImageNet=elabBinaryImage(~,topNet,blockInfo,dataRate)





    ctrlType=pir_boolean_t();
    bImageNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','GenerateBinaryImage',...
    'InportNames',{'grad1','grad2','threshold'},...
    'InportTypes',[blockInfo.gradType,blockInfo.gradType,blockInfo.thresqType],...
    'InportRates',[dataRate,dataRate,dataRate],...
    'OutportNames',{'binaryImage'},...
    'OutportTypes',ctrlType);


    grad1=bImageNet.PirInputSignals(1);
    grad2=bImageNet.PirInputSignals(2);
    thresh=bImageNet.PirInputSignals(3);

    BImage=bImageNet.PirOutputSignals(1);

    if blockInfo.thresqType.builtin
        gradSqType=blockInfo.thresqType;
    else
        gradSqType=bImageNet.getType('FixedPoint',...
        'Signed',false,...
        'WordLength',blockInfo.thresqType.WordLength-1,...
        'FractionLength',blockInfo.thresqType.FractionLength);
    end

    grad1delay=bImageNet.addSignal(blockInfo.gradType,'grad1PreMul');
    pirelab.getIntDelayComp(bImageNet,grad1,grad1delay,2);
    grad1sq=bImageNet.addSignal(gradSqType,'g1Square');
    pirelab.getMulComp(bImageNet,[grad1delay,grad1delay],grad1sq,'Floor','Saturate');
    grad1sqdelay=bImageNet.addSignal(gradSqType,'g1SquarePostMul');
    pirelab.getIntDelayComp(bImageNet,grad1sq,grad1sqdelay,2);

    grad2delay=bImageNet.addSignal(blockInfo.gradType,'grad2PreMul');
    pirelab.getIntDelayComp(bImageNet,grad2,grad2delay,2);
    grad2sq=bImageNet.addSignal(gradSqType,'g2Square');
    pirelab.getMulComp(bImageNet,[grad2delay,grad2delay],grad2sq,'Floor','Saturate');
    grad2sqdelay=bImageNet.addSignal(gradSqType,'g2SquarePostMul');
    pirelab.getIntDelayComp(bImageNet,grad2sq,grad2sqdelay,2);

    sqsum=bImageNet.addSignal(blockInfo.thresqType,'gSquareSum');
    pirelab.getAddComp(bImageNet,[grad1sqdelay,grad2sqdelay],sqsum,'Floor','Saturate');
    sqsumdelay=bImageNet.addSignal(blockInfo.thresqType,'SquareSumDelay');
    pirelab.getUnitDelayComp(bImageNet,sqsum,sqsumdelay);

    bImageNext=bImageNet.addSignal(ctrlType,'bImageNext');
    pirelab.getRelOpComp(bImageNet,[sqsumdelay,thresh],bImageNext,'>',true);
    pirelab.getUnitDelayComp(bImageNet,bImageNext,BImage);




