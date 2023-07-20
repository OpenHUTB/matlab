function partialDeriv=twoStepFinDiffFormulas(formulaType,delta,fCurrent,...
    fPert1,fPert2)

















    if formulaType==0

        partialDeriv=(-fPert1+fPert2)/(2*delta);
    elseif formulaType==1

        partialDeriv=(-3*fCurrent+4*fPert1-fPert2)/(2*delta);
    else

        partialDeriv=(fPert1-4*fPert2+3*fCurrent)/(2*delta);
    end
