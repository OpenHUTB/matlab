function[fval,grad,cIneq,cEq,JacCineqTrans,JacCeqTrans,faultTolStruct,cIneqUser,cEqUser]=...
    evalObjAndConstr(funfcn,confcn,x,fscale,fval,grad,cIneq,cEq,Aeq,beq,A,b,...
    JacCeqTrans,JacCineqTrans,evalGrads,options,sizes,verbosity,varargin)

























    mNonlinIneq=sizes.mNonlinIneq;
    mNonlinEq=sizes.mNonlinEq;

    faultTolStruct.undefObj=false;
    faultTolStruct.undefConstr=false;
    faultTolStruct.funcEvalWellDefined=true;
    faultTolStruct.undefValue='';

    if~evalGrads

        if~isempty(confcn{1})
            [cIneqUser,cEqUser]=feval(confcn{3},reshape(x,sizes.xShape),varargin{:});

            cIneqUser=-full(cIneqUser(:));cEqUser=full(cEqUser(:));
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                if mNonlinIneq>0
                    cIneqUser=fscale.cIneq.*cIneqUser;
                end
                if mNonlinEq>0
                    cEqUser=fscale.cEq.*cEqUser;
                end
            end
        else
            cIneqUser=zeros(0,1);cEqUser=zeros(0,1);
        end


        cEq=[Aeq*x-beq
        cEqUser];

        cIneq=[A*x-b
        cIneqUser];
    else



        if strcmp(confcn{1},'fun_then_grad')
            [JacCineqTrans,JacCeqTrans]=...
            feval(confcn{4},reshape(x,sizes.xShape),varargin{:});

            JacCeqTrans=full(JacCeqTrans);
            JacCineqTrans=full(JacCineqTrans);
            if strcmpi(options.ScaleProblem,'obj-and-constr')


                if mNonlinEq==1
                    JacCeqTrans=JacCeqTrans*fscale.cEq;
                else
                    JacCeqTrans=JacCeqTrans*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
                end
                if mNonlinIneq==1
                    JacCineqTrans=JacCineqTrans*fscale.cIneq;
                else
                    JacCineqTrans=JacCineqTrans*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
                end
            end
        elseif strcmp(confcn{1},'fungrad')
            [cIneqUser,cEqUser,JacCineqTrans,JacCeqTrans]=...
            feval(confcn{3},reshape(x,sizes.xShape),varargin{:});

            cIneqUser=-full(cIneqUser(:));cEqUser=full(cEqUser(:));
            JacCeqTrans=full(JacCeqTrans);
            JacCineqTrans=full(JacCineqTrans);
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                if mNonlinIneq>0
                    cIneqUser=fscale.cIneq.*cIneqUser;
                end
                if mNonlinEq>0
                    cEqUser=fscale.cEq.*cEqUser;
                end


                if mNonlinEq==1
                    JacCeqTrans=JacCeqTrans*fscale.cEq;
                else
                    JacCeqTrans=JacCeqTrans*spdiags(fscale.cEq,0,mNonlinEq,mNonlinEq);
                end
                if mNonlinIneq==1
                    JacCineqTrans=JacCineqTrans*fscale.cIneq;
                else
                    JacCineqTrans=JacCineqTrans*spdiags(fscale.cIneq,0,mNonlinIneq,mNonlinIneq);
                end
            end
        end
    end


    allConstr=[cIneq;cEq];
    if any(~isfinite(allConstr))||any(~isreal(allConstr))
        faultTolStruct.undefConstr=true;
        faultTolStruct.funcEvalWellDefined=false;
        if verbosity>=3
            if any(isnan(allConstr))
                faultTolStruct.undefValue='NaN';
            elseif any(~isfinite(allConstr))
                faultTolStruct.undefValue='Inf';
            else
                faultTolStruct.undefValue='complex';
            end
        end
        fval=Inf;
    elseif~evalGrads

        fval=feval(funfcn{3},reshape(x,sizes.xShape),varargin{:});
        if strcmpi(options.ScaleProblem,'obj-and-constr')
            fval=fscale.obj*fval;
        end
        if~isfinite(fval)||~isreal(fval)
            faultTolStruct.undefObj=true;
            faultTolStruct.funcEvalWellDefined=false;
            if verbosity>=3
                if isnan(fval)
                    faultTolStruct.undefValue='NaN';
                elseif~isfinite(fval)
                    faultTolStruct.undefValue='Inf';
                else
                    faultTolStruct.undefValue='complex';
                end
            end
            fval=Inf;
        end
    else


        if strcmp(funfcn{1},'fun_then_grad')
            grad(:)=feval(funfcn{4},reshape(x,sizes.xShape),varargin{:});

            grad=full(grad);
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                grad=fscale.obj*grad;
            end
        elseif strcmp(funfcn{1},'fungrad')
            [fval,grad(:)]=feval(funfcn{3},reshape(x,sizes.xShape),varargin{:});

            grad=full(grad);
            if strcmpi(options.ScaleProblem,'obj-and-constr')
                fval=fscale.obj*fval;grad=fscale.obj*grad;
            end
        end
    end
