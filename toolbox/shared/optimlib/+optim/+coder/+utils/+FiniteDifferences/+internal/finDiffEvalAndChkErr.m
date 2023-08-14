function[evalOK,fplus,cIneqPlus,cEqPlus,xk,obj]=...
    finDiffEvalAndChkErr(obj,fplus,cIneqPlus,cEqPlus,dim,delta,xk,...
    hasNonFinite,ScaleProblem,scales,varargin)






























%#codegen

    coder.allowpcode('plain');


    validateattributes(fplus,{'double'},{'scalar'});


    validateattributes(dim,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(delta,{'double'},{'scalar'});

    validateattributes(hasNonFinite,{'logical'},{'scalar'});
    validateattributes(ScaleProblem,{'logical'},{'scalar'});
    validateattributes(scales,{'struct'},{'scalar'});

    coder.internal.prefer_const(obj,hasNonFinite,ScaleProblem,scales,varargin{:});

    INT_ONE=coder.internal.indexInt(1);


    evalOK=true;


    temp=xk(dim);
    xk(dim)=xk(dim)+delta;



    if~(isempty(obj.objfun)||obj.SpecifyObjectiveGradient)

        fplus(:)=obj.objfun(xk,varargin{:});



        if(ScaleProblem)
            fplus(:)=scales.objective*fplus;
        end

        if hasNonFinite
            evalOK(:)=isfinite(fplus);

            if~evalOK
                return;
            end
        end
    end


    if~(isempty(obj.nonlin)||obj.SpecifyConstraintGradient)

        [cIneqPlus(:),cEqPlus(:)]=obj.nonlin(xk,varargin{:});



        if(ScaleProblem)
            for idx=1:obj.mIneq
                cIneqPlus(idx)=cIneqPlus(idx)*scales.cineq_constraint(idx);
            end
            for idx=1:obj.mEq
                cEqPlus(idx)=cEqPlus(idx)*scales.ceq_constraint(idx);
            end
        end

        if hasNonFinite
            idx=INT_ONE;
            while(evalOK&&idx<=obj.mIneq)
                evalOK=isfinite(cIneqPlus(idx));
                idx=idx+1;
            end

            if~evalOK
                return;
            end

            idx=INT_ONE;
            while(evalOK&&idx<=obj.mEq)
                evalOK=isfinite(cEqPlus(idx));
                idx=idx+1;
            end
        end
    end


    xk(dim)=temp;

end