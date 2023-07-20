function cgirComp=getWireComp(hN,hInSignals,hOutSignals,compName,desc,slHandle)



    if(nargin<4)
        compName=[hInSignals(1).Name,'_wire'];
    end

    cgirComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_wire',...
    'EMLFlag_RunLoopUnrolling',false);

    cgirComp.isWiringComp(true);
    if targetmapping.isValidDataType(hInSignals.Type)
        cgirComp.setSupportTargetCodGenWithoutMapping(true);
    end
    if(nargin>=5)
        cgirComp.addComment(desc);
    end

    if(nargin>=6)
        cgirComp.SimulinkHandle=slHandle;
    end

end


