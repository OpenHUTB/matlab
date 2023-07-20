function cgirComp=getBitRotateComp(hN,hInSignals,hOutSignals,opName,rotateLength,compName)



    if(nargin<6)
        compName='rotate';
    end



    cgirComp=hN.addComponent2(...
    'kind','bitrotate_comp',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'OpName',opName,...
    'Length',rotateLength);

end


