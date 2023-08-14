function[delta_i,modifiedStep]=fwdFinDiffInsideBnds_lb(xC_i,lb_i,delta_i)

















%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(lb_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});

    modifiedStep=false;


    if(xC_i>=lb_i)
        if(xC_i+delta_i<lb_i)
            delta_i=-delta_i;
            modifiedStep=true;
        end
    end

end