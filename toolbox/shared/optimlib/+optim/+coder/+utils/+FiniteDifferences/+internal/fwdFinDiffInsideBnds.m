function[delta_i,modifiedStep]=fwdFinDiffInsideBnds(xC_i,lb_i,ub_i,delta_i)

















%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(lb_i,{'double'},{'scalar'});
    validateattributes(ub_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});

    modifiedStep=false;


    if lb_i~=ub_i&&xC_i>=lb_i&&xC_i<=ub_i
        if(xC_i+delta_i>ub_i)||(xC_i+delta_i<lb_i)
            delta_i=-delta_i;
            modifiedStep=true;
            if(xC_i+delta_i>ub_i)||(xC_i+delta_i<lb_i)
                lbDiff=xC_i-lb_i;
                ubDiff=ub_i-xC_i;
                if(lbDiff<=ubDiff)
                    newDelta=lbDiff;
                    delta_i=-newDelta;
                else
                    newDelta=ubDiff;
                    delta_i=newDelta;
                end
            end
        end
    end

end