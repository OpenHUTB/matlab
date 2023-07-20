function v=validateCoefficients(this,hC)




    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;

    blockInfo=getBlockInfo(this,slbh);
    coefficients=blockInfo.Coefficients;


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


