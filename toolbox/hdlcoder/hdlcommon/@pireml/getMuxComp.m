function muxComp=getMuxComp(hN,hInSignals,hOutSignals,compName)



    if(nargin<4)
        compName='mux';
    end

    outEx=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);

    ipf='hdleml_mux';
    bmp={outEx};




    muxComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',bmp,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        muxComp.setSupportTargetCodGenWithoutMapping(true);
    end
end
