function strinLenComp=getStringLengthComp(hN,hInSignals,hOutSignals,compName,outTpEx)


    strinLenComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_stringlength',...
    'EMLParams',{outTpEx},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);

end
