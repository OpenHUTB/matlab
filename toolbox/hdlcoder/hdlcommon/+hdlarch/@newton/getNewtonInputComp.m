function[anorm,dynamicshift,normFixedShift,hInC]=getNewtonInputComp(hN,hInSignals)





    inputType=hInSignals(1).Type;
    inputWL=inputType.WordLength;
    inputFL=-inputType.FractionLength;







    inputIntL=inputWL-inputFL;
    if(inputIntL>0)
        normFL=inputWL;

        if(mod(inputIntL,2)==0)
            normFixedShift=inputIntL/2;
        else
            normFL=normFL+1;
            normFixedShift=(inputIntL+1)/2;
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


    anorm=hN.addSignal(normType,'anorm');
    dynamicshift=hN.addSignal(shiftvType,'dynamicshift');
    hInC=hN.addComponent2(...
    'kind','cgireml',...
    'Name','in_norm',...
    'InputSignals',hInSignals,...
    'OutputSignals',[anorm,dynamicshift],...
    'EMLFileName','hdleml_newton_input',...
    'EMLParams',{reintp_ex,norm_ex,normWL,numOR,shiftv_ex},...
    'BlockComment','Input Normalization');

