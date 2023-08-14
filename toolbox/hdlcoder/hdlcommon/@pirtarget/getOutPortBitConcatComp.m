function getOutPortBitConcatComp(hN,hInSignals,hOutSignals)





    if length(hInSignals)==1


        pirelab.getDTCComp(hN,hInSignals{1},hOutSignals,'Floor','Wrap','SI');
    else
        pirelab.getBitConcatComp(hN,hInSignals(end:-1:1),hOutSignals);
    end
end