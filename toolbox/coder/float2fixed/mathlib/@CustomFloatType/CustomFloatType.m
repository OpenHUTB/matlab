%#codegen


classdef CustomFloatType
    properties
WordLength
MantissaLength
ExponentLength
ExponentBias

Exponent_Inf_or_NaN
Mantissa_NaN


Log2IntermediatePrec
Log2NumberOfIterations


Pow2IntermediatePrec
Pow2NumberOfIterations


Pow10IntermediatePrec
Pow10NumberOfIterations


PowIntermediateLog2Prec
PowNumberOfLog2Iterations
PowIntermediatePow2Prec
PowNumberOfPow2Iterations


SinhCubicExponent
SinhIntermediatePrec
SinhNumberOfIterations


TanhCubicExponent
TanhIntermediatePrec
TanhNumberOfIterations


HypotIntermediatePrec
    end

    methods
        function this=CustomFloatType(wl,ml)
            coder.allowpcode('plain');
            assert(wl>ml+2,'WordLength needs to be at least 3 more than MantissaLength');
            this.WordLength=coder.const(int32(wl));
            this.MantissaLength=coder.const(int32(ml));
            this.ExponentLength=coder.const(wl-ml-1);
            this.ExponentBias=coder.const(int32(2^(this.ExponentLength-1)-1));

            this.Exponent_Inf_or_NaN=coder.const(bitcmp(fi(0,0,this.ExponentLength,0)));
            this.Mantissa_NaN=coder.const(bitset(fi(0,0,this.MantissaLength,0),this.MantissaLength));

            this.Log2NumberOfIterations=coder.const(ceil(this.MantissaLength-1)/2);
            this.Log2IntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.Log2NumberOfIterations+1)))+1);

            this.Pow2NumberOfIterations=coder.const(ceil(this.MantissaLength)/2);
            this.Pow2IntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.Pow2NumberOfIterations+1)))+1);

            this.Pow10NumberOfIterations=coder.const(ceil(this.MantissaLength)/2);
            this.Pow10IntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.Pow10NumberOfIterations+1)))+3);

            this.PowNumberOfLog2Iterations=coder.const(ceil(this.WordLength-1)/2);
            this.PowIntermediateLog2Prec=coder.const(this.WordLength+ceil(log2(double(this.PowNumberOfLog2Iterations+1)))+3);
            this.PowNumberOfPow2Iterations=coder.const(ceil(this.MantissaLength)/2)+0;
            this.PowIntermediatePow2Prec=coder.const(this.MantissaLength+ceil(log2(double(this.PowNumberOfPow2Iterations+1)))+3);



            this.SinhCubicExponent=coder.const(ceil((this.MantissaLength-4)/4));
            this.SinhNumberOfIterations=coder.const(ceil((this.MantissaLength+this.SinhCubicExponent)/2));
            this.SinhIntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.SinhNumberOfIterations+1)))+...
            this.SinhCubicExponent);



            this.TanhCubicExponent=coder.const(ceil((this.MantissaLength+1)/4));
            this.TanhNumberOfIterations=coder.const(floor((this.MantissaLength+this.TanhCubicExponent)/2)-1);
            this.TanhIntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.TanhNumberOfIterations+1)))+...
            this.TanhCubicExponent);


            this.HypotIntermediatePrec=coder.const(this.MantissaLength+ceil(log2(double(this.MantissaLength+1))));
        end

        function obj=eq(this,cft)
            if~isa(cft,'CustomFloatType')
                obj=false;
            else
                obj=((this.WordLength==cft.WordLength)&&(this.MantissaLength==cft.MantissaLength));
            end
        end

        function obj=ne(this,cft)
            obj=~eq(this,cft);
        end

        function disp(this)
            tmp=sprintf('float%d_m%d',this.WordLength,this.MantissaLength);

            switch tmp
            case 'float16_m10',type='Floating-point: Half-precision';
            case 'float32_m23',type='Floating-point: Single-precision';
            case 'float64_m52',type='Floating-point: Double-precision';
            otherwise,type='Floating-point: Custom-precision';
            end

            fprintf('\n');
            fprintf('%20s: %s\n','Data Type',type);
            fprintf('%20s: %3d\n','WordLength',this.WordLength);
            fprintf('%20s: %3d\n','MantissaLength',this.MantissaLength);
            fprintf('%20s: %3d\n','ExponentLength',this.ExponentLength);
            fprintf('%20s: %3d\n','ExponentBias',this.ExponentBias);
        end
    end

    methods(Static=true)
        function c=matlabCodegenNontunableProperties(~)
            c={'WordLength','MantissaLength','ExponentLength','ExponentBias',...
            'Exponent_Inf_or_NaN','Mantissa_NaN',...
            'Log2IntermediatePrec','Log2NumberOfIterations',...
            'Pow2IntermediatePrec','Pow2NumberOfIterations',...
            'Pow10IntermediatePrec','Pow10NumberOfIterations',...
            'PowIntermediateLog2Prec','PowNumberOfLog2Iterations',...
            'PowIntermediatePow2Prec','PowNumberOfPow2Iterations',...
            'SinhCubicExponent','SinhIntermediatePrec','SinhNumberOfIterations',...
            'TanhCubicExponent','TanhIntermediatePrec','TanhNumberOfIterations',...
            'HypotIntermediatePrec'};
        end
    end
end