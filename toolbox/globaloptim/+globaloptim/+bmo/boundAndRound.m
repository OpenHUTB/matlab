function cand=boundAndRound(cand,problem,oldCand,options)










    intVarIdx=problem.vartype(:);
    intcon=problem.intcon;
    lb=problem.lb;
    ub=problem.ub;

    cand=min(cand,ub');
    cand=max(cand,lb');
    cand(:,intcon)=round(cand(:,intcon));

    if isempty(problem.Aineq)&&isempty(problem.Aeq)

        remove_duplicates();
        return
    end


    ConstraintTolerance=options.LinearConstraintTolerance;
    IntegerTolerance=options.IntegerTolerance;

    Aineq=problem.Aineq;
    bineq=problem.bineq;
    Aeq=problem.Aeq;
    beq=problem.beq;
    intcon=problem.intcon;
    continuousFeasible=globaloptim.internal.validate.isTrialFeasible(cand,Aineq,bineq,Aeq,beq,lb,ub,ConstraintTolerance);

    if~isempty(intcon)
        integerFeasible=checkIntegerFeasible(cand);
    else
        integerFeasible=true(size(cand,1),1);
    end

    infeasibleCandidates=find(~continuousFeasible|~integerFeasible);

    if isempty(infeasibleCandidates)

        remove_duplicates();
        return;
    end

    logicalForIntegers=intVarIdx;
    numVars=numel(logicalForIntegers);
    if isempty(Aineq)
        Aineq=sparse(0,numVars);
    end
    if isempty(Aeq)
        Aeq=sparse(0,numVars);
    end



    objR=zeros(1,nnz(~logicalForIntegers));
    AineqR=Aineq(:,~logicalForIntegers);
    AeqR=Aeq(:,~logicalForIntegers);
    lbR=lb(~logicalForIntegers);
    ubR=ub(~logicalForIntegers);
    haveContinuousVariables=nnz(~logicalForIntegers)>0;

    optionsLP=options.optionsLP;


























    objARA=[zeros(numVars,1);ones(numVars,1)];
    AeqARA=[sparse(Aeq),sparse(size(Aeq,1),numVars)];

    AineqARA=[sparse(Aineq),sparse(size(Aineq,1),numVars);
    -speye(numVars,numVars),-speye(numVars,numVars);
    speye(numVars,numVars),-speye(numVars,numVars)];


    tB=(ub-lb);
    lbARA=[lb;-tB];
    ubARA=[ub;tB];


    for i=infeasibleCandidates'
        canNotFindFeasible=false;
        if isempty(intcon)


            bineqARA=[bineq;-cand(i,:)';cand(i,:)'];
            [x,~,exitflag]=options.LPalg.runNoChecks(objARA,AineqARA,bineqARA,AeqARA,beq,lbARA,ubARA);
            if~isempty(x)&&exitflag>0
                cand(i,:)=x(1:numVars)';
                continuousFeasible(i)=true;
                continue;
            end
        else
            if~continuousFeasible(i)&&integerFeasible(i)

                if haveContinuousVariables

                    bineqR=bineq-Aineq(:,logicalForIntegers)*cand(i,logicalForIntegers)';
                    beqR=beq-Aeq(:,logicalForIntegers)*cand(i,logicalForIntegers)';
                    [x,~,exitflag]=options.LPalg.runNoChecks(objR,AineqR,bineqR,AeqR,beqR,lbR,ubR);
                    if~isempty(x)&&exitflag>0
                        cand(i,~logicalForIntegers)=x';
                        continuousFeasible(i)=true;
                        continue;
                    else
                        canNotFindFeasible=true;
                    end
                else
                    canNotFindFeasible=true;
                end
            end
            if continuousFeasible(i)&&~integerFeasible(i)
                x=globaloptim.bmo.roundingHeuristic(cand(i,:)',intcon,Aineq,bineq,Aeq,beq,lb,ub,ConstraintTolerance,IntegerTolerance);
                if~isempty(x)
                    cand(i,:)=x';
                    integerFeasible(i)=true;
                    continue;
                end
                x=globaloptim.bmo.checkForTrivialSolutions(cand(i,:)',intcon,Aineq,bineq,Aeq,beq,lb,ub,ConstraintTolerance);
                if~isempty(x)
                    cand(i,:)=x';
                    integerFeasible(i)=true;
                    continue;
                else
                    canNotFindFeasible=true;
                end
            end
            if(~continuousFeasible(i)&&~integerFeasible(i))||canNotFindFeasible

                bineqARA=[bineq;-cand(i,:)';cand(i,:)'];


                [x,~,exitflag]=options.MILPalg.runNoChecks(...
                objARA,intcon,AineqARA,bineqARA,AeqARA,beq,lbARA,ubARA,[]);
                if~isempty(x)&&exitflag>0
                    cand(i,:)=x(1:numVars)';
                    continuousFeasible(i)=true;
                    integerFeasible(i)=true;
                end
            end
        end
    end




    feasibleCandidatesLogical=continuousFeasible&integerFeasible;


    if nnz(feasibleCandidatesLogical)>1&&nnz(~feasibleCandidatesLogical)>0
        feasibleCandidates=find(feasibleCandidatesLogical);
        numFeasCandidates=numel(feasibleCandidates);
        infeasibleCandidates=find(~feasibleCandidatesLogical);
        numCandidates=size(cand,1);
        for i=infeasibleCandidates'
            candOne=1+mod(i,numFeasCandidates);
            candTwo=1+mod(i+1,numFeasCandidates);
            candOneIdx=feasibleCandidates(candOne);
            candTwoIdx=feasibleCandidates(candTwo);
            weight=max(1,(i-1))/numCandidates;
            cand(i,:)=weight*cand(candOneIdx,:)+(1-weight)*cand(candTwoIdx,:);
            cand(i,intcon)=max(lb(intcon),min(round(cand(i,intcon))',ub(intcon)));

            integerFeasible(i)=true;

            if~isempty(intcon)

                continuousFeasible(i)=globaloptim.internal.validate.isTrialFeasible(...
                cand(i,:),Aineq,bineq,Aeq,beq,lb,ub,ConstraintTolerance);
            else
                continuousFeasible(i)=true;
            end

        end
    end


    cand(~continuousFeasible|~integerFeasible,:)=[];


    remove_duplicates();

    function remove_duplicates()

        [~,IA]=uniquetol(cand,1e-10,'ByRows',true);
        cand=cand(sort(IA),:);


        if~isempty(oldCand)



            [~,IA]=uniquetol([cand;oldCand],1e-10,'ByRows',true,...
            'OutputAllIndices',true);
            dups=[];


            for ii=1:length(IA)
                if length(IA{ii})>1&&IA{ii}(1)<=size(cand,1)

                    dups(end+1)=IA{ii}(1);
                end
            end

            cand(dups,:)=[];

        end
    end


    function integerFeasible=checkIntegerFeasible(trials)
        integerFeasible=all(abs(round(trials(:,intVarIdx))-trials(:,intVarIdx))<=IntegerTolerance,2);
    end
end