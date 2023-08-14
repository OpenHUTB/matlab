function[evalOK,fplus,cIneqPlus,cEqPlus]=finDiffEvalAndChkErr(objfun,confun,...
    dim,delta,xCurrent,finDiffFlags,fscale,sizes,varargin)















    evalOK=true;

    fplus=[];cIneqPlus=[];cEqPlus=[];

    xCurrent(dim)=xCurrent(dim)+delta;

    if~isempty(objfun)
        fplus=feval(objfun,reshape(xCurrent,sizes.xShape),varargin{:});
        if finDiffFlags.scaleObjConstr
            fplus=fscale.obj*fplus;
        end


        if finDiffFlags.chkFunEval
            if isscalar(fplus)

                evalOK=isfinite(fplus)&&...
                (~finDiffFlags.chkComplexObj||isreal(fplus));
            else


                evalOK=all(isfinite(fplus(:)))&&...
                (~finDiffFlags.chkComplexObj||isreal(fplus));
            end
            if~evalOK
                return
            end
        end
    end

    if~isempty(confun)
        [cIneqPlus,cEqPlus]=feval(confun,reshape(xCurrent,sizes.xShape),varargin{:});
        cIneqPlus=cIneqPlus(:);cEqPlus=cEqPlus(:);
        if finDiffFlags.scaleObjConstr
            cIneqPlus=fscale.cIneq.*cIneqPlus;
            cEqPlus=fscale.cEq.*cEqPlus;
        end


        if finDiffFlags.chkFunEval&&(any(~isfinite([cIneqPlus;cEqPlus]))||~isreal([cIneqPlus;cEqPlus]))
            evalOK=false;
        end
    end
