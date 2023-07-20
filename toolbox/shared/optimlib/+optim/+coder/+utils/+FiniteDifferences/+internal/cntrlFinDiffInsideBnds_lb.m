function[delta_i,formulaType]=cntrlFinDiffInsideBnds_lb(xC_i,lb_i,delta_i)




























%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(lb_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});



    formulaType=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('Central'));


    if(xC_i>=lb_i)
        if(xC_i-delta_i<lb_i)

            formulaType=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleRight'));
        end
    end

end