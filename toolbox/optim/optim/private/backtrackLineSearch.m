function[alpha,f_alpha,grad,cEq,cIneq,cIneqUser,cEqUser,JacCeqTransUser,JacCineqTransUser,exitflag,funcCount,...
    faultTolStruct]=backtrackLineSearch(funfcn,confcn,mu,xInitial,dir,socDir,stepFlags,faultTolStruct,...
    phiInitial,phiPrimeInitial,phi_alpha,f_alpha,grad,cEq,cIneq,cIneqUser,cEqUser,JacCeqTransUser,...
    JacCineqTransUser,Ain,bin,Aeq,beq,funcCount,fscale,sizes,options,verbosity,varargin)




































    alpha=1;
    rho=1e-4;
    socTaken=stepFlags.socStep;


    tempFaultTolStruct=faultTolStruct;


    while funcCount<options.MaxFunEvals

        if tempFaultTolStruct.funcEvalWellDefined&&phi_alpha<=phiInitial+alpha*rho*phiPrimeInitial
            exitflag=1;
            return
        end


        alpha=0.7*alpha;

        delta_x=alpha*dir(:);
        if socTaken
            delta_x=delta_x+alpha^2*socDir(:);
        end



        if all(abs(delta_x)<options.TolX*max(1,abs(xInitial)))
            exitflag=-2;
            return
        end

        xCurrent=xInitial+delta_x;


        [f_alpha,grad,cIneq,cEq,JacCineqTransUser,JacCeqTransUser,tempFaultTolStruct,cIneqUser,cEqUser]=...
        evalObjAndConstr(funfcn,confcn,xCurrent,fscale,f_alpha,grad,cIneq,cEq,Aeq,beq,Ain,bin,...
        JacCeqTransUser,JacCineqTransUser,false,options,sizes,verbosity,varargin{:});
        funcCount=funcCount+1;


        phi_alpha=meritFcnL1(tempFaultTolStruct.funcEvalWellDefined,mu,f_alpha,cEq,cIneq);

        if verbosity>=3



            if tempFaultTolStruct.undefObj||tempFaultTolStruct.undefConstr
                faultTolStruct=tempFaultTolStruct;
            end
        end
    end

    exitflag=0;
