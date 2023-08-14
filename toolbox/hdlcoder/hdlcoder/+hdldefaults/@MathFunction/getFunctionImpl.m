function impl=getFunctionImpl(this,hC)



    slbh=hC.SimulinkHandle;
    Fname=get_param(slbh,'Function');

    in=hC.PirInputPorts(1).Signal;
    out=hC.PirOutputPorts(1).Signal;
    isInputValid=targetmapping.isValidDataType(in.Type);
    isOutputValid=targetmapping.isValidDataType(out.Type);




    if isInputValid||isOutputValid
        if targetcodegen.targetCodeGenerationUtils.isAlteraMode()
            switch Fname
            case 'reciprocal'
                if strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson')
                    impl=hdldefaults.ReciprocalNewton();
                else
                    impl=hdldefaults.MathTargetLibrary();
                end
            case{'exp','log'}
                impl=hdldefaults.MathTargetLibrary();
            otherwise,impl='';
            end
        elseif targetcodegen.targetCodeGenerationUtils.isNFPMode()
            switch Fname
            case 'reciprocal'
                if strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson')
                    impl=hdldefaults.ReciprocalNewton();
                else
                    impl=hdldefaults.MathTargetLibrary();
                end
            case{'exp','log','mod','rem','square',...
                'conj','pow','hypot','log10','10^u'}
                impl=hdldefaults.MathTargetLibrary();
            case 'sqrt'
                impl=hdldefaults.SqrtTargetLibrary();
            case 'transpose'
                impl=hdldefaults.Transpose();
            case 'hermitian'
                impl=hdldefaults.Hermitian();
            case 'magnitude^2'
                impl=hdldefaults.MagnitudeSquare();
            otherwise,impl='';
            end
        else
            switch Fname
            case 'conj',impl=hdldefaults.ComplexConjugate();
            case 'hermitian',impl=hdldefaults.Hermitian();
            case 'sqrt',impl=hdldefaults.SqrtFunction();
            case 'transpose',impl=hdldefaults.Transpose();
            case 'magnitude^2',impl=hdldefaults.MagnitudeSquare();
            otherwise,impl='';
            end
        end
    else
        switch Fname
        case 'reciprocal'
            if strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson')
                impl=hdldefaults.ReciprocalNewton();
            else
                impl=hdldefaults.RecipDiv();
            end
        case 'conj',impl=hdldefaults.ComplexConjugate();
        case 'hermitian',impl=hdldefaults.Hermitian();
        case 'sqrt',impl=hdldefaults.SqrtFunction();
        case 'transpose',impl=hdldefaults.Transpose();
        case 'magnitude^2',impl=hdldefaults.MagnitudeSquare();
        otherwise,impl='';
        end
    end

    if(~isempty(impl))

        impl.implParams=this.implParams;
    end
end


