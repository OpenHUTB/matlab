function[delta_i,formulaType]=cntrlFinDiffInsideBnds(xC_i,lb_i,ub_i,delta_i)




























%#codegen

    coder.allowpcode('plain');


    validateattributes(xC_i,{'double'},{'scalar'});
    validateattributes(lb_i,{'double'},{'scalar'});
    validateattributes(ub_i,{'double'},{'scalar'});
    validateattributes(delta_i,{'double'},{'scalar'});

    CentralDifferencesFormulaID=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('Central'));
    DoubleRightStepFormulaID=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleRight'));
    DoubleLeftStepFormulaID=coder.const(optim.coder.utils.FiniteDifferences.Constants.CentralFiniteDifferenceID('DoubleLeft'));



    formulaType=CentralDifferencesFormulaID;


    if lb_i~=ub_i&&xC_i>=lb_i&&xC_i<=ub_i
        if xC_i-delta_i<lb_i
            if ub_i<xC_i+delta_i

                distNear=min(xC_i-lb_i,ub_i-xC_i);
                distFar=max(xC_i-lb_i,ub_i-xC_i);
                if distNear>=distFar/2


                    delta_i=distNear;
                    formulaType=CentralDifferencesFormulaID;
                else



                    delta_i=distFar/2;


                    if xC_i-lb_i>=ub_i-xC_i
                        formulaType=DoubleLeftStepFormulaID;
                    else
                        formulaType=DoubleRightStepFormulaID;
                    end
                end
            else
                if xC_i+2*delta_i<=ub_i

                    formulaType=DoubleRightStepFormulaID;
                else


                    if xC_i-lb_i>=(ub_i-xC_i)/2


                        delta_i=xC_i-lb_i;
                        formulaType=CentralDifferencesFormulaID;
                    else


                        delta_i=(ub_i-xC_i)/2;
                        formulaType=DoubleRightStepFormulaID;
                    end
                end
            end
        elseif ub_i<xC_i+delta_i
            if lb_i<=xC_i-2*delta_i

                formulaType=DoubleLeftStepFormulaID;
            else


                if ub_i-xC_i>=(xC_i-lb_i)/2


                    delta_i=ub_i-xC_i;
                    formulaType=CentralDifferencesFormulaID;
                else


                    delta_i=(xC_i-lb_i)/2;
                    formulaType=DoubleLeftStepFormulaID;
                end
            end
        end
    end

end