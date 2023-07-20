


















































































%#codegen


classdef CustomFloat<matlab.mixin.internal.indexing.Paren&matlab.mixin.internal.indexing.ParenAssign&coder.mixin.internal.indexing.ParenAssign



    properties(SetAccess='protected')
Type

SignReal
ExponentReal
MantissaReal
SignImag
ExponentImag
MantissaImag

flagCmplx
    end

    properties(Dependent)
WordLength
MantissaLength
ExponentLength
ExponentBias
    end




    methods

        function this=CustomFloat(x,wl,ml,tpcastmode,flagComplex)
            coder.inline('never');
            coder.allowpcode('plain');

            narginchk(1,5);

            if~(isa(x,'CustomFloat')||isa(x,'numeric')||...
                isa(x,'emlhalf')||isa(x,'half')||...
                isfi(x))
                error('Input datatype %s is not supported',class(x));
            end


            tpcast=false;


            switch class(x)
            case{'double','uint64','int64'}
                in_wl=64;
            case{'single','uint32','int32'}
                in_wl=32;
            case{'half','emlhalf','uint16','int16'}
                in_wl=16;
            case{'uint8','int8'}
                in_wl=8;
            case{'CustomFloat','embedded.fi'}
                in_wl=x.WordLength;
            end


            switch nargin
            case 1

                if isa(x,'CustomFloat')
                    tpcast=true;
                    this.Type=x.Type;
                elseif isa(x,'double')
                    tpcast=true;
                    this.Type=CustomFloatType(64,52);
                elseif isa(x,'single')
                    tpcast=true;
                    this.Type=CustomFloatType(32,23);
                elseif(isa(x,'half')||isa(x,'emlhalf'))
                    tpcast=true;
                    this.Type=CustomFloatType(16,10);
                elseif(isa(x,'uint64')||isa(x,'int64'))

                    this.Type=CustomFloatType(80,64);
                elseif isa(x,'uint32')||isa(x,'int32')

                    this.Type=CustomFloatType(64,52);
                elseif isa(x,'uint16')||isa(x,'int16')

                    this.Type=CustomFloatType(32,23);
                elseif isa(x,'uint8')||isa(x,'int8')

                    this.Type=CustomFloatType(16,10);
                elseif isfi(x)
                    this.Type=CustomFloatType(x.WordLength+ceil(log2(x.WordLength))+3,x.WordLength);
                end

                this.flagCmplx=~isreal(x);

            case 2
                if isa(wl,'CustomFloatType')
                    this.Type=wl;


                    if((isa(x,'CustomFloat')&&(x.Type==this.Type))||...
                        (isa(x,'double')&&(this.Type==CustomFloatType(64,52)))||...
                        (isa(x,'single')&&(this.Type==CustomFloatType(32,23)))||...
                        ((isa(x,'half')||isa(x,'emlhalf'))&&(this.Type==CustomFloatType(16,10))))
                        tpcast=true;
                    end
                elseif isa(wl,'char')



                    switch wl
                    case 'double'
                        if isa(x,'double')
                            tpcast=true;
                        end

                        this.Type=CustomFloatType(64,52);

                    case 'single'
                        if isa(x,'single')
                            tpcast=true;
                        end

                        this.Type=CustomFloatType(32,23);

                    case 'half'
                        if(isa(x,'half')||isa(x,'emlhalf'))
                            tpcast=true;
                        end

                        this.Type=CustomFloatType(16,10);
                    end
                else
                    error('Second argument must be ''double'', ''single'', ''half'', or of CustomFloatType class');
                end

                this.flagCmplx=~isreal(x);

            case 3
                if(ischar(ml))

                    if~(isa(wl,'CustomFloatType')&&strcmpi(ml,'typecast'))
                        error('Unsupported input arguments');
                    end


                    if(in_wl~=wl.WordLength)
                        error('The word length of the custom float type must be equal to the word length of the object being cast');
                    end

                    tpcast=true;
                    this.Type=wl;
                    this.flagCmplx=~isreal(x);
                elseif islogical(ml)

                    this.Type=wl;
                    this.flagCmplx=ml;
                else

                    this.Type=CustomFloatType(wl,ml);
                    this.flagCmplx=~isreal(x);
                end

            case 4
                if ischar(tpcastmode)

                    if~strcmpi(tpcastmode,'typecast')
                        error('Unsupported input arguments');
                    end

                    if(in_wl~=wl)
                        error('The word length of the custom float type must be equal to the word length of the object being cast');
                    end

                    tpcast=true;
                    this.Type=CustomFloatType(wl,ml);
                    this.flagCmplx=~isreal(x);
                elseif ischar(ml)&&islogical(tpcastmode)

                    if~strcmpi(ml,'typecast')
                        error('Unsupported input arguments');
                    end

                    tpcast=true;
                    this.Type=wl;
                    this.flagCmplx=tpcastmode;
                else

                    this.Type=CustomFloatType(wl,ml);
                    this.flagCmplx=logical(tpcastmode);
                end

            case 5

                if~(ischar(tpcastmode)&&strcmpi(tpcastmode,'typecast'))
                    error('Unsupported input arguments');
                end

                if(in_wl~=wl)
                    error('The word length of the custom float type must be equal to the word length of the object being cast');
                end

                tpcast=true;
                this.Type=CustomFloatType(wl,ml);
                this.flagCmplx=logical(flagComplex);

            end

            if(isa(x,'CustomFloat')&&(x.Type==this.Type))

                this.SignReal=x.SignReal;
                this.ExponentReal=x.ExponentReal;
                this.MantissaReal=x.MantissaReal;
                if this.flagCmplx
                    size_x=size(x);
                    if isempty(x.SignImag)
                        this.SignImag=fi(zeros(size_x),0,1,0);
                    else
                        this.SignImag=x.SignImag;
                    end
                    if isempty(x.ExponentImag)
                        this.ExponentImag=fi(zeros(size_x),0,this.Type.ExponentLength,0);
                    else
                        this.ExponentImag=x.ExponentImag;
                    end
                    if isempty(x.MantissaImag)
                        this.MantissaImag=fi(zeros(size_x),0,this.Type.MantissaLength,0);
                    else
                        this.MantissaImag=x.MantissaImag;
                    end
                end
            elseif(tpcast)


                size_x=size(x);
                this.SignReal=coder.nullcopy(fi(zeros(size_x),0,1,0));
                this.ExponentReal=coder.nullcopy(fi(zeros(size_x),0,this.Type.ExponentLength,0));
                this.MantissaReal=coder.nullcopy(fi(zeros(size_x),0,this.Type.MantissaLength,0));
                if this.flagCmplx
                    this.SignImag=coder.nullcopy(fi(zeros(size_x),0,1,0));
                    this.ExponentImag=coder.nullcopy(fi(zeros(size_x),0,this.Type.ExponentLength,0));
                    this.MantissaImag=coder.nullcopy(fi(zeros(size_x),0,this.Type.MantissaLength,0));
                end

                switch class(x)
                case 'CustomFloat'
                    if this.flagCmplx
                        tmpReal=storedFiReal(x);
                        tmpImag=storedFiImag(x);
                    else
                        tmpReal=storedFiReal(x);
                    end
                case 'double'
                    if this.flagCmplx
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',real(x));
                            tmpImag=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',imag(x));
                        else
                            tmpReal=coder.customfloat.helpers.typecast.doubleToFi(real(x));
                            tmpImag=coder.customfloat.helpers.typecast.doubleToFi(imag(x));
                        end
                    else
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',x);
                        else
                            tmpReal=coder.customfloat.helpers.typecast.doubleToFi(x);
                        end
                    end
                case 'single'
                    if this.flagCmplx
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',real(x));
                            tmpImag=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',imag(x));
                        else
                            tmpReal=coder.customfloat.helpers.typecast.singleToFi(real(x));
                            tmpImag=coder.customfloat.helpers.typecast.singleToFi(imag(x));
                        end
                    else
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',x);
                        else
                            tmpReal=coder.customfloat.helpers.typecast.singleToFi(x);
                        end
                    end
                case{'half','emlhalf'}
                    if this.flagCmplx
                        tmpReal=fi(storedInteger(real(x)),0,in_wl,0);
                        tmpImag=fi(storedInteger(imag(x)),0,in_wl,0);
                    else
                        tmpReal=fi(storedInteger(x),0,in_wl,0);
                    end
                case{'uint64','uint32','uint16','uint8'}
                    if this.flagCmplx
                        tmpReal=fi(real(x),0,in_wl,0);
                        tmpImag=fi(imag(x),0,in_wl,0);
                    else
                        tmpReal=fi(x,0,in_wl,0);
                    end
                case{'int64','int32','int16','int8'}
                    if this.flagCmplx
                        tmpReal=reinterpretcast(fi(real(x),1,in_wl,0),numerictype(0,in_wl,0));
                        tmpImag=reinterpretcast(fi(imag(x),1,in_wl,0),numerictype(0,in_wl,0));
                    else
                        tmpReal=reinterpretcast(fi(x,1,in_wl,0),numerictype(0,in_wl,0));
                    end
                case{'embedded.fi'}
                    if this.flagCmplx
                        tmpReal=real(x);
                        tmpImag=imag(x);
                    else
                        tmpReal=x;
                    end
                end

                this.SignReal=bitget(tmpReal,in_wl);
                this.ExponentReal=bitsliceget(tmpReal,in_wl-1,in_wl-this.ExponentLength);
                this.MantissaReal=bitsliceget(tmpReal,this.MantissaLength,1);
                if this.flagCmplx
                    this.SignImag=bitget(tmpImag,in_wl);
                    this.ExponentImag=bitsliceget(tmpImag,in_wl-1,in_wl-this.ExponentLength);
                    this.MantissaImag=bitsliceget(tmpImag,this.MantissaLength,1);
                end

            else
                assert(this.Type.ExponentLength<31,'ExponentLength must be less than 31.');
                size_x=size(x);


                this.SignReal=coder.nullcopy(fi(zeros(size_x),0,1,0));
                this.ExponentReal=coder.nullcopy(fi(zeros(size_x),0,this.Type.ExponentLength,0));
                this.MantissaReal=coder.nullcopy(fi(zeros(size_x),0,this.Type.MantissaLength,0));
                if this.flagCmplx
                    this.SignImag=coder.nullcopy(fi(zeros(size_x),0,1,0));
                    this.ExponentImag=coder.nullcopy(fi(zeros(size_x),0,this.Type.ExponentLength,0));
                    this.MantissaImag=coder.nullcopy(fi(zeros(size_x),0,this.Type.MantissaLength,0));
                end


                switch class(x)
                case 'CustomFloat'
                    for ii=1:numel(x)
                        [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                        x.SignReal(ii),x.ExponentReal(ii),x.MantissaReal(ii),x.Type);
                        if this.flagCmplx
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                            x.SignImag(ii),x.ExponentImag(ii),x.MantissaImag(ii),x.Type);
                        end
                    end

                case 'double'
                    DoubleType=CustomFloatType(64,52);

                    if~this.flagCmplx
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',x);
                        else
                            tmpReal=coder.customfloat.helpers.typecast.doubleToFi(x);
                        end
                    else
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',real(x));
                            tmpImag=coder.const(@feval,'coder.customfloat.helpers.typecast.doubleToFi',imag(x));
                        else
                            tmpReal=coder.customfloat.helpers.typecast.doubleToFi(real(x));
                            tmpImag=coder.customfloat.helpers.typecast.doubleToFi(imag(x));
                        end
                    end


                    aSignReal=bitget(tmpReal,DoubleType.WordLength);
                    aExponentReal=bitsliceget(tmpReal,DoubleType.WordLength-1,DoubleType.WordLength-DoubleType.ExponentLength);
                    aMantissaReal=bitsliceget(tmpReal,DoubleType.MantissaLength,1);
                    for ii=1:numel(x)
                        [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                        aSignReal(ii),aExponentReal(ii),aMantissaReal(ii),DoubleType);
                    end

                    if this.flagCmplx
                        aSignImag=bitget(tmpImag,DoubleType.WordLength);
                        aExponentImag=bitsliceget(tmpImag,DoubleType.WordLength-1,DoubleType.WordLength-DoubleType.ExponentLength);
                        aMantissaImag=bitsliceget(tmpImag,DoubleType.MantissaLength,1);
                        for ii=1:numel(x)
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                            aSignImag(ii),aExponentImag(ii),aMantissaImag(ii),DoubleType);
                        end
                    end

                case 'single'
                    SingleType=CustomFloatType(32,23);
                    if~this.flagCmplx
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',x);
                        else
                            tmpReal=coder.customfloat.helpers.typecast.singleToFi(x);
                        end
                    else
                        if coder.internal.isConst(x)
                            tmpReal=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',real(x));
                            tmpImag=coder.const(@feval,'coder.customfloat.helpers.typecast.singleToFi',imag(x));
                        else
                            tmpReal=coder.customfloat.helpers.typecast.singleToFi(real(x));
                            tmpImag=coder.customfloat.helpers.typecast.singleToFi(imag(x));
                        end
                    end

                    aSignReal=bitget(tmpReal,SingleType.WordLength);
                    aExponentReal=bitsliceget(tmpReal,SingleType.WordLength-1,SingleType.WordLength-SingleType.ExponentLength);
                    aMantissaReal=bitsliceget(tmpReal,SingleType.MantissaLength,1);
                    if this.flagCmplx
                        aSignImag=bitget(tmpImag,SingleType.WordLength);
                        aExponentImag=bitsliceget(tmpImag,SingleType.WordLength-1,SingleType.WordLength-SingleType.ExponentLength);
                        aMantissaImag=bitsliceget(tmpImag,SingleType.MantissaLength,1);
                    end

                    for ii=1:numel(x)
                        [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                        aSignReal(ii),aExponentReal(ii),aMantissaReal(ii),SingleType);
                        if this.flagCmplx
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                            aSignImag(ii),aExponentImag(ii),aMantissaImag(ii),SingleType);
                        end
                    end

                case{'half','emlhalf'}
                    HalfType=CustomFloatType(16,10);

                    if~this.flagCmplx
                        tmpReal=fi(storedInteger(x),0,in_wl,0);
                        aSignReal=bitget(tmpReal,HalfType.WordLength);
                        aExponentReal=bitsliceget(tmpReal,HalfType.WordLength-1,HalfType.WordLength-HalfType.ExponentLength);
                        aMantissaReal=bitsliceget(tmpReal,HalfType.MantissaLength,1);
                    else
                        tmpReal=fi(storedInteger(real(x)),0,in_wl,0);
                        aSignReal=bitget(tmpReal,HalfType.WordLength);
                        aExponentReal=bitsliceget(tmpReal,HalfType.WordLength-1,HalfType.WordLength-HalfType.ExponentLength);
                        aMantissaReal=bitsliceget(tmpReal,HalfType.MantissaLength,1);
                        tmpImag=fi(storedInteger(imag(x)),0,in_wl,0);
                        aSignImag=bitget(tmpImag,HalfType.WordLength);
                        aExponentImag=bitsliceget(tmpImag,HalfType.WordLength-1,HalfType.WordLength-HalfType.ExponentLength);
                        aMantissaImag=bitsliceget(tmpImag,HalfType.MantissaLength,1);
                    end

                    for ii=1:numel(x)
                        [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                        aSignReal(ii),aExponentReal(ii),aMantissaReal(ii),HalfType);
                        if this.flagCmplx
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.cf2cf(this.Type,...
                            aSignImag(ii),aExponentImag(ii),aMantissaImag(ii),HalfType);
                        end
                    end

                case{'uint64','uint32','uint16','uint8'}
                    if~this.flagCmplx
                        tmpReal=fi(x,0,in_wl,0);
                        for ii=1:numel(x)
                            [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpReal(ii));
                        end
                    else
                        tmpReal=fi(real(x),0,in_wl,0);
                        tmpImag=fi(imag(x),0,in_wl,0);
                        for ii=1:numel(x)
                            [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpReal(ii));
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpImag(ii));
                        end
                    end
                case{'int64','int32','int16','int8'}
                    if~this.flagCmplx
                        tmpReal=fi(x,1,in_wl,0);
                        for ii=1:numel(x)
                            [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpReal(ii));
                        end
                    else
                        tmpReal=fi(real(x),1,in_wl,0);
                        tmpImag=fi(imag(x),1,in_wl,0);
                        for ii=1:numel(x)
                            [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpReal(ii));
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            tmpImag(ii));
                        end
                    end

                case{'embedded.fi'}
                    for ii=1:numel(x)
                        [this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                        real(x(ii)));
                        if this.flagCmplx
                            [this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii)]=coder.customfloat.scalar.fixed2cf(this.Type,...
                            imag(x(ii)));
                        end
                    end

                end
            end

        end


        function obj=complex(this,x)
            if nargin==1
                if this.flagCmplx
                    obj=this;
                else
                    obj=allocImag(this);
                end
            else
                assert(numel(this)==numel(x),'Real and Imag must have same dimension.');
                if(~isa(x,'CustomFloat'))||(x.Type~=this.Type)
                    x_cf=CustomFloat(x,this.Type);
                else
                    x_cf=x;
                end
                obj=allocImag(this);
                obj.SignImag=x_cf.SignReal;
                obj.ExponentImag=x_cf.ExponentReal;
                obj.MantissaImag=x_cf.MantissaReal;
            end
        end



        function obj=allocImag(this)
            obj=CustomFloat.initializeType(size(this),this.Type,true);
            obj.SignReal=this.SignReal;
            obj.ExponentReal=this.ExponentReal;
            obj.MantissaReal=this.MantissaReal;
            obj.SignImag=fi(zeros(size(this)),0,1,0);
            obj.ExponentImag=fi(zeros(size(this)),0,this.Type.ExponentLength,0);
            obj.MantissaImag=fi(zeros(size(this)),0,this.Type.MantissaLength,0);
        end


        function disp(this)
            if(this.WordLength<=32)&&(this.MantissaLength<=23)
                tmp=single(this);
            else
                tmp=double(this);
            end
            disp(tmp);
            this.Type.disp;
        end
    end


    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'flagCmplx'};
        end
    end




    methods(Hidden)

        function obj=parenReference(this,varargin)
            numIndex=length(varargin);
            index=1:numIndex;
            for ii=1:numIndex
                index(ii)=length(varargin{ii});
            end
            if(numIndex==1)
                index=[1,index];
            end

            if this.flagCmplx
                obj=CustomFloat.initializeType(index,this.Type,true);
                obj.SignImag=this.SignImag(varargin{:});
                obj.ExponentImag=this.ExponentImag(varargin{:});
                obj.MantissaImag=this.MantissaImag(varargin{:});
            else
                obj=CustomFloat.initializeType(index,this.Type);
            end

            obj.SignReal=this.SignReal(varargin{:});
            obj.ExponentReal=this.ExponentReal(varargin{:});
            obj.MantissaReal=this.MantissaReal(varargin{:});
        end


        function this=parenAssign(this,x,varargin)
            this=reAssign(this,x,varargin{:});
        end
    end

    methods

        function varargout=size(this)
            s=size(this.SignReal);

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
            obj=numel(this.SignReal);
        end


        function obj=ndims(this)
            obj=ndims(this.SignReal);
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

            obj=CustomFloat.initializeType(s,this.Type,this.flagCmplx);

            if this.flagCmplx
                obj.SignImag=reshape(this.SignImag,s);
                obj.ExponentImag=reshape(this.ExponentImag,s);
                obj.MantissaImag=reshape(this.MantissaImag,s);
            end

            obj.SignReal=reshape(this.SignReal,s);
            obj.ExponentReal=reshape(this.ExponentReal,s);
            obj.MantissaReal=reshape(this.MantissaReal,s);

        end


        function obj=transpose(this)
            tmp=transpose(this.SignReal);
            obj=CustomFloat.initializeType(size(tmp),this.Type,this.flagCmplx);

            if this.flagCmplx
                obj.SignImag=transpose(this.SignImag);
                obj.ExponentImag=transpose(this.ExponentImag);
                obj.MantissaImag=transpose(this.MantissaImag);
            end

            obj.SignReal=tmp;
            obj.ExponentReal=transpose(this.ExponentReal);
            obj.MantissaReal=transpose(this.MantissaReal);
        end


        function obj=ctranspose(this)
            obj=transpose(this);
            if this.flagCmplx
                obj.SignImag=bitcmp(obj.SignImag);
            end
        end


        function obj=conj(this)
            if this.flagCmplx
                obj=this;
                obj.SignImag=bitcmp(this.SignImag);
            else
                obj=this;
            end
        end


    end




    methods


        function obj=real(this)
            if this.flagCmplx
                obj=CustomFloat.initializeType(size(this),this.Type,false);
                obj.SignReal=this.SignReal;
                obj.ExponentReal=this.ExponentReal;
                obj.MantissaReal=this.MantissaReal;
            else
                obj=this;
            end
        end


        function obj=imag(this)
            if this.flagCmplx
                obj=CustomFloat.initializeType(size(this),this.Type,false);
                obj.SignReal=this.SignImag;
                obj.ExponentReal=this.ExponentImag;
                obj.MantissaReal=this.MantissaImag;
            else
                obj=this;
            end
        end



        function obj=norm(this,normmode)
            assert(nargin==2,'Please specify a norm mode.')

            if~strcmp(normmode,'fro')
                assert(false,'The type of norm is not supported.');
            end

            if this.flagCmplx

                tmpobj=CustomFloat.initializeType([1,1],this.Type,false);
                for ii=1:numel(this)
                    [x2_s,x2_e,x2_m]=coder.customfloat.scalar.times(tmpobj.Type,...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true);
                    [y2_s,y2_e,y2_m]=coder.customfloat.scalar.times(tmpobj.Type,...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),true);
                    [tmpS,tmpE,tmpM]=...
                    coder.customfloat.scalar.plus(tmpobj.Type,...
                    x2_s,x2_e,x2_m,...
                    y2_s,y2_e,y2_m,true);
                    [tmpobj.SignReal,tmpobj.ExponentReal,tmpobj.MantissaReal]=...
                    coder.customfloat.scalar.plus(tmpobj.Type,...
                    tmpobj.SignReal,tmpobj.ExponentReal,tmpobj.MantissaReal,...
                    tmpS,tmpE,tmpM,true);
                end
                obj=sqrt(tmpobj);
            else
                tmpobj=CustomFloat.initializeType([1,1],this.Type,false);
                tmp=times(this,this);
                for ii=1:numel(tmp)
                    [tmpobj.SignReal,tmpobj.ExponentReal,tmpobj.MantissaReal]=...
                    coder.customfloat.scalar.plus(this.Type,...
                    tmpobj.SignReal,tmpobj.ExponentReal,tmpobj.MantissaReal,...
                    tmp.SignReal(ii),tmp.ExponentReal(ii),tmp.MantissaReal(ii),true);
                end
                obj=sqrt(tmpobj);
            end
        end

    end




    methods
        function obj=isnan(this)
            obj=coder.nullcopy(zeros(size(this),'logical'));
            for ii=1:numel(this)
                obj(ii)=((this.ExponentReal(ii)==this.Type.Exponent_Inf_or_NaN)&&(this.MantissaReal(ii)~=0));
            end
            if this.flagCmplx
                for ii=1:numel(this)
                    objReal=obj(ii);
                    objImag=((this.ExponentImag(ii)==this.Type.Exponent_Inf_or_NaN)&&(this.MantissaImag(ii)~=0));
                    obj(ii)=objReal|objImag;
                end
            end
        end

        function obj=isinf(this)
            obj=coder.nullcopy(zeros(size(this),'logical'));
            for ii=1:numel(this)
                obj(ii)=((this.ExponentReal(ii)==this.Type.Exponent_Inf_or_NaN)&&(this.MantissaReal(ii)==0));
            end
            if this.flagCmplx
                for ii=1:numel(this)
                    objReal=obj(ii);
                    objImag=((this.ExponentImag(ii)==this.Type.Exponent_Inf_or_NaN)&&(this.MantissaImag(ii)==0));
                    obj(ii)=objReal|objImag;
                end
            end
        end

        function obj=isfinite(this)
            obj=coder.nullcopy(zeros(size(this),'logical'));
            for ii=1:numel(this)
                obj(ii)=(this.ExponentReal(ii)~=this.Type.Exponent_Inf_or_NaN);
            end
            if this.flagCmplx
                for ii=1:numel(this)
                    objReal=obj(ii);
                    objImag=(this.ExponentImag(ii)~=this.Type.Exponent_Inf_or_NaN);
                    obj(ii)=objReal&objImag;
                end
            end
        end

        function obj=isreal(this)
            obj=~this.flagCmplx;
        end

    end




    methods
        function this=reAssign(this,x,varargin)
            lhsSize=size(this);
            numIndex=length(varargin);
            index=1:numIndex;
            for ii=1:numIndex
                if strcmp(varargin{ii},':')
                    index(ii)=lhsSize(ii);
                else
                    index(ii)=length(varargin{ii});
                end
            end
            if(numIndex==1)
                index=[1,index];
            end
            assert(coder.ignoreConst(all(index==size(x))||prod(index)==numel(x)),...
            'Dimensions must match');



            if(~isa(x,'CustomFloat'))||(x.Type~=this.Type)
                x_cf=CustomFloat(x,this.Type);
            else
                x_cf=x;
            end


            assert(coder.ignoreConst(~(~this.flagCmplx&&x_cf.flagCmplx)),...
            ['The left-hand side has been constrained to be non-complex, '...
            ,'but the right-hand side is complex. To correct this problem, '...
            ,'make the right-hand side real using the function REAL, '...
            ,'or change the initial assignment to the left-hand side variable '...
            ,'to be a complex value using the COMPLEX function.'])


            if(this.flagCmplx&&x_cf.flagCmplx)

                this.SignImag(varargin{:})=x_cf.SignImag;
                this.ExponentImag(varargin{:})=x_cf.ExponentImag;
                this.MantissaImag(varargin{:})=x_cf.MantissaImag;
            elseif this.flagCmplx


                this.SignImag(varargin{:})=fi(zeros(size(x_cf)),0,1,0);
                this.ExponentImag(varargin{:})=fi(zeros(size(x_cf)),0,x_cf.Type.ExponentLength,0);
                this.MantissaImag(varargin{:})=fi(zeros(size(x_cf)),0,x_cf.Type.MantissaLength,0);
            end


            this.SignReal(varargin{:})=x_cf.SignReal;
            this.ExponentReal(varargin{:})=x_cf.ExponentReal;
            this.MantissaReal(varargin{:})=x_cf.MantissaReal;
        end

        function obj=horzcat(this,varargin)







            assert(numel(size(this))<3,'horzcat/vertcat only supports upto 2D array');
            [ntar,msum]=size(this);
            for ii=1:length(varargin)
                assert(numel(size(varargin{ii}))<3,'horzcat/vertcat only supports upto 2D array');
                [n,m]=size(varargin{ii});
                assert(n==ntar,'Dimensions must match');
                msum=m+msum;
            end


            flagC=logical(this.flagCmplx);
            for ii=1:length(varargin)
                flagC=flagC|logical(varargin{ii}.flagCmplx);
            end

            obj=CustomFloat(ones([ntar,msum]),this.Type,flagC);




            head=0;
            idxArray=(1:numel(this))+head;
            obj=parenAssign(obj,this,idxArray);
            head=head+numel(this);
            for ii=1:length(varargin)
                idxArray=(1:numel(varargin{ii}))+head;
                obj=parenAssign(obj,varargin{ii},idxArray);
                head=head+numel(varargin{ii});
            end
        end

        function obj=vertcat(this,varargin)
            assert(numel(size(this))<3,'horzcat/vertcat only supports upto 2D array');
            tmpArgs=cell(size(varargin));
            for ii=1:length(varargin)
                assert(numel(size(this))<3,'horzcat/vertcat only supports upto 2D array');
                tmpArgs{ii}=transpose(varargin{ii});
            end
            tmpobj=horzcat(transpose(this),tmpArgs{:});
            obj=transpose(tmpobj);
        end

        function obj=cat(dim,varargin)
            assert(prod(size(varargin))<3,'cat only supports upto 2D array');
            if(dim==1)
                obj=vertcat(varargin{1},varargin{2});
            elseif(dim==2)
                obj=horzcat(varargin{1},varargin{2});
            end
        end

    end




    methods

        function obj=single(this)
            SingleType=CustomFloatType(32,23);

            if~this.flagCmplx
                if(this.Type==SingleType)
                    tmpReal=storedIntegerReal(this);
                else
                    tmpReal=storedIntegerReal(CustomFloat(this,SingleType));
                end

                if coder.internal.isConst(tmpReal)
                    obj=coder.const(@feval,'coder.customfloat.helpers.typecast.uint32ToSingle',tmpReal);
                else
                    obj=coder.customfloat.helpers.typecast.uint32ToSingle(tmpReal);
                end
            else
                if(this.Type==SingleType)
                    tmpReal=storedIntegerReal(this);
                    tmpImag=storedIntegerImag(this);
                else
                    tmpReal=storedIntegerReal(CustomFloat(this,SingleType));
                    tmpImag=storedIntegerImag(CustomFloat(this,SingleType));
                end

                if coder.internal.isConst(tmpReal)&&coder.internal.isConst(tmpImag)
                    objReal=coder.const(@feval,'coder.customfloat.helpers.typecast.uint32ToSingle',tmpReal);
                    objImag=coder.const(@feval,'coder.customfloat.helpers.typecast.uint32ToSingle',tmpImag);
                else
                    objReal=coder.customfloat.helpers.typecast.uint32ToSingle(tmpReal);
                    objImag=coder.customfloat.helpers.typecast.uint32ToSingle(tmpImag);
                end

                obj=complex(objReal,objImag);
            end
        end


        function obj=double(this)
            DoubleType=CustomFloatType(64,52);

            if~this.flagCmplx
                if(this.Type==DoubleType)
                    tmpReal=storedIntegerReal(this);
                else
                    tmpReal=storedIntegerReal(CustomFloat(this,DoubleType));
                end

                if coder.internal.isConst(tmpReal)
                    obj=coder.const(@feval,'coder.customfloat.helpers.typecast.uint64ToDouble',tmpReal);
                else
                    obj=coder.customfloat.helpers.typecast.uint64ToDouble(tmpReal);
                end
            else
                if(this.Type==DoubleType)
                    tmpReal=storedIntegerReal(this);
                    tmpImag=storedIntegerImag(this);
                else
                    tmpReal=storedIntegerReal(CustomFloat(this,DoubleType));
                    tmpImag=storedIntegerImag(CustomFloat(this,DoubleType));
                end

                if coder.internal.isConst(tmpReal)
                    objReal=coder.const(@feval,'coder.customfloat.helpers.typecast.uint64ToDouble',tmpReal);
                    objImag=coder.const(@feval,'coder.customfloat.helpers.typecast.uint64ToDouble',tmpImag);
                else
                    objReal=coder.customfloat.helpers.typecast.uint64ToDouble(tmpReal);
                    objImag=coder.customfloat.helpers.typecast.uint64ToDouble(tmpImag);
                end

                obj=complex(objReal,objImag);
            end
        end


        function obj=fi(this,Signed,WordLength,FracLength)
            obj=coder.nullcopy(zeros(size(this),'like',fi([],numerictype(Signed,WordLength,FracLength))));

            if~this.flagCmplx
                for ii=1:numel(this)
                    obj(ii)=coder.customfloat.scalar.cf2fixed(this.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    Signed,WordLength,FracLength,true);
                end
            else
                for ii=1:numel(this)
                    objReal=coder.customfloat.scalar.cf2fixed(this.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    Signed,WordLength,FracLength,true);
                    objImag=coder.customfloat.scalar.cf2fixed(this.Type,this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),...
                    Signed,WordLength,FracLength,true);
                    obj(ii)=complex(objReal,objImag);
                end
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


        function obj=storedFiReal(this)
            obj=bitconcat(this.SignReal,this.ExponentReal,this.MantissaReal);
        end
        function obj=storedFiImag(this)
            obj=bitconcat(this.SignImag,this.ExponentImag,this.MantissaImag);
        end
        function obj=storedFi(this)
            if this.flagCmplx
                obj=complex(storedFiReal(this),storedFiImag(this));
            else
                obj=storedFiReal(this);
            end
        end


        function obj=storedIntegerReal(this)
            obj=storedInteger(storedFiReal(this));
        end
        function obj=storedIntegerImag(this)
            obj=storedInteger(storedFiImag(this));
        end
        function obj=storedInteger(this)
            if this.flagCmplx
                obj=complex(storedIntegerReal(this),storedIntegerImag(this));
            else
                obj=storedIntegerReal(this);
            end
        end


        function obj=binReal(this)
            tmp=storedFiReal(this);
            obj=tmp.bin;
        end
        function obj=binImag(this)
            tmp=storedFiImag(this);
            obj=tmp.bin;
        end
        function obj=bin(this)
            if this.flagCmplx
                tmp=complex(storedFiReal(this),storedFiImag(this));
                obj=tmp.bin;
            else
                obj=binReal(this);
            end
        end
    end




    methods

        function obj=eq(this,x)
            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            if(this.Type==x_cf.Type)
                a_cf=this;
                b_cf=x_cf;
            else
                wl=max(this.WordLength,x_cf.WordLength);
                ml=max(this.MantissaLength,x_cf.MantissaLength);

                cfType=CustomFloatType(wl,ml);
                a_cf=CustomFloat(this,cfType);
                b_cf=CustomFloat(x_cf,cfType);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            a_nan=isnan(a_cf);
            b_nan=isnan(b_cf);

            for ii=1:numel(this)
                obj(ii)=((~a_nan(ii))&&(~b_nan(ii))&&...
                (a_cf.ExponentReal(ii)==b_cf.ExponentReal(ii))&&(a_cf.MantissaReal(ii)==b_cf.MantissaReal(ii))&&...
                ((a_cf.SignReal(ii)==b_cf.SignReal(ii))||((a_cf.ExponentReal(ii)==0)&&(a_cf.MantissaReal(ii)==0))));
            end

            if this.flagCmplx
                objReal=obj;
                for ii=1:numel(this)
                    objImag=((a_cf.ExponentImag(ii)==b_cf.ExponentImag(ii))&&(a_cf.MantissaImag(ii)==b_cf.MantissaImag(ii))&&...
                    ((a_cf.SignImag(ii)==b_cf.SignImag(ii))||((a_cf.ExponentImag(ii)==0)&&(a_cf.MantissaImag(ii)==0))));
                    obj(ii)=objReal(ii)&objImag;
                end
            end
        end


        function obj=ne(this,x)
            obj=~(this==x);
        end


        function obj=lt(this,x)
            assert(all(size(this)==size(x)),'Dimensions must match');

            if this.flagCmplx||x.flagCmplx
                assert(false,"< is undefined for complex number.");
            end

            x_cf=CustomFloat(x);

            if(this.Type==x_cf.Type)
                a_cf=this;
                b_cf=x_cf;
            else
                wl=max(this.WordLength,x_cf.WordLength);
                ml=max(this.MantissaLength,x_cf.MantissaLength);

                cfType=CustomFloatType(wl,ml);
                a_cf=CustomFloat(this,cfType);
                b_cf=CustomFloat(x_cf,cfType);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            a_nan=isnan(a_cf);
            b_nan=isnan(b_cf);

            for ii=1:numel(this)

                if(a_cf.ExponentReal(ii)==0)&&(a_cf.MantissaReal(ii)==0)
                    em1=fi(0,1,a_cf.WordLength,0);
                else
                    em1=reinterpretcast(bitconcat(fi(0,0,1,0),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii)),numerictype(1,a_cf.WordLength,0));
                    if(a_cf.SignReal(ii)==1)
                        em1(:)=-em1;
                    end
                end

                if(b_cf.ExponentReal(ii)==0)&&(b_cf.MantissaReal(ii)==0)
                    em2=fi(0,1,b_cf.WordLength,0);
                else
                    em2=reinterpretcast(bitconcat(fi(0,0,1,0),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii)),numerictype(1,b_cf.WordLength,0));
                    if(b_cf.SignReal(ii)==1)
                        em2(:)=-em2;
                    end
                end

                obj(ii)=((~a_nan(ii))&&(~b_nan(ii))&&...
                (em1<em2));
            end
        end


        function obj=le(this,x)
            assert(all(size(this)==size(x)),'Dimensions must match');
            obj=((this<x)|(this==x));
        end


        function obj=gt(this,x)
            assert(all(size(this)==size(x)),'Dimensions must match');

            if this.flagCmplx||x.flagCmplx
                assert(false,"> is undefined for complex number.");
            end

            x_cf=CustomFloat(x);

            if(this.Type==x_cf.Type)
                a_cf=this;
                b_cf=x_cf;
            else
                wl=max(this.WordLength,x_cf.WordLength);
                ml=max(this.MantissaLength,x_cf.MantissaLength);

                cfType=CustomFloatType(wl,ml);
                a_cf=CustomFloat(this,cfType);
                b_cf=CustomFloat(x_cf,cfType);
            end

            obj=coder.nullcopy(zeros(size(this),'logical'));
            a_nan=isnan(a_cf);
            b_nan=isnan(b_cf);

            for ii=1:numel(this)

                if(a_cf.ExponentReal(ii)==0)&&(a_cf.MantissaReal(ii)==0)
                    em1=fi(0,1,a_cf.WordLength,0);
                else
                    em1=reinterpretcast(bitconcat(fi(0,0,1,0),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii)),numerictype(1,a_cf.WordLength,0));
                    if(a_cf.SignReal(ii)==1)
                        em1(:)=-em1;
                    end
                end

                if(b_cf.ExponentReal(ii)==0)&&(b_cf.MantissaReal(ii)==0)
                    em2=fi(0,1,b_cf.WordLength,0);
                else
                    em2=reinterpretcast(bitconcat(fi(0,0,1,0),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii)),numerictype(1,b_cf.WordLength,0));
                    if(b_cf.SignReal(ii)==1)
                        em2(:)=-em2;
                    end
                end

                obj(ii)=((~a_nan(ii))&&(~b_nan(ii))&&...
                (em1>em2));
            end
        end


        function obj=ge(this,x)
            assert(all(size(this)==size(x)),'Dimensions must match');
            obj=((this>x)|(this==x));
        end
    end





    methods

        function obj=fma(this,x,y)
            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match.');
            assert(all(size(this)==size(y)),'Dimensions must match.');

            x_cf=CustomFloat(x);
            y_cf=CustomFloat(y);

            wl=max([this.WordLength,x_cf.WordLength,y_cf.WordLength]);
            ml=max([this.MantissaLength,x_cf.MantissaLength,y_cf.MantissaLength]);

            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);
            c_cf=CustomFloat(y_cf,cfType);

            if a_cf.flagCmplx||b_cf.flagCmplx||c_cf.flagCmplx
                obj=plus(times(a_cf,b_cf),c_cf);
            else
                obj=CustomFloat.initializeType(size(this),cfType,false);
                for ii=1:numel(x)
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.fma(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),...
                    c_cf.SignReal(ii),c_cf.ExponentReal(ii),c_cf.MantissaReal(ii),1);
                end
            end
        end
    end




    methods

        function obj=plus(this,x)
            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match.');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);


            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);
            obj=CustomFloat.initializeType(size(this),cfType,(a_cf.flagCmplx||b_cf.flagCmplx));

            for ii=1:numel(x)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.plus(cfType,...
                a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),1);
            end

            if a_cf.flagCmplx&&b_cf.flagCmplx
                for ii=1:numel(x)
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.plus(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),1);
                end
            elseif a_cf.flagCmplx
                tmpSign=fi(0,0,1,0);
                tmpExponent=fi(0,0,a_cf.Type.ExponentLength,0);
                tmpMantissa=fi(0,0,a_cf.Type.MantissaLength,0);
                for ii=1:numel(x)
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.plus(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    tmpSign,tmpExponent,tmpMantissa,1);
                end
            elseif b_cf.flagCmplx
                tmpSign=fi(0,0,1,0);
                tmpExponent=fi(0,0,a_cf.Type.ExponentLength,0);
                tmpMantissa=fi(0,0,a_cf.Type.MantissaLength,0);
                for ii=1:numel(x)
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.plus(cfType,...
                    tmpSign,tmpExponent,tmpMantissa,...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),1);
                end
            end
        end


        function obj=minus(this,x)
            obj=this+(-x);
        end


        function obj=times(this,x)
            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);
            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            obj=CustomFloat.initializeType(size(this),cfType,(this.flagCmplx||x_cf.flagCmplx));
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);

            for ii=1:numel(x)


                if a_cf.flagCmplx&&b_cf.flagCmplx

                    [xuS,xuE,xuM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [yvS,yvE,yvM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                    [xvS,xvE,xvM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                    [yuS,yuE,yuM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.plus(cfType,...
                    xuS,xuE,xuM,...
                    bitcmp(yvS),yvE,yvM,true);
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.plus(cfType,...
                    xvS,xvE,xvM,...
                    yuS,yuE,yuM,true);
                elseif a_cf.flagCmplx

                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                elseif b_cf.flagCmplx

                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                else
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                end
            end
        end


        function obj=mtimes(this,x)
            coder.inline('never');

            size_this=size(this);
            size_x=size(x);
            size_out=[size_this(1),size_x(2)];
            assert((size_this(2)==size_x(1)),'Dimensions mismatch');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            obj=CustomFloat.initializeType(size_out,cfType,(this.flagCmplx||x_cf.flagCmplx));
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);



            for ii=1:1:size_out(1)
                for jj=1:1:size_out(2)
                    if a_cf.flagCmplx&&b_cf.flagCmplx

                        [xuS,xuE,xuM]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                        [yvS,yvE,yvM]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignImag(ii,1),a_cf.ExponentImag(ii,1),a_cf.MantissaImag(ii,1),...
                        b_cf.SignImag(1,jj),b_cf.ExponentImag(1,jj),b_cf.MantissaImag(1,jj),true);
                        [xvS,xvE,xvM]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignImag(1,jj),b_cf.ExponentImag(1,jj),b_cf.MantissaImag(1,jj),true);
                        [yuS,yuE,yuM]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignImag(ii,1),a_cf.ExponentImag(ii,1),a_cf.MantissaImag(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                        [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                        xuS,xuE,xuM,...
                        bitcmp(yvS),yvE,yvM,true);
                        [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                        xvS,xvE,xvM,...
                        yuS,yuE,yuM,true);
                    elseif a_cf.flagCmplx

                        [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                        [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignImag(ii,1),a_cf.ExponentImag(ii,1),a_cf.MantissaImag(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                    elseif b_cf.flagCmplx

                        [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                        [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignImag(1,jj),b_cf.ExponentImag(1,jj),b_cf.MantissaImag(1,jj),true);
                    else
                        [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.times(cfType,...
                        a_cf.SignReal(ii,1),a_cf.ExponentReal(ii,1),a_cf.MantissaReal(ii,1),...
                        b_cf.SignReal(1,jj),b_cf.ExponentReal(1,jj),b_cf.MantissaReal(1,jj),true);
                    end

                    for kk=2:1:size_this(2)
                        if a_cf.flagCmplx&&b_cf.flagCmplx

                            [xuS,xuE,xuM]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [yvS,yvE,yvM]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignImag(ii,kk),a_cf.ExponentImag(ii,kk),a_cf.MantissaImag(ii,kk),...
                            b_cf.SignImag(kk,jj),b_cf.ExponentImag(kk,jj),b_cf.MantissaImag(kk,jj),true);
                            [xvS,xvE,xvM]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignImag(kk,jj),b_cf.ExponentImag(kk,jj),b_cf.MantissaImag(kk,jj),true);
                            [yuS,yuE,yuM]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignImag(ii,kk),a_cf.ExponentImag(ii,kk),a_cf.MantissaImag(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [tmp_s_Real,tmp_e_Real,tmp_m_Real]=coder.customfloat.scalar.plus(cfType,...
                            xuS,xuE,xuM,...
                            bitcmp(yvS),yvE,yvM,true);
                            [tmp_s_Imag,tmp_e_Imag,tmp_m_Imag]=coder.customfloat.scalar.plus(cfType,...
                            xvS,xvE,xvM,...
                            yuS,yuE,yuM,true);
                            [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj),...
                            tmp_s_Real,tmp_e_Real,tmp_m_Real,true);
                            [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj),...
                            tmp_s_Imag,tmp_e_Imag,tmp_m_Imag,true);
                        elseif a_cf.flagCmplx

                            [tmp_s_Real,tmp_e_Real,tmp_m_Real]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [tmp_s_Imag,tmp_e_Imag,tmp_m_Imag]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignImag(ii,kk),a_cf.ExponentImag(ii,kk),a_cf.MantissaImag(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj),...
                            tmp_s_Real,tmp_e_Real,tmp_m_Real,true);
                            [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj),...
                            tmp_s_Imag,tmp_e_Imag,tmp_m_Imag,true);
                        elseif b_cf.flagCmplx

                            [tmp_s_Real,tmp_e_Real,tmp_m_Real]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [tmp_s_Imag,tmp_e_Imag,tmp_m_Imag]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignImag(kk,jj),b_cf.ExponentImag(kk,jj),b_cf.MantissaImag(kk,jj),true);
                            [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj),...
                            tmp_s_Real,tmp_e_Real,tmp_m_Real,true);
                            [obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignImag(ii,jj),obj.ExponentImag(ii,jj),obj.MantissaImag(ii,jj),...
                            tmp_s_Imag,tmp_e_Imag,tmp_m_Imag,true);
                        else
                            [tmp_s_Real,tmp_e_Real,tmp_m_Real]=coder.customfloat.scalar.times(cfType,...
                            a_cf.SignReal(ii,kk),a_cf.ExponentReal(ii,kk),a_cf.MantissaReal(ii,kk),...
                            b_cf.SignReal(kk,jj),b_cf.ExponentReal(kk,jj),b_cf.MantissaReal(kk,jj),true);
                            [obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj)]=coder.customfloat.scalar.plus(cfType,...
                            obj.SignReal(ii,jj),obj.ExponentReal(ii,jj),obj.MantissaReal(ii,jj),...
                            tmp_s_Real,tmp_e_Real,tmp_m_Real,true);
                        end
                    end
                end
            end
        end


        function obj=rdivide(this,x)
            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            obj=CustomFloat.initializeType(size(this),cfType,(this.flagCmplx||x_cf.flagCmplx));

            a_cf=CustomFloat(this,cfType,(this.flagCmplx||x_cf.flagCmplx));
            b_cf=CustomFloat(x_cf,cfType,(this.flagCmplx||x_cf.flagCmplx));




            if a_cf.flagCmplx
                for ii=1:numel(x)

                    [u2_s,u2_e,u2_m]=coder.customfloat.scalar.times(obj.Type,...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [v2_s,v2_e,v2_m]=coder.customfloat.scalar.times(obj.Type,...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                    [norm_s,norm_e,norm_m]=coder.customfloat.scalar.plus(obj.Type,...
                    u2_s,u2_e,u2_m,...
                    v2_s,v2_e,v2_m,true);

                    [xuS,xuE,xuM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [yvS,yvE,yvM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                    [RealS,RealE,RealM]=coder.customfloat.scalar.plus(cfType,...
                    xuS,xuE,xuM,...
                    yvS,yvE,yvM,true);

                    [xvS,xvE,xvM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignImag(ii),b_cf.ExponentImag(ii),b_cf.MantissaImag(ii),true);
                    [yuS,yuE,yuM]=coder.customfloat.scalar.times(cfType,...
                    a_cf.SignImag(ii),a_cf.ExponentImag(ii),a_cf.MantissaImag(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                    [ImagS,ImagE,ImagM]=coder.customfloat.scalar.plus(cfType,...
                    yuS,yuE,yuM,...
                    bitcmp(xvS),xvE,xvM,true);

                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.rdivide(cfType,...
                    RealS,RealE,RealM,...
                    norm_s,norm_e,norm_m,true);

                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=coder.customfloat.scalar.rdivide(cfType,...
                    ImagS,ImagE,ImagM,...
                    norm_s,norm_e,norm_m,true);
                end
            else
                for ii=1:numel(x)
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.rdivide(cfType,...
                    a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                    b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),true);
                end
            end
        end


        function obj=ldivide(this,x)
            x_cf=CustomFloat(x);
            obj=rdivide(x_cf,this);
        end


        function obj=rem(this,x)
            if this.flagCmplx||x.flagCmplx
                assert(false,'rem is not defined for complex numbers.');
            end

            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);

            obj=CustomFloat.initializeType(size(this),cfType);

            for ii=1:numel(x)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.modrem(cfType,...
                a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),...
                2,true);
            end
        end


        function obj=mod(this,x)
            if this.flagCmplx||x.flagCmplx
                assert(false,'mod is not defined for complex numbers.');
            end

            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);

            obj=CustomFloat.initializeType(size(this),cfType);

            for ii=1:numel(x)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.modrem(cfType,...
                a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),...
                1,true);
            end

            obj=obj.reshape(size(this));
        end


        function obj=power(this,x)
            if this.flagCmplx||x.flagCmplx
                assert(false,'power is not defined for complex numbers.');
            end

            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);

            obj=CustomFloat.initializeType(size(this),cfType);

            Log2TableForLog2=coder.customfloat.helpers.generateLog2Table(this.Type,'power_log2');
            Log2MinusTableForLog2=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'power_log2');
            Log2E=coder.customfloat.helpers.generateLog2E(this.Type,'pow');

            Log2TableForPow2=coder.customfloat.helpers.generateLog2Table(this.Type,'power_pow2');
            Log2MinusTableForPow2=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'power_pow2');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type,'pow');

            for ii=1:numel(x)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.power(cfType,...
                a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),...
                true,Log2TableForLog2,Log2MinusTableForLog2,Log2E,...
                Log2TableForPow2,Log2MinusTableForPow2,Ln2);
            end
        end


        function obj=hypot(this,x)
            if this.flagCmplx||x.flagCmplx
                assert(false,'hypot is not implemented for complex numbers.');
            end

            coder.inline('never');

            assert(all(size(this)==size(x)),'Dimensions must match');

            x_cf=CustomFloat(x);

            wl=max(this.WordLength,x_cf.WordLength);
            ml=max(this.MantissaLength,x_cf.MantissaLength);

            cfType=CustomFloatType(wl,ml);
            a_cf=CustomFloat(this,cfType);
            b_cf=CustomFloat(x_cf,cfType);

            obj=CustomFloat.initializeType(size(this),cfType);

            HypotScalingFactor=coder.customfloat.helpers.generateHypotScalingFactor(this.Type);

            for ii=1:numel(x)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=coder.customfloat.scalar.hypot(cfType,...
                a_cf.SignReal(ii),a_cf.ExponentReal(ii),a_cf.MantissaReal(ii),...
                b_cf.SignReal(ii),b_cf.ExponentReal(ii),b_cf.MantissaReal(ii),HypotScalingFactor);
            end

            obj=obj.reshape(size(this));
        end

    end




    methods

        function obj=uplus(this)
            obj=this;
        end


        function obj=uminus(this)
            obj=this;
            obj.SignReal=bitcmp(this.SignReal);
            if this.flagCmplx
                obj.SignImag=bitcmp(this.SignImag);
            end
        end


        function obj=abs(this)
            if this.flagCmplx

                obj=CustomFloat.initializeType(size(this),this.Type,false);
                for ii=1:numel(this)
                    [x2_s,x2_e,x2_m]=coder.customfloat.scalar.times(obj.Type,...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true);
                    [y2_s,y2_e,y2_m]=coder.customfloat.scalar.times(obj.Type,...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),true);
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                    coder.customfloat.scalar.plus(obj.Type,...
                    x2_s,x2_e,x2_m,...
                    y2_s,y2_e,y2_m,true);
                end
                obj=sqrt(obj);
            else
                obj=this;
                for ii=1:numel(this)
                    if(obj.SignReal(ii)==1)
                        obj.SignReal(ii)=fi(0,0,1,0);
                    end
                end
            end
        end


        function obj=floor(this)
            if this.flagCmplx
                assert(false,'floor is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.floor(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii));
            end
        end


        function obj=ceil(this)
            if this.flagCmplx
                assert(false,'ceil is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.ceil(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii));
            end
        end


        function obj=fix(this)
            if this.flagCmplx
                assert(false,'fix is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.fix(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii));
            end
        end


        function obj=round(this)
            if this.flagCmplx
                assert(false,'round is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.round(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii));
            end
        end


        function obj=sqrt(this)
            if this.flagCmplx
                assert(false,'sqrt is not implemented for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.sqrt(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii));
            end
        end


        function obj=rsqrt(this)
            if this.flagCmplx
                assert(false,'rsqrt is not implemented for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.rsqrt(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true);
            end
        end


        function obj=recip(this)
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type,this.flagCmplx);

            if this.flagCmplx

                for ii=1:numel(this)
                    [x2_s,x2_e,x2_m]=coder.customfloat.scalar.times(obj.Type,...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true);
                    [y2_s,y2_e,y2_m]=coder.customfloat.scalar.times(obj.Type,...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),...
                    this.SignImag(ii),this.ExponentImag(ii),this.MantissaImag(ii),true);
                    [norm_s,norm_e,norm_m]=coder.customfloat.scalar.plus(obj.Type,...
                    x2_s,x2_e,x2_m,...
                    y2_s,y2_e,y2_m,true);

                    [r_norm_s,r_norm_e,r_norm_m]=coder.customfloat.scalar.recip(obj.Type,...
                    norm_s,norm_e,norm_m,true);

                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                    coder.customfloat.scalar.times(obj.Type,...
                    this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                    r_norm_s,r_norm_e,r_norm_m,true);
                    [obj.SignImag(ii),obj.ExponentImag(ii),obj.MantissaImag(ii)]=...
                    coder.customfloat.scalar.times(obj.Type,...
                    bitcmp(this.SignImag(ii)),this.ExponentImag(ii),this.MantissaImag(ii),...
                    r_norm_s,r_norm_e,r_norm_m,true);
                end
            else
                for ii=1:numel(this)
                    [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                    coder.customfloat.scalar.recip(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true);
                end
            end
        end


        function obj=log2(this)
            if this.flagCmplx
                assert(false,'log2 is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'log2');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'log2');
            Log2E=coder.customfloat.helpers.generateLog2E(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.log2(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,Log2Table,Log2MinusTable,Log2E);
            end
        end


        function obj=log10(this)
            if this.flagCmplx
                assert(false,'log10 is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log10Table=coder.customfloat.helpers.generateLog10Table(this.Type);
            Log10MinusTable=coder.customfloat.helpers.generateLog10MinusTable(this.Type);
            Log4thRoot10E=coder.customfloat.helpers.generateLog4thRoot10E(this.Type);
            Log10ExpTable=coder.customfloat.helpers.generateLog10ExpTable_Denormal(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.log10(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,...
                Log10Table,Log10MinusTable,Log4thRoot10E,Log10ExpTable);
            end
        end


        function obj=log(this)
            if this.flagCmplx
                assert(false,'log is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            LogTable=coder.customfloat.helpers.generateLogTable(this.Type);
            LogMinusTable=coder.customfloat.helpers.generateLogMinusTable(this.Type);
            LogExpTable=coder.customfloat.helpers.generateLogExpTable_Denormal(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.log(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,...
                LogTable,LogMinusTable,LogExpTable);
            end
        end


        function obj=pow2(this)
            if this.flagCmplx
                assert(false,'pow2 is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'pow2');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'pow2');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.pow2(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,Log2Table,Log2MinusTable,Ln2);
            end
        end


        function obj=pow10(this)
            if this.flagCmplx
                assert(false,'pow10 is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'pow10');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'pow10');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type);
            Log2_10=coder.customfloat.helpers.generateLog2_10(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.pow10(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,...
                Log2Table,Log2MinusTable,Ln2,Log2_10);
            end
        end


        function obj=exp(this)
            if this.flagCmplx
                assert(false,'exp is not defined for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'exp');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'exp');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type);
            Log2_E=coder.customfloat.helpers.generateLog2_E(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.exp(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),true,...
                Log2Table,Log2MinusTable,Ln2,Log2_E);
            end
        end


        function obj=cosh(this)
            if this.flagCmplx
                assert(false,'cosh is not implemented for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'exp');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'exp');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type);
            Log2_E=coder.customfloat.helpers.generateLog2_E(this.Type);

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.cosh(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                Log2Table,Log2MinusTable,Ln2,Log2_E);
            end
        end


        function obj=sinh(this)
            if this.flagCmplx
                assert(false,'sinh is not implemented for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'sinh');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'sinh');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type,'sinh');
            Log2_E=coder.customfloat.helpers.generateLog2_E(this.Type,'sinh');

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.sinh(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                Log2Table,Log2MinusTable,Ln2,Log2_E);
            end
        end


        function obj=tanh(this)
            if this.flagCmplx
                assert(false,'tanh is not implemented for complex numbers.');
            end
            coder.inline('never');

            obj=CustomFloat.initializeType(size(this),this.Type);

            Log2Table=coder.customfloat.helpers.generateLog2Table(this.Type,'tanh');
            Log2MinusTable=coder.customfloat.helpers.generateLog2MinusTable(this.Type,'tanh');
            Ln2=coder.customfloat.helpers.generateLn2(this.Type,'tanh');
            Log2_E=coder.customfloat.helpers.generateLog2_E(this.Type,'tanh');

            for ii=1:numel(this)
                [obj.SignReal(ii),obj.ExponentReal(ii),obj.MantissaReal(ii)]=...
                coder.customfloat.scalar.tanh(obj.Type,this.SignReal(ii),this.ExponentReal(ii),this.MantissaReal(ii),...
                Log2Table,Log2MinusTable,Ln2,Log2_E);
            end
        end

    end




    methods

        function obj=get.WordLength(this)
            obj=this.Type.WordLength;
        end


        function obj=get.MantissaLength(this)
            obj=this.Type.MantissaLength;
        end


        function obj=get.ExponentLength(this)
            obj=this.Type.ExponentLength;
        end


        function obj=get.ExponentBias(this)
            obj=this.Type.ExponentBias;
        end

    end





    methods(Access='private')
        function obj=isInfOrNaN(this)
            obj=(this.ExponentReal==this.Type.Exponent_Inf_or_NaN);
            if this.flagCmplx
                objReal=obj;
                objImag=(this.ExponentReal==this.Type.Exponent_Inf_or_NaN);
                obj=objReal|objImag;
            end
        end

    end

    methods(Static,Hidden)

        function obj=initializeType(s,cfType,flagComplex)
            if nargin==3
                obj=CustomFloat(zeros(s,'like',fi([],0,cfType.WordLength,0)),cfType,'typecast',flagComplex);
            else
                obj=CustomFloat(zeros(s,'like',fi([],0,cfType.WordLength,0)),cfType,'typecast');
            end
        end


        function out=zerosLike(x,varargin)
            numIndex=length(varargin);
            s=coder.nullcopy(zeros([1,numIndex]));
            for ii=1:numIndex
                s(ii)=varargin{ii};
            end
            out=CustomFloat.initializeType(s,x.Type);
        end


        function out=onesLike(x,varargin)
            numIndex=length(varargin);
            s=coder.nullcopy(zeros([1,numIndex]));
            for ii=1:numIndex
                s(ii)=varargin{ii};
            end

            tmp=fi(repmat(x.Type.ExponentBias,s),0,x.WordLength,x.MantissaLength);
            out=CustomFloat(tmp,x.Type,'typecast');
        end


        function out=typecast(x)
            switch class(x)
            case{'uint64','int64'}
                out=CustomFloat(x,64,52,'typecast');
            case{'uint32','int32'}
                out=CustomFloat(x,32,23,'typecast');
            case{'uint16','int16'}
                out=CustomFloat(x,16,10,'typecast');
            otherwise
                error('Unsupported datatype: %s',class(x));
            end
        end
    end

end
