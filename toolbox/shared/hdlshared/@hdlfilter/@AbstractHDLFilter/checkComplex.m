function v=checkComplex(this)






    v=struct('Status',0,'Message','','MessageID','');
    if this.getHDLParameter('filter_complex_inputs')
        if~this.isComplexInputSupported
            msg='Complex Inputs are not supported.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotsupported');
            return
        end
    end

    if~isreal(this.Coefficients)
        if~this.isComplexCoeffSupported
            msg='Complex Coefficients are not supported.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexCoeffnotsupported');
            return
        end
    end

