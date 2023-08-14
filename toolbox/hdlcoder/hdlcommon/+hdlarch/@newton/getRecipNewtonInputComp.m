function[anorm,dynamicshift,normFixedShift,onemoreshift,changesign,hInC]=getRecipNewtonInputComp(hN,hInSignals)





    inputType=hInSignals(1).Type;
    inputWL=inputType.WordLength;
    inputFL=-inputType.FractionLength;







    inputIntL=inputWL-inputFL;
    if(inputIntL>0)
        normFL=inputWL;




        if(mod(inputIntL,2)==0)
            normFixedShift=inputIntL;
        else
            normFL=normFL+1;
            normFixedShift=(inputIntL+1);
        end
    else
        normFL=inputFL;
        normFixedShift=0;
    end


    normWL=inputWL;
    reintpType=pir_ufixpt_t(normWL,-normFL);
    reintp_ex=pirelab.getTypeInfoAsFi(reintpType);



    if normFL>normWL
        normWL=normFL;
    end
    normType=pir_ufixpt_t(normWL,-normFL);
    norm_ex=pirelab.getTypeInfoAsFi(normType);


    numOR=ceil(normWL/2)-1;


    shiftvWL=ceil(log2(normWL));
    shiftvType=pir_ufixpt_t(shiftvWL,0);
    shiftv_ex=pirelab.getTypeInfoAsFi(shiftvType);







    ufix1Type=pir_ufixpt_t(1,0);


    anorm=hN.addSignal(normType,'anorm');
    dynamicshift=hN.addSignal(shiftvType,'dynamicshift');
    onemoreshift=hN.addSignal(ufix1Type,'onemoreshift');
    if inputType.Signed
        changesign=hN.addSignal(ufix1Type,'changesign');
        hInC=hN.addComponent2(...
        'kind','cgireml',...
        'Name','in_norm',...
        'InputSignals',hInSignals,...
        'OutputSignals',[anorm,dynamicshift,onemoreshift,changesign],...
        'EMLFileName','hdleml_recipnewton_input',...
        'EMLParams',{reintp_ex,norm_ex,normWL,normFixedShift,numOR,shiftv_ex},...
        'BlockComment','Input Normalization');
    else
        hInC=hN.addComponent2(...
        'kind','cgireml',...
        'Name','in_norm',...
        'InputSignals',hInSignals,...
        'OutputSignals',[anorm,dynamicshift,onemoreshift],...
        'EMLFileName','hdleml_recipnewton_input',...
        'EMLParams',{reintp_ex,norm_ex,normWL,normFixedShift,numOR,shiftv_ex},...
        'BlockComment','Input Normalization');
        changesign=[];
    end


