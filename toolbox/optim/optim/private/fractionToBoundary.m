function[alpha,fullStep]=fractionToBoundary(z,dir_z,bndryThresh)












    negElements_idx=dir_z<-eps;
    if any(negElements_idx)
        alphaToBoundary=min(-bndryThresh*z(negElements_idx)./dir_z(negElements_idx));
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
