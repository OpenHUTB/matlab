function[scaledNormalNewtonStep,stepType,tau]=normalNewtonStep(AugFactor,...
    c_ip,slacks,normCauchyStep,bndryThresh_normal,trRadius_normal,sizes)












    nVar=sizes.nVar;mEq=sizes.mEq;mIneq=sizes.mIneq;mAll=sizes.mAll;


    scaledNormalNewtonStep=solveAugSystem(AugFactor,...
    zeros(nVar,1),zeros(mIneq,1),c_ip(1:mEq,1),c_ip(mEq+1:mAll,1),...
    slacks,sizes);
    scaledNormalNewtonStep=-scaledNormalNewtonStep;

    normScaledNormalNewtonStep=norm(scaledNormalNewtonStep);








    if normScaledNormalNewtonStep<normCauchyStep-sqrt(eps)







        stepType='suspect';
        tau=[];
    else

        [tau,fullStep]=...
        fractionToBoundaryScaled(scaledNormalNewtonStep(nVar+1:nVar+mIneq,1),...
        bndryThresh_normal);

        if fullStep&&normScaledNormalNewtonStep<=trRadius_normal

            stepType='full';
        else

            stepType='truncated';

            tau=min(tau,trRadius_normal/normScaledNormalNewtonStep);
        end
    end
