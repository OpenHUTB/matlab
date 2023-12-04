function[x,fval,exitflag,output,lambda]=interiorPointMethod(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub,options,coneprogStartTime)

    import optim.coneprog.SecondOrderConeConstraint
    import optim.coneprog.checkInputType
    import optim.coneprog.checkInputNanComplexInf
    import optim.coneprog.checkInputSize
    import optim.coneprog.socp

    if isempty(options)
        options=optimoptions('coneprog');
    elseif~isa(options,'optim.options.SolverOptions')
        errid='optim:coneprog:InvalidOptions';
        msgid='optimlib:commonMsgs:InvalidOptions';
        ME=MException(errid,getString(message(msgid)));
        throwAsCaller(ME);
    end


    optionsStruct=prepareOptionsForSolver(options,'coneprog');

    checkInputType(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub);
    checkInputNanComplexInf(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub);
    [f,bineq,beq,lb,ub]=checkInputSize(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub);
    n=numel(f);
    [~,lb,ub,boundCheckMessage]=checkbounds([],lb,ub,n);
    if~isempty(boundCheckMessage)
        exitflag=-2;
        if strcmp(optionsStruct.Display,'iter')||strcmp(optionsStruct.Display,'final')
            fprintf(boundCheckMessage);
        end
    else
        coneprogSetupTime=toc(coneprogStartTime);
        optionsStruct.InternalOptions.StartTime=coneprogSetupTime;
        [x,fval,exitflag,output,lambda]=socp(f,socConstraints,Aineq,bineq,Aeq,beq,lb,ub,optionsStruct);
    end


    if exitflag==1
        output.message=getString(message('optim:coneprog:FinalDisplayMessageOptimalSolution'));
    elseif exitflag==0
        x=[];
        fval=[];
        lambda=[];
        output.primalfeasibility=[];
        output.dualfeasibility=[];
        output.dualitygap=[];
        if output.iterations>=options.MaxIterations
            output.message=getString(message('optim:coneprog:FinalDisplayMessageIterLimit'));
        else
            output.message=getString(message('optim:coneprog:FinalDisplayMessageTimeLimit'));
        end
    elseif exitflag==-2
        x=[];
        fval=[];
        lambda=[];
        output.primalfeasibility=[];
        output.dualfeasibility=[];
        output.dualitygap=[];
        output.message=getString(message('optim:coneprog:FinalDisplayMessageInfeasible'));
    elseif exitflag==-3
        x=[];
        fval=[];
        lambda=[];
        output.primalfeasibility=[];
        output.dualfeasibility=[];
        output.dualitygap=[];
        output.message=getString(message('optim:coneprog:FinalDisplayMessageUnbounded'));
    elseif exitflag==-7
        output.message=getString(message('optim:coneprog:FinalDisplayMessageSmallStep'));
    else
        x=[];
        fval=[];
        lambda=[];
        output.primalfeasibility=[];
        output.dualfeasibility=[];
        output.dualitygap=[];
        output.message=getString(message('optim:coneprog:FinalDisplayMessageUnstable'));
    end


    if strcmp(optionsStruct.Display,'iter')||strcmp(optionsStruct.Display,'final')
        disp(output.message);
    end

end
