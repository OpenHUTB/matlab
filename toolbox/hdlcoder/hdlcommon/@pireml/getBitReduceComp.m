function cgirComp=getBitReduceComp(hN,hInSignals,hOutSignals,opName,compName)






    if(nargin<5)
        compName='reduce';
    end

    switch lower(opName)
    case 'and'
        mode=1;
    case 'or'
        mode=2;
    case 'xor'
        mode=3;
    otherwise
        error(message('hdlcommon:hdlcommon:unsupportedbitreducemode'));
    end

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_bitreduce',...
    'EMLParams',{mode},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end
