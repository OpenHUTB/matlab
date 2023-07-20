






































%#codegen


classdef emlhalf<matlab.mixin.internal.indexing.Paren&matlab.mixin.internal.indexing.ParenAssign&coder.mixin.internal.indexing.ParenAssign
    properties(Access='private')




Value
    end





    properties(Constant,Hidden)
        Type=CustomFloatType(16,10);
        SingleType=CustomFloatType(32,23);
        DoubleType=CustomFloatType(64,52);

        WordLength=emlhalf.Type.WordLength;
        MantissaLength=emlhalf.Type.MantissaLength;
        ExponentLength=emlhalf.Type.ExponentLength;
        ExponentBias=emlhalf.Type.ExponentBias;
    end

    properties(Constant,Access='private')

        LogTable=coder.customfloat.helpers.generateLogTable(CustomFloatType(16,10));
        LogMinusTable=coder.customfloat.helpers.generateLogMinusTable(CustomFloatType(16,10));
        LogExpTable=coder.customfloat.helpers.generateLogExpTable_Denormal(CustomFloatType(16,10));


        Log2TableForExp=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'exp');
        Log2MinusTableForExp=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'exp');
        Log2_E=coder.customfloat.helpers.generateLog2_E(CustomFloatType(16,10));


        Log2TableForLog2=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'log2');
        Log2MinusTableForLog2=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'log2');
        Log2E=coder.customfloat.helpers.generateLog2E(CustomFloatType(16,10));


        Ln2=coder.customfloat.helpers.generateLn2(CustomFloatType(16,10));


        Log10Table=coder.customfloat.helpers.generateLog10Table(CustomFloatType(16,10));
        Log10MinusTable=coder.customfloat.helpers.generateLog10MinusTable(CustomFloatType(16,10));
        Log4thRoot10E=coder.customfloat.helpers.generateLog4thRoot10E(CustomFloatType(16,10));
        Log10ExpTable=coder.customfloat.helpers.generateLog10ExpTable_Denormal(CustomFloatType(16,10));


        Log2TableForPow2_Pow=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'power_pow2');
        Log2MinusTableForPow2_Pow=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'power_pow2');
        Log2TableForLog2_Pow=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'power_log2');
        Log2MinusTableForLog2_Pow=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'power_log2');
        Log2E_Pow=coder.customfloat.helpers.generateLog2E(CustomFloatType(16,10),'pow');
        Ln2_Pow=coder.customfloat.helpers.generateLn2(CustomFloatType(16,10),'pow');


        Log2TableForSinh=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'sinh');
        Log2MinusTableForSinh=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'sinh');
        Ln2_ForSinh=coder.customfloat.helpers.generateLn2(CustomFloatType(16,10),'sinh');
        Log2_E_ForSinh=coder.customfloat.helpers.generateLog2_E(CustomFloatType(16,10),'sinh');


        Log2TableForTanh=coder.customfloat.helpers.generateLog2Table(CustomFloatType(16,10),'tanh');
        Log2MinusTableForTanh=coder.customfloat.helpers.generateLog2MinusTable(CustomFloatType(16,10),'tanh');
        Ln2_ForTanh=coder.customfloat.helpers.generateLn2(CustomFloatType(16,10),'tanh');
        Log2_E_ForTanh=coder.customfloat.helpers.generateLog2_E(CustomFloatType(16,10),'tanh');


        TwoOverPi=coder.customfloat.helpers.half.generateConst('sin');
        SinTwoOverPiTable=coder.customfloat.helpers.half.generateConstOverPiTable('sin');
        SinLinearApproxSlope=coder.customfloat.helpers.half.generateSlope('sin');
        SinLinearApproxIntercept=coder.customfloat.helpers.half.generateIntercept('sin');


        CosTwoOverPiTable=coder.customfloat.helpers.half.generateConstOverPiTable('cos');
        CosLinearApproxSlope=coder.customfloat.helpers.half.generateSlope('cos');
        CosLinearApproxIntercept=coder.customfloat.helpers.half.generateIntercept('cos');


        FourOverPi=coder.customfloat.helpers.half.generateConst('tan');
        TanFourOverPiTable=coder.customfloat.helpers.half.generateConstOverPiTable('tan');
        TanLinearApproxSlope=coder.customfloat.helpers.half.generateSlope('tan');
        TanLinearApproxIntercept=coder.customfloat.helpers.half.generateIntercept('tan');


        PiOverTwoExponent=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi/2,'exponent');
        PiOverTwoMantissa=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi/2,'mantissa');
        PiExponent=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi,'exponent');
        PiMantissa=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi,'mantissa');
        TwoPiExponent=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),2*pi,'exponent');
        TwoPiMantissa=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),2*pi,'mantissa');


        AsinApproxSlopeTable=coder.customfloat.helpers.half.getInvTrigFcnSlopeTable('asin');
        AsinApproxInterceptTable=coder.customfloat.helpers.half.getInvTrigFcnInterceptTable('asin');
        AsinLookupTablePos=coder.customfloat.helpers.half.generateInvTrigFcnLookupTablePos('asin',0.90625);


        Pi=coder.customfloat.helpers.half.generateConst('acos');
        AcosApproxSlopeTable=coder.customfloat.helpers.half.getInvTrigFcnSlopeTable('acos');
        AcosApproxInterceptTable=coder.customfloat.helpers.half.getInvTrigFcnInterceptTable('acos');
        AcosLookupTablePos=coder.customfloat.helpers.half.generateInvTrigFcnLookupTablePos('acos',0.875);
        AcosLookupTableNeg=coder.customfloat.helpers.half.generateInvTrigFcnLookupTableNeg('acos',-0.875);


        PiOverTwo=coder.customfloat.helpers.half.generateConst('atan');
        AtanApproxSlopeTable=coder.customfloat.helpers.half.getInvTrigFcnSlopeTable('atan');
        AtanApproxInterceptTable=coder.customfloat.helpers.half.getInvTrigFcnInterceptTable('atan');


        HypotScalingFactor=coder.customfloat.helpers.generateHypotScalingFactor(CustomFloatType(16,10));


        PiOverFourExponent=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi/4,'exponent');
        PiOverFourMantissa=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),pi/4,'mantissa');
        ThreePiOverFourExponent=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),3*pi/4,'exponent');
        ThreePiOverFourMantissa=coder.customfloat.helpers.half.generateConstComponents(CustomFloatType(16,10),3*pi/4,'mantissa');


        SignMask=bitset(uint16(0),16);
        ExponentMask=bitsll(uint16(2^emlhalf.ExponentLength-1),emlhalf.MantissaLength);
        MantissaMask=uint16(2^emlhalf.MantissaLength-1);
        ExponentMantissaMask=bitcmp(emlhalf.SignMask);
    end




    methods

        function this=emlhalf(x,tpcast)
            coder.inline('never');
            coder.allowpcode('plain');

            narginchk(1,2);

            if(nargin<2)
                tpcast=false;
            end

            if isa(x,'emlhalf')
                this.Value=x.Value;
            elseif isa(x,'half')
                this.Value=storedInteger(x);
            else
                if(tpcast)
                    switch class(x)
                    case 'uint16'
                        this.Value=x;
                    case 'int16'
                        if coder.internal.isConst(x)
                            this.Value=coder.const(@feval,'coder.customfloat.helpers.typecast.int16ToUint16',x);
                        else
                            this.Value=coder.customfloat.helpers.typecast.int16ToUint16(x);
                        end
                    case 'embedded.fi'
                        assert((x.WordLength==16),'The word length of the input must be 16');
                        this.Value=storedInteger(reinterpretcast(x,numerictype(0,16,0)));
                    case 'CustomFloat'
                        assert((x.WordLength==16),'The word length of the input must be 16');
                        this.Value=storedInteger(storedFi(x));
                    otherwise
                        error('Input datatype %s is not supported',class(x));
                    end
                else
                    this.Value=storedInteger(storedFi(CustomFloat(x,CustomFloatType(16,10))));
                end
            end
        end


        function obj=half(this)
            obj=half.typecast(this.Value);
        end


        function obj=single(this)
            tmp=coder.nullcopy(zeros(size(this),'uint32'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.cf2cf(CustomFloatType(32,23),aSign,aExponent,aMantissa,CustomFloatType(16,10));

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            if coder.internal.isConst(tmp)
                obj=coder.const(@feval,'coder.customfloat.helpers.typecast.uint32ToSingle',tmp);
            else
                obj=coder.customfloat.helpers.typecast.uint32ToSingle(tmp);
            end
        end


        function obj=double(this)
            tmp=coder.nullcopy(zeros(size(this),'uint64'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.cf2cf(CustomFloatType(64,52),aSign,aExponent,aMantissa,CustomFloatType(16,10));

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            if coder.internal.isConst(tmp)
                obj=coder.const(@feval,'coder.customfloat.helpers.typecast.uint64ToDouble',tmp);
            else
                obj=coder.customfloat.helpers.typecast.uint64ToDouble(tmp);
            end
        end


        function obj=fi(this,Signed,WordLength,FracLength)
            obj=coder.nullcopy(zeros(size(this),'like',fi([],numerictype(Signed,WordLength,FracLength))));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                obj(ii)=coder.customfloat.scalar.cf2fixed(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                Signed,WordLength,FracLength,true);
            end
        end


        function obj=uint64(this)
            obj=storedInteger(fi(this,0,64,0));
        end


        function obj=uint32(this)
            obj=storedInteger(fi(this,0,32,0));
        end


        function obj=uint16(this)
            obj=storedInteger(fi(this,0,16,0));
        end


        function obj=uint8(this)
            obj=storedInteger(fi(this,0,8,0));
        end


        function obj=int64(this)
            obj=storedInteger(fi(this,1,64,0));
        end


        function obj=int32(this)
            obj=storedInteger(fi(this,1,32,0));
        end


        function obj=int16(this)
            obj=storedInteger(fi(this,1,16,0));
        end


        function obj=int8(this)
            obj=storedInteger(fi(this,1,8,0));
        end


        function disp(this)
            if coder.target('MATLAB')
                oldFormat=get(0,'Format');
                format short;

                disp(single(this));

                format(oldFormat);
            end
        end

    end




    methods(Hidden)

        function obj=parenReference(this,varargin)
            tmp=this.Value(varargin{:});
            obj=emlhalf.typecast(tmp);
        end


        function this=parenAssign(this,x,varargin)
            numIndex=length(varargin);
            index=1:numIndex;
            for ii=1:numIndex
                index(ii)=length(varargin{ii});
            end
            if(numIndex==1)
                index=[1,index];
            end

            assert(all(index==size(x)),'Dimensions must match');
            if(~isa(x,'emlhalf'))
                x_half=emlhalf(x);
            else
                x_half=x;
            end

            this.Value(varargin{:})=x_half.Value;
        end


        function obj=horzcat(this,varargin)
            tmp=cell(1,length(varargin));

            if(nargin>1)
                for ii=1:length(varargin)
                    tmp_half=emlhalf(varargin{ii});

                    tmp{ii}=tmp_half.Value;
                end

                obj=emlhalf.typecast(horzcat(this.Value,tmp{:}));
            else
                obj=this;
            end
        end


        function obj=vertcat(this,varargin)
            tmp=cell(1,length(varargin));

            for ii=1:length(varargin)
                if isa(varargin{ii},'emlhalf')
                    tmp_half=varargin{ii};
                else
                    tmp_half=emlhalf(varargin{ii});
                end

                tmp{ii}=tmp_half.Value;
            end

            obj=emlhalf.typecast(vertcat(this.Value,tmp{:}));
        end

    end

    methods

        function varargout=size(this)
            s=size(this.Value);
            if(nargout<=1)
                varargout{1}=s;
            elseif(nargout>length(s))
                for ii=1:length(s)
                    varargout{ii}=s(ii);
                end

                for ii=(length(s)+1):nargout
                    varargout{ii}=1;
                end
            else
                for ii=1:nargout
                    varargout{ii}=s(ii);
                end
            end
        end


        function obj=numel(this)
            obj=numel(this.Value);
        end


        function obj=reshape(this,varargin)
            if(nargin==2)
                s=varargin{1};
            else
                s=coder.nullcopy(zeros([1,nargin-1]));
                for ii=1:(nargin-1)
                    s(ii)=varargin{ii};
                end
            end

            tmp=reshape(this.Value,s);
            obj=emlhalf.typecast(tmp);
        end


        function obj=transpose(this)
            obj=emlhalf.typecast(transpose(this.Value));
        end


        function obj=ctranspose(this)
            obj=transpose(this);
        end


        function out=all(this)
            out=all(single(this));
        end
    end




    methods

        function obj=fma(this,x,y)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match.');
            assert(all(size(this)==size(y)),'Dimensions must match.');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(y,'emlhalf')
                y_half=y;
            else
                y_half=emlhalf(y);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));
                [cSign,cExponent,cMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),y_half.Value(ii));

                [dSign,dExponent,dMantissa]=coder.customfloat.scalar.fma(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,cSign,cExponent,cMantissa,true);

                tmp(ii)=storedInteger(bitconcat(dSign,dExponent,dMantissa));
            end

            obj=emlhalf.typecast(tmp);
        end
    end







    methods

        obj=plus(this,x);


        function obj=minus(this,x)
            obj=this+(-x);
        end


        obj=times(this,x);



        function obj=mtimes(this,x)
            coder.inline('never');
            if(numel(this)==1)||(numel(x)==1)

                tmp=times_scalar(this,x);
            else

                size_this=size(this);
                size_x=size(x);
                size_out=[size_this(1),size_x(2)];
                assert((size_this(2)==size_x(1)),'Dimensions mismatch');

                if isa(x,'emlhalf')
                    x_half=x;
                else
                    x_half=emlhalf(x);
                end

                if isa(this,'emlhalf')
                    this_half=this;
                else
                    this_half=emlhalf(this);
                end

                tmp=coder.nullcopy(zeros(size_out,'uint16'));

                for ii=1:1:size_out(1)
                    for jj=1:1:size_out(2)
                        [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii,1));
                        [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(1,jj));

                        [dSign,dExponent,dMantissa]=coder.customfloat.scalar.times(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                        bSign,bExponent,bMantissa,true);

                        for kk=2:1:size_this(2)
                            [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii,kk));
                            [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(kk,jj));
                            [cSign,cExponent,cMantissa]=coder.customfloat.scalar.times(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                            bSign,bExponent,bMantissa,true);
                            [dSign,dExponent,dMantissa]=coder.customfloat.scalar.plus(CustomFloatType(16,10),dSign,dExponent,dMantissa,...
                            cSign,cExponent,cMantissa,true);
                        end

                        tmp(ii,jj)=storedInteger(bitconcat(dSign,dExponent,dMantissa));
                    end
                end

            end

            obj=emlhalf.typecast(tmp);
        end


        obj=rdivide(this,x);


        function obj=ldivide(this,x)
            coder.inline('never');
            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            obj=rdivide(x_half,this);
        end


        function obj=rem(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=coder.customfloat.scalar.half.modrem(this_half.Value(ii),x_half.Value(ii),uint16(2),true);
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=mod(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=coder.customfloat.scalar.half.modrem(this_half.Value(ii),x_half.Value(ii),uint16(1),true);
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=power(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));

                [cSign,cExponent,cMantissa]=coder.customfloat.scalar.power(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,true,...
                emlhalf.Log2TableForLog2_Pow,emlhalf.Log2MinusTableForLog2_Pow,emlhalf.Log2E_Pow,...
                emlhalf.Log2TableForPow2_Pow,emlhalf.Log2MinusTableForPow2_Pow,emlhalf.Ln2_Pow);

                tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=hypot(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));

                [cSign,cExponent,cMantissa]=coder.customfloat.scalar.hypot(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,emlhalf.HypotScalingFactor);

                tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=atan2(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimensions must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this_half.Value(ii));
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),x_half.Value(ii));

                [cSign,cExponent,cMantissa]=coder.customfloat.scalar.half.atan2(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,emlhalf.PiExponent,emlhalf.PiMantissa,...
                emlhalf.PiOverTwoExponent,emlhalf.PiOverTwoMantissa,...
                emlhalf.PiOverFourExponent,emlhalf.PiOverFourMantissa,...
                emlhalf.ThreePiOverFourExponent,emlhalf.ThreePiOverFourMantissa,...
                emlhalf.PiOverTwo,emlhalf.Pi,...
                emlhalf.AtanApproxSlopeTable,emlhalf.AtanApproxInterceptTable,true);

                tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
            end

            obj=emlhalf.typecast(tmp);
        end
    end




    methods

        function obj=uplus(this)
            obj=this;
        end


        function obj=uminus(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=bitxor(this.Value(ii),emlhalf.SignMask);
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=abs(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=bitand(this.Value(ii),emlhalf.ExponentMantissaMask);
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=sqrt(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.sqrt(CustomFloatType(16,10),aSign,aExponent,aMantissa);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=rsqrt(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.rsqrt(CustomFloatType(16,10),aSign,aExponent,aMantissa,true);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=recip(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.recip(CustomFloatType(16,10),aSign,aExponent,aMantissa,true);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=log(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.log(CustomFloatType(16,10),aSign,aExponent,aMantissa,true,...
                emlhalf.LogTable,emlhalf.LogMinusTable,emlhalf.LogExpTable);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=log2(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.log2(CustomFloatType(16,10),aSign,aExponent,aMantissa,true,...
                emlhalf.Log2TableForLog2,emlhalf.Log2MinusTableForLog2,emlhalf.Log2E);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=log10(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.log10(CustomFloatType(16,10),aSign,aExponent,aMantissa,true,...
                emlhalf.Log10Table,emlhalf.Log10MinusTable,emlhalf.Log4thRoot10E,emlhalf.Log10ExpTable);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=exp(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=coder.customfloat.scalar.half.c.exp(this.Value(ii));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=pow2(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=coder.customfloat.scalar.half.c.pow2(this.Value(ii));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=pow10(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                tmp(ii)=coder.customfloat.scalar.half.c.pow10(this.Value(ii));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=sin(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.sin(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.TwoOverPi,emlhalf.SinTwoOverPiTable,emlhalf.SinLinearApproxSlope,emlhalf.SinLinearApproxIntercept,...
                emlhalf.PiExponent,emlhalf.PiMantissa,true);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=cos(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.cos(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.CosTwoOverPiTable,emlhalf.CosLinearApproxSlope,emlhalf.CosLinearApproxIntercept,...
                emlhalf.TwoPiExponent,emlhalf.TwoPiMantissa,true);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=tan(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.tancot(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.FourOverPi,emlhalf.TanFourOverPiTable,emlhalf.TanLinearApproxSlope,emlhalf.TanLinearApproxIntercept,...
                emlhalf.PiOverTwoExponent,emlhalf.PiOverTwoMantissa,true,true);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=cot(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.tancot(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.FourOverPi,emlhalf.TanFourOverPiTable,emlhalf.TanLinearApproxSlope,emlhalf.TanLinearApproxIntercept,...
                emlhalf.PiExponent,emlhalf.PiMantissa,false,true);
                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=asin(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.asin(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.PiOverTwoExponent,emlhalf.PiOverTwoMantissa,emlhalf.AsinApproxSlopeTable,...
                emlhalf.AsinApproxInterceptTable,emlhalf.AsinLookupTablePos);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=acos(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.acos(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.Pi,emlhalf.PiExponent,emlhalf.PiMantissa,emlhalf.AcosApproxSlopeTable,...
                emlhalf.AcosApproxInterceptTable,emlhalf.AcosLookupTablePos,emlhalf.AcosLookupTableNeg);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=atan(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.half.atan(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.PiOverTwo,emlhalf.PiOverTwoExponent,emlhalf.PiOverTwoMantissa,emlhalf.AtanApproxSlopeTable,...
                emlhalf.AtanApproxInterceptTable);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=cosh(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.cosh(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.Log2TableForExp,emlhalf.Log2MinusTableForExp,emlhalf.Ln2,emlhalf.Log2_E);
                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=sinh(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.sinh(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.Log2TableForSinh,emlhalf.Log2MinusTableForSinh,emlhalf.Ln2_ForSinh,emlhalf.Log2_E_ForSinh);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=tanh(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.tanh(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                emlhalf.Log2TableForTanh,emlhalf.Log2MinusTableForTanh,emlhalf.Ln2_ForTanh,emlhalf.Log2_E_ForTanh);
                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end

    end




    methods

        function obj=floor(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.floor(CustomFloatType(16,10),aSign,aExponent,aMantissa);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=ceil(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.ceil(CustomFloatType(16,10),aSign,aExponent,aMantissa);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=fix(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.fix(CustomFloatType(16,10),aSign,aExponent,aMantissa);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end


        function obj=round(this)
            coder.inline('never');
            tmp=coder.nullcopy(zeros(size(this),'uint16'));

            for ii=1:numel(this)
                [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),this.Value(ii));

                [Sign,Exponent,Mantissa]=coder.customfloat.scalar.round(CustomFloatType(16,10),aSign,aExponent,aMantissa);

                tmp(ii)=storedInteger(bitconcat(Sign,Exponent,Mantissa));
            end

            obj=emlhalf.typecast(tmp);
        end

    end




    methods

        function obj=eq(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimension must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            this_nan=isnan(this_half);
            x_nan=isnan(x_half);

            for ii=1:numel(this)
                exp_mant=bitand(this_half.Value(ii),emlhalf.ExponentMantissaMask);
                obj(ii)=((~this_nan(ii))&&(~x_nan(ii))&&...
                (exp_mant==bitand(x_half.Value(ii),emlhalf.ExponentMantissaMask))&&...
                ((bitand(this_half.Value(ii),emlhalf.SignMask)==bitand(this_half.Value(ii),emlhalf.SignMask))||...
                (exp_mant==0)));
            end
        end


        function obj=ne(this,x)
            obj=~(this==x);
        end


        function obj=lt(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimension must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            this_nan=isnan(this_half);
            x_nan=isnan(x_half);

            for ii=1:numel(this)

                this_corr=bitand(this_half.Value(ii),emlhalf.ExponentMantissaMask);
                if(this_corr~=0)
                    this_corr=this_half.Value(ii);
                end

                x_corr=bitand(x_half.Value(ii),emlhalf.ExponentMantissaMask);
                if(x_corr~=0)
                    x_corr=x_half.Value(ii);
                end

                obj(ii)=((~this_nan(ii))&&(~x_nan(ii))&&(this_corr<x_corr));
            end
        end


        function obj=le(this,x)
            assert(all(size(this)==size(x)),'Dimension must match');

            obj=((this<x)|(this==x));
        end


        function obj=gt(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimension must match');

            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            this_nan=isnan(this_half);
            x_nan=isnan(x_half);

            for ii=1:numel(this)

                this_corr=bitand(this_half.Value(ii),emlhalf.ExponentMantissaMask);
                if(this_corr~=0)
                    this_corr=this_half.Value(ii);
                end

                x_corr=bitand(x_half.Value(ii),emlhalf.ExponentMantissaMask);
                if(x_corr~=0)
                    x_corr=x_half.Value(ii);
                end

                obj(ii)=((~this_nan(ii))&&(~x_nan(ii))&&(this_corr>x_corr));
            end
        end


        function obj=ge(this,x)
            coder.inline('never');
            assert(all(size(this)==size(x)),'Dimension must match');

            obj=((this>x)|(this==x));
        end
    end




    methods
        function obj=isnan(this)
            obj=(bitand(this.Value,emlhalf.ExponentMask)==emlhalf.ExponentMask)&(bitand(this.Value,emlhalf.MantissaMask)~=0);
        end

        function obj=isinf(this)
            obj=(bitand(this.Value,emlhalf.ExponentMask)==emlhalf.ExponentMask)&(bitand(this.Value,emlhalf.MantissaMask)==0);
        end

        function obj=isfinite(this)
            obj=(bitand(this.Value,emlhalf.ExponentMask)~=emlhalf.ExponentMask);
        end
    end




    methods

        function obj=storedInteger(this)
            obj=this.Value;
        end
    end




    methods(Access='private')

        function out=times_scalar(this,x)
            if isa(x,'emlhalf')
                x_half=x;
            else
                x_half=emlhalf(x);
            end

            if isa(this,'emlhalf')
                this_half=this;
            else
                this_half=emlhalf(this);
            end

            if(numel(this)==1)
                scalar=this_half.Value;
                tmp=x_half.Value;
            else
                scalar=x_half.Value;
                tmp=this_half.Value;
            end

            [aSign,aExponent,aMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),scalar);

            for ii=1:numel(tmp)
                [bSign,bExponent,bMantissa]=coder.customfloat.helpers.extractComponentsFromUInt(CustomFloatType(16,10),tmp(ii));

                [cSign,cExponent,cMantissa]=coder.customfloat.scalar.times(CustomFloatType(16,10),aSign,aExponent,aMantissa,...
                bSign,bExponent,bMantissa,true);

                tmp(ii)=storedInteger(bitconcat(cSign,cExponent,cMantissa));
            end

            out=tmp;
        end
    end

    methods(Static,Access='private')
        function name=matlabCodegenUserReadableName(~)
            name='half';
        end
    end

    methods(Static)
        function out=matlabCodegenToRedirected(in)

            out=emlhalf.typecast(storedInteger(in));
        end

        function out=matlabCodegenFromRedirected(in)

            out=half.typecast(storedInteger(in));
        end
    end
    methods(Static,Hidden)
        function out=typecast(x)
            out=emlhalf(x,true);
        end

        function out=zeros(varargin)
            numIndex=length(varargin);
            s=coder.nullcopy(zeros([1,numIndex]));
            for ii=1:numIndex
                s(ii)=varargin{ii};
            end
            out=emlhalf.typecast(zeros(s,'uint16'));
        end

        function out=ones(varargin)
            numIndex=length(varargin);
            s=coder.nullcopy(zeros([1,numIndex]));
            for ii=1:numIndex
                s(ii)=varargin{ii};
            end

            out=emlhalf.typecast(repmat(uint16(15360),s));
        end

        function out=cast(x)
            out=emlhalf(x);
        end
    end
end
