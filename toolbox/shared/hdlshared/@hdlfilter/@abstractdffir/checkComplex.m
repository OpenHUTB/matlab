function v=checkComplex(this)






    v=struct('Status',0,'Message','','MessageID','');
    if this.getHDLParameter('filter_complex_inputs')
        if~(strcmpi(this.implementation,'parallel')||...
            strcmpi(this.implementation,'serial')||...
            strcmpi(this.implementation,'serialcascade'))
            msg=['Complex inputs are not supported for ''',this.implementation,''' implementation.'];
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotsupported');
            return
        end
        coeffs_internal=strcmpi(this.getHDLParameter('filter_coefficient_source'),'internal');
        if~coeffs_internal
            msg='Complex inputs are not supported with processor interface.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotforProcint');
            return
        end
    end

    if~isreal(this.Coefficients)
        if~strcmpi(this.implementation,'parallel')
            msg=['Complex coefficients are not supported for ''',this.implementation,''' implementation.'];
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexCoeffnotsupported');
            return
        end
        coeffs_internal=strcmpi(this.getHDLParameter('filter_coefficient_source'),'internal');
        if~coeffs_internal
            msg='Complex coefficients are not supported with processor interface.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotforProcint');
            return
        end
    end

