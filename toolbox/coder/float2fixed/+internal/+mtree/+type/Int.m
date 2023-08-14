




classdef Int<internal.mtree.type.NumericType

    properties(Access=public)
        Signedness(1,1)logical
        Bits(1,1)uint32
    end

    methods(Access=public)

        function this=Int(signed,bits,dimensions,isComplex)
            this=this@internal.mtree.type.NumericType(dimensions,isComplex);

            assert(ismember(bits,[8,16,32,64]),'Not a valid MATLAB integer');

            this.Signedness=signed;
            this.Bits=bits;
        end


        function mode=getOverflowMode(this)
            mode=this.setGetOverflowBehavior;
        end


        function mode=getRoundMode(~)
            mode='Nearest';
        end

        function name=getMLName(this)
            if this.Signedness
                signednessChar='';
            else
                signednessChar='u';
            end

            name=[signednessChar,'int',num2str(this.Bits)];
        end

        function type=toSlName(this)
            if this.Signedness
                signednessChar='';
            else
                signednessChar='u';
            end

            type=[signednessChar,'int',num2str(this.Bits)];
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

        function signed=isSigned(this)
            signed=this.Signedness;
        end

        function wl=getWordLength(this)
            wl=this.Bits;
        end

    end

    methods(Access=protected)

        function type=toPIRLeafType(this)
            if this.Signedness
                type=pir_signed_t(this.Bits);
            else
                type=pir_unsigned_t(this.Bits);
            end
        end

        function realVal=getExampleValueScalarReal(this)
            classname=this.getMLName;
            realVal=cast(1,classname);
        end

        function realStr=getExampleValueStringScalarReal(this)
            classname=this.getMLName;
            realStr=sprintf('%s(1)',classname);
        end

        function res=isTypeEqualScalarReal(this,other)
            if~isa(other,'internal.mtree.type.Int')
                res=false;
            else
                res=(this.Signedness==other.Signedness)&&...
                (this.Bits==other.Bits);
            end
        end

    end

    methods(Static,Access=public)

        function mode_out=setGetOverflowBehavior(mode_in)
            persistent mode;

            if nargout>0
                if isempty(mode)
                    error('Default saturate behavior for integers was never set');
                end

                mode_out=mode;
            end

            if nargin>0
                mode=mode_in;
            end
        end

    end

end
