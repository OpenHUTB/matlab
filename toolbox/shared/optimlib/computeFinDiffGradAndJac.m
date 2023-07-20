function[grad,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=...
    computeFinDiffGradAndJac(xCurrent,funfcn,confcn,fval,cIneq,cEq,grad,...
    JacCineqTrans,JacCeqTrans,lb,ub,fscale,options,finDiffFlags,sizes,varargin)












    evalOK=true;
    useParallel=validateopts_UseParallel(options.UseParallel,true,true);


    if iscell(funfcn)&&iscell(confcn)
        finDiffObj=strcmp(funfcn{1},'fun');
        finDiffConstr=strcmp(confcn{1},'fun');
        objfun=funfcn{3};
        confun=confcn{3};
    else
        finDiffObj=~isempty(funfcn);
        finDiffConstr=~isempty(confcn);
        objfun=funfcn;
        confun=confcn;
    end

    if~useParallel
        if finDiffObj&&finDiffConstr


            [grad,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=finitedifferences(xCurrent,...
            objfun,confun,lb,ub,fval,cIneq,cEq,1:sizes.nVar,options,sizes,...
            grad,JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin{:});
        elseif finDiffObj

            [grad,~,~,numEvals,evalOK]=finitedifferences(xCurrent,...
            objfun,[],lb,ub,fval,[],[],1:sizes.nVar,options,sizes,...
            grad,[],[],finDiffFlags,fscale,varargin{:});
        elseif finDiffConstr


            [~,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=finitedifferences(xCurrent,...
            [],confun,lb,ub,[],cIneq,cEq,1:sizes.nVar,options,sizes,...
            [],JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin{:});
        else

            numEvals=0;
        end
    else




        if finDiffObj&&finDiffConstr


            [grad,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=parfinitedifferences(xCurrent,...
            lb,ub,fval,cIneq,cEq,1:sizes.nVar,options,sizes,...
            grad,JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin{:});
        elseif finDiffObj

            [grad,~,~,numEvals,evalOK]=parfinitedifferences(xCurrent,...
            lb,ub,fval,[],[],1:sizes.nVar,options,sizes,...
            grad,[],[],finDiffFlags,fscale,varargin{:});
        elseif finDiffConstr


            [~,JacCineqTrans,JacCeqTrans,numEvals,evalOK]=parfinitedifferences(xCurrent,...
            lb,ub,[],cIneq,cEq,1:sizes.nVar,options,sizes,...
            [],JacCineqTrans,JacCeqTrans,finDiffFlags,fscale,varargin{:});
        else

            numEvals=0;
        end
    end
