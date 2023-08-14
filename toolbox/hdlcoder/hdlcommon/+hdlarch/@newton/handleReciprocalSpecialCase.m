function recipComp=handleReciprocalSpecialCase(hN,hInSignals,hOutSignals,rndMode,satMode,compName)







    hInType=hInSignals.Type;
    hOutType=hOutSignals.Type;

    inSigned=hInType.Signed;
    inWordLen=hInType.WordLength;
    inFracLen=-hInType.FractionLength;
    outSigned=hOutType.Signed;
    outWordLen=hOutType.WordLength;
    outFracLen=-hOutType.FractionLength;


    ufix1_in=~inSigned&&(inWordLen==1);
    sfix2_in=inSigned&&(inWordLen==2);
    ufix1_out=~outSigned&&(outWordLen==1);


    if ufix1_in
        mode=1;
    elseif ufix1_out
        mode=2;
    elseif sfix2_in
        mode=3;
    else
        mode=4;
    end


    outtp_ex=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode);

    if ufix1_in||sfix2_in

        Div_zero=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,upperbound(outtp_ex));
        Div_posone=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,2^inFracLen);
        Div_negone=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,-2^inFracLen);
        Div_negtwo=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,-2^(inFracLen-1));

        Input_posone=pirelab.getTypeInfoAsFi(hInType,rndMode,satMode,2^-inFracLen);
        Input_negone=pirelab.getTypeInfoAsFi(hInType,rndMode,satMode,-2^-inFracLen);

        recipComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_reciprocalspecial',...
        'EMLParams',{mode,Div_zero,Div_posone,Div_negone,Div_negtwo,...
        0,0,0,0,Input_posone,Input_negone,0},...
        'EMLFlag_RunLoopUnrolling',false);

    else

        Const_zero=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,0);
        Const_posone=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,2^-outFracLen);
        Const_negone=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,-2^-outFracLen);
        Const_negtwo=pirelab.getTypeInfoAsFi(hOutType,rndMode,satMode,-2^(-outFracLen+1));

        Input_posone=pirelab.getTypeInfoAsFi(hInType,rndMode,satMode,2^outFracLen);
        Input_negone=pirelab.getTypeInfoAsFi(hInType,rndMode,satMode,-2^outFracLen);
        Input_negtwo=pirelab.getTypeInfoAsFi(hInType,rndMode,satMode,-2^(outFracLen-1));

        recipComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_reciprocalspecial',...
        'EMLParams',{mode,0,0,0,0,...
        Const_zero,Const_posone,Const_negone,Const_negtwo,...
        Input_posone,Input_negone,Input_negtwo},...
        'EMLFlag_RunLoopUnrolling',false);
    end