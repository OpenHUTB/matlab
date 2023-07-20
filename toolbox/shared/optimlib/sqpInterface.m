function[xCurrent,fval,exitflag,output,lambda,grad,Hess]=...
    sqpInterface(funfcn,xCurrent,Aineq,bineq,Aeq,beq,lb,ub,confcn,fval,grad,...
    cIneqUser,cEqUser,JacCineqTransUser,JacCeqTransUser,sizes,options,...
    finDiffFlags,verbosity,makeExitMsg,varargin)
















    if~isfinite(fval)||~isreal(fval)
        error('optimlib:sqpInterface:UsrObjUndefAtX0',getString(message('optimlib:sqpLineSearch:UsrObjUndefAtX0')));
    end
    if any(~isfinite([cIneqUser(:);cEqUser(:)]))||~isreal([cIneqUser(:);cEqUser(:)])
        error('optimlib:sqpInterface:UsrNonlConstrUndefAtX0',getString(message('optimlib:sqpLineSearch:UsrNonlConstrUndefAtX0')));
    end



    if any(~isfinite(grad(:)))||~isreal(grad)
        error('optimlib:sqpInterface:GradUndefAtX0',...
        getString(message('optimlib:commonMsgs:GradUndefAtX0','Fmincon')));
    elseif any(any(~isfinite(JacCineqTransUser)))||~isreal(JacCineqTransUser)
        error('optimlib:sqpInterface:DerivIneqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivIneqUndefAtX0','Fmincon')));
    elseif any(any(~isfinite(JacCeqTransUser)))||~isreal(JacCeqTransUser)
        error('optimlib:sqpInterface:DerivEqUndefAtX0',...
        getString(message('optimlib:commonMsgs:DerivEqUndefAtX0','Fmincon')));
    end

    if~isreal(Aineq)||~isreal(bineq)||~isreal(Aeq)||~isreal(beq)
        error('optimlib:sqpInterface:invalidLinConstr',getString(message('optimlib:sqpLineSearch:invalidLinConstr')));
    end

    if(any(~isreal(lb))||any(~isreal(ub)))
        error('optimlib:sqpInterface:invalidBounds',getString(message('optimlib:sqpLineSearch:invalidBounds')));
    end




    fscale=[];
    finDiffFlags.scaleObjConstr=false;

    finDiffFlags.chkFunEval=true;
    finDiffFlags.chkComplexObj=true;
    [grad,JacCineqTransUser,JacCeqTransUser,extraEvals,evalOK]=...
    computeFinDiffGradAndJac(xCurrent(:),funfcn,confcn,fval,cIneqUser(:),cEqUser(:),grad,...
    JacCineqTransUser,JacCeqTransUser,lb,ub,fscale,options,finDiffFlags,sizes,varargin{:});
    funcCount=1+extraEvals;


    finDiffFlags.scaleObjConstr=strcmpi(options.ScaleProblem,'obj-and-constr');


    undefGrads=~evalOK;


    if undefGrads
        error('optimlib:sqpInterface:DerivUndefAtX0',...
        getString(message('optimlib:commonMsgs:FinDiffDerivUndefAtX0','Fmincon')));
    end


    if isempty(options.OutputFcn)
        outputfcns=[];
    else

        outputfcns=createCellArrayOfFunctions(options.OutputFcn,'OutputFcn');
    end

    if isempty(options.PlotFcns)
        plotfcns=[];
    else

        plotfcns=createCellArrayOfFunctions(options.PlotFcns,'PlotFcns');
    end


    [xCurrent,fval,exitflag,output,lambda,grad,Hess]=sqpLineSearchMex(funfcn,xCurrent,Aineq,bineq,Aeq,beq,...
    lb,ub,confcn,fval,grad,cIneqUser,cEqUser,JacCineqTransUser,JacCeqTransUser,options,finDiffFlags,...
    verbosity,varargin,funcCount,outputfcns,plotfcns);


    if makeExitMsg
        output.message=createExitMsg(output.message{:});
    end