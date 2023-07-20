function[scaledNormalStep,c_pred]=normalStep(c_ip,JacTrans_ip,trRadius,...
    AugFactor,slacks,bndryThresh,honorBndsOnlyMode,honorIneqsBndsMode,sizes)











    nVar=sizes.nVar;mIneq=sizes.mIneq;
    trRadius_normal=0.8*trRadius;
    bndryThresh_normal=0.5*bndryThresh;


    [scaledNormalCauchyStep,cauchyTrActive,normCauchyStep]=...
    normalCauchyStep(c_ip,JacTrans_ip,trRadius_normal,AugFactor,slacks,...
    honorBndsOnlyMode,honorIneqsBndsMode,sizes);


    [scaledNormalNewtonStep,normalNewtonStepType,tauN]=...
    normalNewtonStep(AugFactor,c_ip,slacks,normCauchyStep,...
    bndryThresh_normal,trRadius_normal,sizes);


    if strcmpi(normalNewtonStepType,'full')
        normalStepType='newton';
    elseif strcmpi(normalNewtonStepType,'suspect')

        normalStepType='cauchyOnly';
    elseif cauchyTrActive
        normalStepType='cauchy';
    else

        [scaledNormalIntersectStep,intrsctIsCauchy]=normalIntersectStep(scaledNormalCauchyStep,...
        scaledNormalNewtonStep,bndryThresh_normal,trRadius_normal,sizes);

        if intrsctIsCauchy
            normalStepType='cauchy';
        else
            normalStepType='intersect';
        end
    end

    norm_c_ip=norm(c_ip);

    if~strcmpi(normalStepType,'cauchyOnly')

        scaledNormalNewtonStep=tauN*scaledNormalNewtonStep;

        c_pred_newton=tauN*norm_c_ip;
    end



    if strcmpi(normalStepType,'intersect')
        scaledNormalStep=scaledNormalIntersectStep;
        c_pred=norm_c_ip-norm(c_ip+JacTrans_ip'*scaledNormalStep);
    elseif strcmpi(normalStepType,'cauchy')||strcmpi(normalStepType,'cauchyOnly')

        tauC=fractionToBoundaryScaled(scaledNormalCauchyStep(nVar+1:nVar+mIneq,1),bndryThresh_normal);
        scaledNormalStep=tauC*scaledNormalCauchyStep;
        c_pred=norm_c_ip-norm(c_ip+JacTrans_ip'*scaledNormalStep);
    else
        scaledNormalStep=scaledNormalNewtonStep;
        c_pred=c_pred_newton;
    end



    if(strcmpi(normalStepType,'intersect')||strcmpi(normalStepType,'cauchy'))&&...
        c_pred_newton>c_pred

        scaledNormalStep=scaledNormalNewtonStep;
        c_pred=c_pred_newton;
    end


    if c_pred<0
        if~strcmpi(normalStepType,'cauchy')||~strcmpi(normalStepType,'cauchyOnly')


            tauC=fractionToBoundaryScaled(scaledNormalCauchyStep(nVar+1:nVar+mIneq,1),bndryThresh_normal);
            scaledNormalStep=tauC*scaledNormalCauchyStep;
            c_pred=norm_c_ip-norm(c_ip+JacTrans_ip'*scaledNormalStep);
        end
        if c_pred<0

            scaledNormalStep=zeros(nVar+mIneq,1);
            c_pred=0.0;
        end
    end
