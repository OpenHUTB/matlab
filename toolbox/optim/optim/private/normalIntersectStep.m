function[scaledNormalIntersectStep,isCauchy]=normalIntersectStep(scaledNormalCauchyStep,...
    scaledNormalNewtonStep,bndryThresh_normal,trRadius_normal,sizes)











    nVar=sizes.nVar;
    isCauchy=false;





    term1=scaledNormalCauchyStep'*scaledNormalNewtonStep;
    cauchyStepSquaredNorm=scaledNormalCauchyStep'*scaledNormalCauchyStep;
    newtonStepSquaredNorm=scaledNormalNewtonStep'*scaledNormalNewtonStep;
    term2=newtonStepSquaredNorm+cauchyStepSquaredNorm-2*term1;
    term3=term1-cauchyStepSquaredNorm;
    term4=trRadius_normal^2-cauchyStepSquaredNorm;

    if newtonStepSquaredNorm<=trRadius_normal^2
        gamma=1.0;
    elseif term2<=0||term4<=0






        gamma=0.0;
    else



        gamma=-term3+sqrt(term3^2+term2*term4);
        gamma=gamma/term2;
    end






    scaledNormalCauchy_slack=scaledNormalCauchyStep(nVar+1:end,1);
    scaledNormalNewton_slack=scaledNormalNewtonStep(nVar+1:end,1);


    cauchyFracToBound_idx=scaledNormalCauchy_slack>=-bndryThresh_normal;


    idx=cauchyFracToBound_idx&scaledNormalNewton_slack-scaledNormalCauchy_slack<0;
    tauMax=min((-bndryThresh_normal-scaledNormalCauchy_slack(idx))./...
    (scaledNormalNewton_slack(idx)-scaledNormalCauchy_slack(idx)));
    if isempty(tauMax)

        tauMax=gamma;
    end
    tauMax=min(tauMax,gamma);


    cnVecPos_idx=scaledNormalNewton_slack-scaledNormalCauchy_slack>0;
    if any(~cauchyFracToBound_idx&~cnVecPos_idx)



        isCauchy=true;
        tauMin=0.0;
    else
        idx=~cauchyFracToBound_idx&cnVecPos_idx;
        tauMin=max((-bndryThresh_normal-scaledNormalCauchy_slack(idx))./...
        (scaledNormalNewton_slack(idx)-scaledNormalCauchy_slack(idx)));
        if isempty(tauMin)

            tauMin=0.0;
        end
        tauMin=max(tauMin,0.0);
    end

    if tauMax<tauMin||isCauchy
        tauIntersect=0.0;
        isCauchy=true;
    else
        tauIntersect=tauMax;
        isCauchy=false;
    end


    scaledNormalIntersectStep=scaledNormalCauchyStep+...
    tauIntersect*(scaledNormalNewtonStep-scaledNormalCauchyStep);

