function runWorkflow(obj)





    disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSolverConfigurationCheckTitle').getString(),' ==']);
    obj.checkSolverConfiguration();


    disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSwitchedLinearCheckTitle').getString(),' ==']);
    obj.checkSwitchedLinear();


    if strcmpi(hdlfeature('SSCHDLModelOrderReduction'),'on')
        disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckTitle').getString(),' ==']);
        if obj.linearize
            disp('    ==Performing Linearization==')
            obj.linearizeSwitches();
        else
            disp('    ==No Model Order Reduction Performed==')
        end
    end


    disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckTitle').getString(),' ==']);
    obj.extractEquations();


    disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeCheckTitle').getString(),' ==']);
    obj.discretizeEquations();


    disp(['== ',message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckTitle').getString(),' ==']);
    obj.generateHDLModel();
end
