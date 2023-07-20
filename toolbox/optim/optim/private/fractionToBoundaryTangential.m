function[alpha,fullStep]=fractionToBoundaryTangential(scaledInteriorStep_s,...
    scaledTangentialDir_s,bndryThresh)
















    negElements_idx=scaledTangentialDir_s<-eps;
    if any(negElements_idx)
        alphaToBoundary=min((-bndryThresh-scaledInteriorStep_s(negElements_idx))...
        ./scaledTangentialDir_s(negElements_idx));
        if alphaToBoundary<1.0
            fullStep=false;
            alpha=alphaToBoundary;
        else
            fullStep=true;
            alpha=1.0;
        end
    else
        alpha=1.0;
        fullStep=true;
    end
