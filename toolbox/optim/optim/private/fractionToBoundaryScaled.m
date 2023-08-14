function[alpha,fullStep]=fractionToBoundaryScaled(scaledDir_s,bndryThresh)














    negElements_idx=scaledDir_s<-eps;
    if any(negElements_idx)
        alphaToBoundary=min(-bndryThresh./scaledDir_s(negElements_idx));
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
