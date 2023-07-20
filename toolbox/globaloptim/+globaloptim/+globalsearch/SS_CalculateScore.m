function Score=SS_CalculateScore(x,fval,c,ceq,state)




























    if isempty(c)&&isempty(ceq)
        Score=fval;
        return
    end


    nPts=size(x,1);


    cviol=[c,abs(ceq)];
    TOL=1e-4;
    cviol(cviol<TOL)=0;


    isFeas=all(cviol<=0,2);


    Score=zeros(nPts,1);
    Score(isFeas)=fval(isFeas);


    if isempty(ceq)
        cRange=state.ConIQRange;
    elseif isempty(c)
        cRange=state.EqConIQRange;
    else
        cRange=[state.ConIQRange,state.EqConIQRange];
    end
    cRange=cRange(ones(sum(~isFeas),1),:);
    sConViol=cviol(~isFeas,:)./cRange;


    if isempty(state.ObjMaxFeas)
        fmax=0;
    else
        fmax=state.ObjMaxFeas;
    end
    Score(~isFeas)=fmax+sum(sConViol,2);
