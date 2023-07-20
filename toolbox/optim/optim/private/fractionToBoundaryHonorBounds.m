function[alpha,fullStep]=...
    fractionToBoundaryHonorBounds(x,lb,ub,xIndices,dir_x,bndryThresh)













    negElementsLb_idx=xIndices.finiteLb&dir_x<-eps;
    if any(negElementsLb_idx)
        alphaToBoundaryLb=min(-bndryThresh*(x(negElementsLb_idx)-lb(negElementsLb_idx))./dir_x(negElementsLb_idx));
    else
        alphaToBoundaryLb=1.0;
    end
    negElementsUb_idx=xIndices.finiteUb&dir_x>eps;
    if any(negElementsUb_idx)
        alphaToBoundaryUb=min(-bndryThresh*(x(negElementsUb_idx)-ub(negElementsUb_idx))./dir_x(negElementsUb_idx));
    else
        alphaToBoundaryUb=1.0;
    end
    alphaToBoundary=min(alphaToBoundaryLb,alphaToBoundaryUb);
    if alphaToBoundary<1.0
        fullStep=false;
        alpha=alphaToBoundary;
    else
        fullStep=true;
        alpha=1.0;
    end
