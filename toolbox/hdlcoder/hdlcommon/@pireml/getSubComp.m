function SubComp=getSubComp(hN,hInSignals,hOutSignals,...
    rndMode,satMode,compName,accumType)




    if(nargin<7)
        applyAccumType=false;
    else
        applyAccumType=true;
    end

    if(nargin<6)
        compName='subtractor';
    end

    if(nargin<5)
        satMode='Wrap';
    end

    if(nargin<4)
        rndMode='Floor';
    end

    if applyAccumType


        outputTpEx=pirelab.getTypeInfoAsFi(hOutSignals.Type,rndMode,satMode);

        in1=hN.addSignal(accumType,sprintf('%s_accum_in1',hInSignals(1).Name));
        in2=hN.addSignal(accumType,sprintf('%s_accum_in2',hInSignals(2).Name));

        pireml.getDTCComp(hN,hInSignals(1),in1,rndMode,satMode,'RWV','sub_accum_dtc1');
        pireml.getDTCComp(hN,hInSignals(2),in2,rndMode,satMode,'RWV','sub_accum_dtc2');


        SubComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',[in1,in2],...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_sub',...
        'EMLParams',{outputTpEx});
    else


        outTpEx=pirelab.getTypeInfoAsFi(hOutSignals.Type,rndMode,satMode);

        SubComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hInSignals,...
        'OutputSignals',hOutSignals,...
        'EMLFileName','hdleml_sub',...
        'EMLParams',{outTpEx});

    end
