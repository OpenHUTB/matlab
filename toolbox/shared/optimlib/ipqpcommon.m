function[x,fval,exitflag,output,lambda]=ipqpcommon(H,f,A,b,Aeq,beq,lb,ub,x0,...
    flags,opts,defaultopt)













    A=sparse(A);
    Aeq=sparse(Aeq);


    optionsNeeded={'Display';'ConvexCheck';'MaxIter';'TolCon';'TolFun';'EnablePresolve';'TolX';'ProblemdefOptions'};
    defaultopt.EnablePresolve=true;
    defaultopt.ConvexCheck='on';

    for i=1:numel(optionsNeeded)
        field=optionsNeeded{i};
        options.(field)=optimget(opts,field,defaultopt,'fast');
    end


    flags.FromEqnSolve=false;
    if~isempty(options.ProblemdefOptions)&&isfield(options.ProblemdefOptions,'FromEqnSolve')
        flags.FromEqnSolve=options.ProblemdefOptions.FromEqnSolve;
    end


    if strcmpi(options.ConvexCheck,'on')
        options.ConvexCheck=1;
    else
        options.ConvexCheck=0;
    end


    if~isempty(x0)&&flags.verbosity>=1
        fprintf(getString(message('optimlib:ipqpcommon:IgnoringX0')));
    end


    if isfield(opts,'PresolveOps')
        transformsToPerform=opts.PresolveOps;
    else
        transformsToPerform=[];
    end


    flags.makeExitMsg=logical(flags.verbosity)||flags.computeLambda;

    if(options.EnablePresolve)


        [H,f,A,b,Aeq,beq,lb,ub,transforms,restoreData,exitflag,msg]=...
        presolve(H,full(f),A,full(b),Aeq,full(beq),full(lb),full(ub),...
        options,flags.computeLambda,transformsToPerform,flags.makeExitMsg);


        if~isempty(exitflag)
            x=[];fval=[];lambda=[];
            output.algorithm='interior-point-convex';
            output.iterations=0;
            output.cgiterations=[];
            output.constrviolation=[];
            output.firstorderopt=[];
            output.message=msg;

            if exitflag>0


                [x,lambda]=postsolve(x,transforms,restoreData,...
                lambda,options,flags.computeLambda,false);
            end
            return
        end
    end


    nVar=length(f);


    xIndices=classifyBoundsOnVars(lb,ub,nVar,true);


    [x,fval,exitflag,output,lambda]=ipConvexQP(H,f,A,b,Aeq,beq,lb,ub,nVar,...
    options,xIndices,flags);

    if(options.EnablePresolve)

        [x,lambda]=postsolve(x,transforms,restoreData,lambda,options,...
        flags.computeLambda,false);
    end


    function[xOut,fval,exitflag,output,lambda]=ipConvexQP(H,f,A,b,Aeq,beq,lb,ub,nVar,...
        options,xIndices,flags)




        x0=ones(nVar,1);


        sizes=setSizes(x0,[],[],Aeq,A,xIndices,false);


        x0=shiftInitPtToInterior(sizes.nVar,x0,lb,ub,Inf);


        sparseId=speye(sizes.nVar,sizes.nVar);
        Acomb=[-A;
        sparseId(xIndices.finiteLb,:);
        -sparseId(xIndices.finiteUb,:)];
        bcomb=[-b;lb(xIndices.finiteLb);-ub(xIndices.finiteUb)];




        Aeqcomb=Aeq;
        beqcomb=beq;
        if~isempty(xIndices.fixed)
            Aeqcomb=[Aeq;
            sparseId(xIndices.fixed,:)];
            beqcomb=[beq;lb(xIndices.fixed)];
        end

        [xOut,fval,exitflag,qpoutput,lambdaOut]=barrierConvexQPmex(H,f,Acomb,bcomb,Aeqcomb,beqcomb,x0,options);


        grad=H*xOut+f;
        lambda=formLambdaStruct(lambdaOut,grad,xIndices,sizes,false);


        lambda=fixLambda(lambda);



        dispMsg=flags.verbosity>0;
        switch exitflag
        case 1
            msgData={{'optimlib:ipqpcommon:Exit1basic'},...
            {'optimlib:ipqpcommon:Exit1detailed',...
            qpoutput.dualnorm/qpoutput.stop_relFactorObjConstr,options.TolFun,...
            qpoutput.complerror,...
            qpoutput.primalnorm/qpoutput.stop_relFactorConstr,options.TolCon},...
            dispMsg,flags.detailedExitMsg};
        case 0
            msgData={{'optimlib:commonMsgs:Exit10basic',flags.caller,options.MaxIter},...
            {},dispMsg,false};
        case 6

            exitflag=2;


            AineqFeasible=true;
            lbFeasible=true;
            ubFeasible=true;
            AeqFeasible=true;

            if(~isempty(A))
                AineqFeasible=all(A*xOut<=b+options.TolCon);
            end
            if(~isempty(lb))
                lbFeasible=all(xOut>=lb-options.TolCon);
            end
            if(~isempty(ub))
                ubFeasible=all(xOut<=ub+options.TolCon);
            end
            if(~isempty(Aeq))
                AeqFeasible=all(norm(Aeq*xOut-beq,inf)<=options.TolCon);
            end

            msgID='optimlib:ipqpcommon:Exit2detailed';
            if~(AineqFeasible&&lbFeasible&&ubFeasible&&AeqFeasible)
                exitflag=-2;
                msgID='optimlib:ipqpcommon:ExitNeg22detailed';
            end

            msgData={{replace(msgID,'detailed','basic'),flags.caller},...
            {msgID,options.TolX,...
            qpoutput.primalnorm/qpoutput.stop_relFactorConstr,options.TolCon},...
            dispMsg,flags.detailedExitMsg};
        case-2
            msgData={{'optimlib:ipqpcommon:ExitNeg21basic',flags.caller},...
            {'optimlib:ipqpcommon:ExitNeg21detailed',...
            qpoutput.meritfun/qpoutput.stop_relFactorObjConstr*options.TolFun},...
            dispMsg,flags.detailedExitMsg};
        case-6
            msgData={{'optimlib:ipqpcommon:ExitNeg6basic'},{},dispMsg,false};
        case-8
            msgData={{'optimlib:ipqpcommon:ExitNeg8basic'},{},dispMsg,false};
        case 91
            error(message('optimlib:ipqpcommon:ipConvexQP:emptyProblem'));
        case 92
            error(message('optimlib:ipqpcommon:ipConvexQP:InfNaNComplexDetected'));
        otherwise
            error(message('optimlib:ipqpcommon:ipConvexQP:unknownExitflag'));
        end


        if flags.FromEqnSolve


            output.msgData=msgData;
        elseif flags.makeExitMsg

            output.message=createExitMsg(msgData{:});
        end

        output.algorithm='interior-point-convex';
        output.firstorderopt=max(qpoutput.dualnorm,qpoutput.complerror);
        output.constrviolation=qpoutput.primalnorm;
        output.iterations=qpoutput.iterations;



        function lambda=fixLambda(lambda)


            idx=find(lambda.lower&lambda.upper);


            idxLb=lambda.upper(idx)<lambda.lower(idx);

            lambda.lower(idx(idxLb))=lambda.lower(idx(idxLb))-lambda.upper(idx(idxLb));
            lambda.upper(idx(idxLb))=0;

            lambda.upper(idx(~idxLb))=lambda.upper(idx(~idxLb))-lambda.lower(idx(~idxLb));
            lambda.lower(idx(~idxLb))=0;