




classdef Fi<internal.mtree.type.NumericType

    properties(Access=public)
        Numerictype(1,1)
        Fimath(1,1)embedded.fimath
    end

    methods
        function set.Numerictype(this,ntIn)
            if~isa(ntIn,'embedded.numerictype')
                error('Property ''Numerictype'' must be an ''embedded.numerictype''');
            end

            this.Numerictype=ntIn;
        end
    end

    methods(Access=public)

        function this=Fi(numerictype,fimath,dimensions,isComplex)
            this=this@internal.mtree.type.NumericType(dimensions,isComplex);
            this.Numerictype=numerictype;
            this.Fimath=fimath;
        end

        function name=getMLName(this)
            name=this.Numerictype.tostring;
        end

        function type=toSlName(this)
            type=this.Numerictype.tostringInternalFixdt;
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end


        function mode=getRoundMode(this)
            mode=this.Fimath.RoundingMethod;
        end


        function mode=getOverflowMode(this)
            mode=this.Fimath.OverflowAction;
        end

        function signed=isSigned(this)
            signed=this.Numerictype.SignednessBool;
        end

        function wl=getWordLength(this)
            wl=this.Numerictype.WordLength;
        end

        function b=getSlope(this)
            b=this.Numerictype.Slope;
        end

        function b=getBias(this)
            b=this.Numerictype.Bias;
        end

        function sb=isSlopeBias(this)
            sb=this.Numerictype.isscalingslopebias;
        end

        function f=isFixed(this)
            f=this.Numerictype.isfixed;
        end

    end

    methods(Access=protected)

        function type=toPIRLeafType(this)
            fl=this.Numerictype.FractionLength;
            if fl==0
                if this.isSigned
                    type=pir_signed_t(this.getWordLength);
                else
                    type=pir_unsigned_t(this.getWordLength);
                end
            else
                type=pir_fixpt_t(this.isSigned,this.getWordLength,-fl);
            end
        end

        function realVal=getExampleValueScalarReal(this)
            realVal=eps(this.Numerictype);
            realVal.fimath=this.Fimath;
        end

        function realStr=getExampleValueStringScalarReal(this)
            realVal=this.getExampleValueScalarReal;
            realStr=realVal.tostring;
        end

        function res=isTypeEqualScalarReal(this,other)
            if~isa(other,'internal.mtree.type.Fi')
                res=false;
            else
                fimathEqual=isequal(this.Fimath,other.Fimath);
                ntEqual=isequal(this.Numerictype,other.Numerictype);

                res=fimathEqual&&ntEqual;
            end
        end

    end

end
