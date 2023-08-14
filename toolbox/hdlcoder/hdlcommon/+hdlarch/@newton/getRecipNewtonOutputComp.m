function hOutC=getRecipNewtonOutputComp(hN,hInSignals,hOutSignals,newtonInfo,normFixedShift)









    intermType=newtonInfo.intermType;







    maxEvenDynamicShift=floor(intermType.WordLength/2)*2;


    intermType=newtonInfo.intermType;






    output_ex=newtonInfo.output_ex;




    outflreqwidshift=(intermType.WordLength+output_ex.FractionLength-(-intermType.FractionLength+normFixedShift));


    if mod(output_ex.WordLength-output_ex.FractionLength,2)==0
        outflreqwidshift=(outflreqwidshift>0);
    end
    denormWL=intermType.WordLength;
    denormFL=-intermType.FractionLength+normFixedShift+outflreqwidshift-intermType.WordLength;
    denormType=pir_ufixpt_t(denormWL,-denormFL);
    denorm_ex=pirelab.getTypeInfoAsFi(denormType);




    hOutC=hN.addComponent2(...
    'kind','cgireml',...
    'Name','out_denorm',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_recipnewton_output',...
    'EMLParams',{maxEvenDynamicShift,intermType.WordLength,outflreqwidshift,denorm_ex,output_ex},...
    'BlockComment','Output Denormalization');

