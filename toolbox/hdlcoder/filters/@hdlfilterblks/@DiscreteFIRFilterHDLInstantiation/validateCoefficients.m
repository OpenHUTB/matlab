function v=validateCoefficients(this,hC)




    v=hdlvalidatestruct;

    hF=this.createHDLFilterObj(hC);

    coeffs=hF.Coefficients;


    if iscolumn(coeffs)&&~isscalar(coeffs)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_Coeffs_notRow','column vector'));
    end

    if~isvector(coeffs)&&~isscalar(coeffs)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validate:DFIR_Coeffs_notRow','matrix'));
    end


    sym=checksymmetry(coeffs,0);

    if strcmp(hF.FilterStructure,'Discrete FIR Filter - Direct form')&&strcmp(sym,'symmetric')&&~all(coeffs==0)&&(length(coeffs)>1)

        warning(message('HDLShared:hdlfilter:symmetrywarning'));
    end

    if strcmp(hF.FilterStructure,'Discrete FIR Filter - Direct form')&&strcmp(sym,'antisymmetric')&&~all(coeffs==0)&&(length(coeffs)>1)

        warning(message('HDLShared:hdlfilter:asymmetrywarning'));
    end