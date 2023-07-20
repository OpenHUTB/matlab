function v=validateCoefficients(this,hC)




    v=hdlvalidatestruct;

    FilterStructure=get_param(hC.SimulinkHandle,'FilterStructure');
    slbh=hC.SimulinkHandle;
    progCoeff=strcmpi(get_param(slbh,'CoefSource'),'Input port');



    if strcmpi(get_param(slbh,'CoefSource'),'Input port')&&~strcmpi(FilterStructure,'Direct Form')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:FIRcoefInputNotSupported'));
        return;
    end

    if progCoeff


        sigType=hdlissignaltype(hC.PirInputSignals(2));
        if~(sigType.isrowvec||sigType.isscalar)

            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_Coeffs_notRow','column vector'));
            return;
        end

        if hdlsignaliscomplex(hC.PirInputSignals(1))&&hdlsignaliscomplex(hC.PirInputSignals(2))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validateFrameBased:complexCoefsComplexInputNotSupported'));
            return;
        end
    else
        coefficients=this.hdlslResolve('Coefficients',hC.SimulinkHandle);


        if iscolumn(coefficients)&&~isscalar(coefficients)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_Coeffs_notRow','column vector'));
        end

        if~isvector(coefficients)&&~isscalar(coefficients)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:DFIR_Coeffs_notRow','matrix'));
        end

        if~isreal(coefficients)&&hdlsignaliscomplex(hC.PirInputSignals(1))
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validateFrameBased:complexCoefsComplexInputNotSupported'));
            return;
        end


        sym=checksymmetry(coefficients,0);

        if strcmp(FilterStructure,'Direct form symmetric')&&~strcmp(sym,'symmetric')&&~all(coefficients==0)&&(length(coefficients)>1)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validateFrameBased:symmStructureNotSymmCoefs'));
        end

        if strcmp(FilterStructure,'Direct form antisymmetric')&&~strcmp(sym,'antisymmetric')&&~all(coefficients==0)&&(length(coefficients)>1)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validateFrameBased:antisymmStructureNotAntiSymmCoefs'));
        end
    end

