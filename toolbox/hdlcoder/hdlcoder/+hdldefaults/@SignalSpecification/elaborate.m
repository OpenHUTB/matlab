function newComp=elaborate(~,hN,hC)



    if hC.PirOutputSignals(1).Type.isMatrix
        traceComment=hC.getComment;
    else
        traceComment='';
    end
    newComp=pirelab.getWireComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    hC.Name,'',-1,traceComment);




    if(strfind(newComp.getBlockName,'/Buffer'))
        newComp.setSourceBlock('sigspec');
    end
end


