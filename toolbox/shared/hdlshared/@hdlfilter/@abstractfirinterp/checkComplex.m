function v=checkComplex(this)





    v=struct('Status',0,'Message','','MessageID','');
    if this.getHDLParameter('filter_complex_inputs')
        if strcmpi(this.implementation,'distributedarithmetic')
            msg=['Complex inputs are not supported for ''',this.implementation,''' implementation.'];
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotsupported');
            return
        end
    end

    if~isreal(this.polyphaseCoefficients)
        if~strcmpi(this.implementation,'parallel')
            msg=['Complex coefficients are not supported for ''',this.implementation,''' implementation.'];
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexCoeffnotsupported');
            return
        end
    end
