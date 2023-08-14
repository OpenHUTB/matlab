function v=checkComplex(this)






    v=struct('Status',0,'Message','','MessageID','');
    if this.getHDLParameter('filter_complex_inputs')
        if~this.isComplexInputSupported
            msg='Complex Inputs are not supported.';
            v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexinputnotsupported');
            return
        end
    end


    for n=1:length(this.Stage)
        if hasPolyphaseCoeffs(this.Stage(n))
            if~isreal(this.Stage(n).PolyphaseCoefficients)
                msg='HDL code generation is not supported for cascades if any stage has complex coefficients.';
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexcoeffsnotsupported');
                return
            end
        elseif hasNoCoefficients(this.Stage(n))

        elseif isa(this.Stage(n),'hdlfilter.scalar')
            if~isreal(this.Stage(n).Gain)
                msg='HDL code generation is not supported for cascades if any stage has complex coefficients.';
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexcoeffsnotsupported');
                return
            end
        else
            if~isreal(this.Stage(n).Coefficients)
                msg='HDL code generation is not supported for cascades if any stage has complex coefficients.';
                v=struct('Status',1,'Message',msg,'MessageID','HDLShared:hdlfilter:complexcoeffsnotsupported');
                return
            end
        end
    end



    function success=hasPolyphaseCoeffs(hdlfilterobj)

        success=...
        isa(hdlfilterobj,'hdlfilter.linearinterp')||...
        isa(hdlfilterobj,'hdlfilter.firinterp')||...
        isa(hdlfilterobj,'hdlfilter.firdecim')||...
        isa(hdlfilterobj,'hdlfilter.firtdecim');

        function success=hasNoCoefficients(hdlfilterobj)

            success=...
            isa(hdlfilterobj,'hdlfilter.cicdecim')||...
            isa(hdlfilterobj,'hdlfilter.cicinterp')||...
            isa(hdlfilterobj,'hdlfilter.holdinterp')||...
            isa(hdlfilterobj,'hdlfilter.delay');

