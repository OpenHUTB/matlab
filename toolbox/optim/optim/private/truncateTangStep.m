function[scaledTangentialStep,numFunEvals]=truncateTangStep(scaledTangentialDir,...
    scaledTangentialCauchyDir,projCGIter,scaledNormalStep,Hess,barrierHess_s,...
    initialResidual,bndryThresh,funfcn,confcn,xCurrent,grad,JacCeqTrans,...
    JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,sizes,varargin)












    nVar=sizes.nVar;nPrimal=sizes.nPrimal;
    numFunEvals=0;




    [alpha_s,fullStep]=fractionToBoundaryTangential(scaledNormalStep(nVar+1:nPrimal,1),...
    scaledTangentialDir(nVar+1:nPrimal,1),bndryThresh);

    if~fullStep


        if projCGIter<=1


            scaledTangentialStep=alpha_s*scaledTangentialCauchyDir;
        else

            [HessScaledTangentialDir_x,evalCount]=hessTimesVector(Hess,...
            scaledTangentialDir(1:nVar),funfcn,confcn,xCurrent,grad,...
            JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,...
            sizes,varargin{:});
            numFunEvals=numFunEvals+evalCount;
            curvature=scaledTangentialDir(1:nVar)'*HessScaledTangentialDir_x+...
            sum((scaledTangentialDir(nVar+1:nPrimal,1).^2).*barrierHess_s);
            tangSteihaugObj=0.5*alpha_s^2*curvature+...
            alpha_s*(initialResidual'*scaledTangentialDir);



            [alpha_s_cauchy,fullStepCauchy]=...
            fractionToBoundaryTangential(scaledNormalStep(nVar+1:nPrimal,1),...
            scaledTangentialCauchyDir(nVar+1:nPrimal,1),bndryThresh);
            if~fullStepCauchy



                [HessScaledTangentialCauchyDir_x,evalCount]=hessTimesVector(Hess,...
                scaledTangentialCauchyDir(1:nVar),funfcn,confcn,xCurrent,grad,...
                JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,...
                sizes,varargin{:});
                numFunEvals=numFunEvals+evalCount;
                curvatureCauchy=scaledTangentialCauchyDir(1:nVar)'*HessScaledTangentialCauchyDir_x+...
                sum((scaledTangentialCauchyDir(nVar+1:nPrimal,1).^2).*barrierHess_s);
                tangCauchyObj=0.5*alpha_s_cauchy^2*curvatureCauchy+...
                alpha_s_cauchy*(initialResidual'*scaledTangentialCauchyDir);
                if tangCauchyObj<tangSteihaugObj
                    scaledTangentialStep=alpha_s_cauchy*scaledTangentialCauchyDir;
                else
                    scaledTangentialStep=alpha_s*scaledTangentialDir;
                end
            else



                alpha_s_intersect=...
                fractionToBoundaryTangential(scaledNormalStep(nVar+1:nPrimal,1)+scaledTangentialCauchyDir(nVar+1:nPrimal,1),...
                scaledTangentialDir(nVar+1:nPrimal,1)-scaledTangentialCauchyDir(nVar+1:nPrimal,1),bndryThresh);
                scaledTangentialIntersectStep=scaledTangentialCauchyDir+...
                alpha_s_intersect*(scaledTangentialDir-scaledTangentialCauchyDir);
                [HessScaledTangentialIntersectStep_x,evalCount]=hessTimesVector(Hess,...
                scaledTangentialIntersectStep(1:nVar),funfcn,confcn,xCurrent,...
                grad,JacCeqTrans,JacCineqTrans,lb,ub,xIndices,fscale,lambda_ip,options,...
                sizes,varargin{:});
                numFunEvals=numFunEvals+evalCount;
                curvatureIntersect=scaledTangentialIntersectStep(1:nVar)'*HessScaledTangentialIntersectStep_x+...
                sum((scaledTangentialIntersectStep(nVar+1:nPrimal,1).^2).*barrierHess_s);
                tangIntersectObj=0.5*curvatureIntersect+initialResidual'*scaledTangentialIntersectStep;
                if tangIntersectObj<tangSteihaugObj
                    scaledTangentialStep=scaledTangentialIntersectStep;
                else
                    scaledTangentialStep=alpha_s*scaledTangentialDir;
                end

            end
        end
    else
        scaledTangentialStep=scaledTangentialDir;
    end
