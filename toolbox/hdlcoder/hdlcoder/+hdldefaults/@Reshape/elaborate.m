

function hNewC=elaborate(~,hN,hC)


    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode())

        if hC.PirOutputSignals(1).Type.isMatrix
            traceComment=hC.getComment;
        else
            traceComment='';
        end
        hNewC=pirelab.getWireComp(hN,hC.SLInputSignals,hC.SLOutputSignals,hC.Name,'',-1,traceComment);



        if(strcmp(hNewC.ClassName,'buffer_comp'))
            hNewC.setSourceBlock('reshape');
        end
    else

        hCInSignals=hC.SLInputSignals;
        hCOutSignals=hC.SLOutputSignals;

        hNewC=pirelab.getReshapeComp(hN,hCInSignals,hCOutSignals);
    end



end
