function cgirComp=getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName)






    if(nargin<6)
        compName='rotate';
    end

    switch lower(opName)
    case{'rotate left','rol'}
        mode=1;
    case{'rotate right','ror'}
        mode=2;
    otherwise
        error(message('hdlcommon:hdlcommon:unsupportedbitrotatemode'));
    end

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_bitrotate',...
    'EMLParams',{mode,rotateLength},...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_RunLoopUnrolling',false);
end


