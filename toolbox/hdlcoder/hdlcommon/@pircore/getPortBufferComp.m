function bufferComp=getPortBufferComp(hN,hInSignals,hOutSignals,...
    compName,slbh,desc)



    if nargin<4
        compName='';
    end

    if nargin<5
        slbh=-1.0;
    end

    if nargin<6
        desc='';
    end

    bufferComp=hN.addComponent2(...
    'kind','buffer',...
    'SimulinkHandle',slbh,...
    'name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'BlockComment',desc);
end
