function hOutC=getNewtonOutputComp(hN,hInSignals,hOutSignals,newtonInfo,normFixedShift)









    normType=newtonInfo.normType;
    maxDynamicShift=ceil(normType.WordLength/2)-1;


    intermType=newtonInfo.intermType;
    preshiftWL=intermType.WordLength+maxDynamicShift;
    preshiftFL=-intermType.FractionLength;
    preshiftType=pir_ufixpt_t(preshiftWL,-preshiftFL);
    preshift_ex=pirelab.getTypeInfoAsFi(preshiftType);



    denormWL=preshiftWL;
    denormFL=preshiftFL+normFixedShift;
    denormType=pir_ufixpt_t(denormWL,-denormFL);
    denorm_ex=pirelab.getTypeInfoAsFi(denormType);


    output_ex=newtonInfo.output_ex;


    hOutC=hN.addComponent2(...
    'kind','cgireml',...
    'Name','out_denorm',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_newton_output',...
    'EMLParams',{preshift_ex,denorm_ex,output_ex},...
    'BlockComment','Output Denormalization');

