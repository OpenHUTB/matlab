function[delta_i,modifiedStep]=fwdFinDiffInsideBnds_ub(xC_i,ub_i,delta_i)

















%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(ub_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});

    modifiedStep=false;


    if(xC_i<=ub_i)
        if(xC_i+delta_i>ub_i)
            delta_i=-delta_i;
            modifiedStep=true;
        end
    end

end