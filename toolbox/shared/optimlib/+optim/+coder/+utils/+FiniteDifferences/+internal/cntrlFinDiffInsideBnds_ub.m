function[delta_i,formulaType]=cntrlFinDiffInsideBnds_ub(xC_i,ub_i,delta_i)




























%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(ub_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});



    formulaType=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('Central'));


    if(xC_i<=ub_i)
        if(ub_i<xC_i+delta_i)

            formulaType=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleLeft'));
        end
    end

end