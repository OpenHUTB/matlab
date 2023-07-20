function Score=gaminlppenaltyfcn(pop,problem,conScale)




















    fObj=problem.fitnessfcn;
    fCon=problem.nonlcon;



    UserVectorized=problem.options.UserVectorized;
    SerialUserFcn=problem.options.SerialUserFcn;
    FunOnWorkers=problem.options.ProblemdefOptions.FunOnWorkers;
    mIneq=conScale.mIneq;
    mEq=conScale.mEq;
    TolCon=problem.options.TolCon;

    numPts=size(pop,1);





    if~isempty(problem.Aineq)
        lineq=bsxfun(@minus,problem.Aineq*pop',problem.bineq)';
    else
        lineq=zeros(numPts,0);
    end
    if~isempty(problem.Aeq)
        leq=bsxfun(@minus,problem.Aeq*pop',problem.beq)';
    else
        leq=zeros(numPts,0);
    end

    cviol=[lineq,abs(leq)];


    cviol(cviol<=TolCon)=0;
    isFeas=true(numPts,1);
    isFeas=isFeas&all(cviol<=0,2);





    if isempty(fCon)
        fval=Inf(numPts,1);
        c=zeros(numPts,0);ceq=zeros(numPts,0);

        if UserVectorized
            fval(isFeas)=fObj(pop(isFeas,:));
        else
            fval(isFeas)=fcnvectorizer(pop(isFeas,:),fObj,1,SerialUserFcn,FunOnWorkers);
        end


        if conScale.noConstrEvals
            Score=fval;
            return
        end
    elseif UserVectorized
        [c,ceq]=fCon(pop);
        if mIneq==0
            c=reshape(c,numPts,0);
        elseif mEq==0
            ceq=reshape(ceq,numPts,0);
        end

        isFeas=isFeas&isNonlinearFeasible(c,ceq,TolCon);


        fval=Inf(numPts,1);
        fval(isFeas)=fObj(pop(isFeas,:));
    else
        [fval,c,ceq,isFeas]=objAndConVectorizer(pop,fObj,fCon,1,mIneq,mEq,...
        SerialUserFcn,isFeas,TolCon);
    end


    cviol=[c,abs(ceq),cviol];



    cviol(cviol<=TolCon)=0;


    Score=zeros(numPts,1);
    Score(isFeas)=fval(isFeas);


    cScale=conScale.evaluate(c,ceq,lineq,leq);


    if any(~isFeas)

        if all(~isFeas)


            fmax=0;
        else
            fmax=max(Score(isFeas));
        end
        cScale=cScale(ones(sum(~isFeas),1),:);
        sConViol=cviol(~isFeas,:)./cScale;
        Score(~isFeas)=fmax+sum(sConViol,2);
    end



    Score(isnan(Score))=inf;
