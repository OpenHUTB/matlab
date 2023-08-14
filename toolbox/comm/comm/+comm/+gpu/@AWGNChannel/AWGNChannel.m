classdef(StrictDefaults)AWGNChannel<comm.gpu.internal.GPUSystem














































































    properties(Nontunable)





        NoiseMethod='Signal to noise ratio (Eb/No)';
    end
    properties






        EbNo=10;






        EsNo=10;






        SNR=10;
    end
    properties(Nontunable)






        BitsPerSymbol=1;
    end

    properties








        SignalPower=1;
    end

    properties(Nontunable)






        SamplesPerSymbol=1;







        VarianceSource='Property';
    end

    properties






        Variance=1;
    end

    properties(Nontunable)





        RandomStream='Global stream';


        Seed=67;
    end

    properties(Constant,Hidden)
        NoiseMethodSet=matlab.system.StringSet({...
        'Signal to noise ratio (Eb/No)',...
        'Signal to noise ratio (Es/No)','Signal to noise ratio (SNR)',...
        'Variance'});
        VarianceSourceSet=comm.CommonSets.getSet('SpecifyInputs');
        RandomStreamSet=matlab.system.StringSet({'Global stream'});
    end

    properties(Access=private)
pVarianceInput
    end

    properties(Access=private,Nontunable)



pNumChannels
pSamplesPerFrame
pComplexOutput
pDataType
pDivisor
    end

    methods
        function obj=AWGNChannel(varargin)
            setProperties(obj,nargin,varargin{:});
        end

        function set.EbNo(obj,val)
            validateattributes(val,{'numeric'},{'real','row'},...
            '','EbNo');
            obj.EbNo=val;
        end

        function set.EsNo(obj,val)
            validateattributes(val,{'numeric'},{'real','row'},...
            '','EsNo');
            obj.EsNo=val;
        end

        function set.SNR(obj,val)
            validateattributes(val,{'numeric'},{'real','row'},...
            '','SNR');
            obj.SNR=val;
        end

        function set.BitsPerSymbol(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','positive','integer','row'},'',...
            'BitsPerSymbol');
            obj.BitsPerSymbol=val;
        end

        function set.SignalPower(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','positive','row'},'','SignalPower');
            obj.SignalPower=val;
        end

        function set.SamplesPerSymbol(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','positive','integer','row'},'',...
            'SamplesPerSymbol');
            obj.SamplesPerSymbol=val;
        end

        function set.Variance(obj,val)
            validateattributes(val,{'numeric'},...
            {'real','nonnegative','row'},'','Variance');
            obj.Variance=val;
        end

        function set.Seed(obj,seed)
            propName='Seed';
            validateattributes(seed,{'double'},...
            {'real','scalar','integer','nonnegative','finite'},...
            [class(obj),'.',propName],propName);

            obj.Seed=seed;
        end
    end

    methods(Access=protected)
        function y=stepGPUImpl(obj,x,varargin)

            if obj.pComplexOutput
                randData=(gpuArray.randn(obj.pSamplesPerFrame,...
                obj.pNumChannels,obj.pDataType)+...
                1i*gpuArray.randn(obj.pSamplesPerFrame,...
                obj.pNumChannels,obj.pDataType))/obj.pDivisor;
            else
                randData=gpuArray.randn(obj.pSamplesPerFrame,...
                obj.pNumChannels,obj.pDataType);
            end

            if getNoiseMethodIdx(obj)==5
                if any(varargin{1}<0)
                    error(message('comm:system:DAWGN:varInNotRealNonNeg'));
                end
                theVariance=sqrt(varargin{1});
                if isscalar(theVariance)
                    y=x+randData*theVariance;
                else
                    y=x+randData*diag(theVariance);
                end
            else

                y=x+randData*diag(sqrt(obj.pVarianceInput));
            end
        end

        function num=getNumInputsImpl(obj)
            num=1;
            if(getNoiseMethodIdx(obj)==5)

                num=2;
            end
        end

        function validatePropertiesImpl(obj)
            switch obj.NoiseMethod
            case 'Signal to noise ratio (Eb/No)'
                lengthVec=zeros(4,1);
                lengthVec(1)=length(obj.EbNo);
                lengthVec(2)=length(obj.BitsPerSymbol);
                lengthVec(3)=length(obj.SignalPower);
                lengthVec(4)=length(obj.SamplesPerSymbol);
            case 'Signal to noise ratio (Es/No)'
                lengthVec=zeros(3,1);
                lengthVec(1)=length(obj.EsNo);
                lengthVec(2)=length(obj.SignalPower);
                lengthVec(3)=length(obj.SamplesPerSymbol);
            case 'Signal to noise ratio (SNR)'
                lengthVec=zeros(2,1);
                lengthVec(1)=length(obj.SNR);
                lengthVec(2)=length(obj.SignalPower);
            otherwise
                return;
            end
            valid=true;
            numChan=1;
            for p=1:length(lengthVec)
                if(lengthVec(p)>1)
                    if(numChan==1)
                        numChan=lengthVec(p);
                    end
                    valid=(numChan==lengthVec(p));
                end
                if~valid
                    break
                end
            end
            if~valid
                error(message('comm:system:AWGNChannel:PropsNotSameLength'))
            end
        end

        function processTunedPropertiesImpl(obj)
            noiseIndex=getNoiseMethodIdx(obj);


            if noiseIndex<5
                checkPropertyDimensions(obj);
            end

            switch(noiseIndex)
            case 1
                obj.setVarianceFromEbNo;
            case 2
                obj.setVarianceFromEsNo;
            case 3
                obj.setVarianceFromSNR;
            case 4
                obj.setVarianceFromProperty;
            end
        end

        function setupGPUImpl(obj,varargin)

            sizeY=0;
            if nargin>1
                sizeY=size(varargin{1});
            end

            if numel(sizeY)>2
                error(message('comm:system:AWGNChannel:Expected2D'));
            end


            obj.pSamplesPerFrame=sizeY(1);

            obj.pNumChannels=sizeY(2);



            obj.pComplexOutput=~isreal(varargin{1});


            if isInputGPUArray(obj,1)
                obj.pDataType=underlyingType(varargin{1});
            else
                obj.pDataType=class(varargin{1});
                if isa(varargin{1},'embedded.fi')
                    if issingle(varargin{1})
                        obj.pDataType='single';
                    elseif isdouble(varargin{1})
                        obj.pDataType='double';
                    end
                end
            end

            if(~strcmp(obj.pDataType,'double')&&~strcmp(obj.pDataType,'single'))
                error(message('comm:system:AWGNChannel:InputNotDoubleOrSingle'));
            end

            if obj.pComplexOutput
                obj.pDivisor=gpuArray(cast(sqrt(2),obj.pDataType));
            else
                obj.pDivisor=gpuArray(1);
            end
            noiseIndex=getNoiseMethodIdx(obj);



            switch noiseIndex
            case 1
                checkPropertyDimensions(obj);
                obj.setVarianceFromEbNo;
            case 2
                checkPropertyDimensions(obj);
                obj.setVarianceFromEsNo;
            case 3
                checkPropertyDimensions(obj);
                obj.setVarianceFromSNR;
            case 4
                checkPropertyDimensions(obj);
                obj.setVarianceFromProperty;
            case 5
                sz=0;
                if size(varargin,2)>1
                    sz=size(varargin{2});
                end

                if any(sz>1)
                    if any(sz~=[1,obj.pNumChannels])
                        error(message('comm:system:AWGNChannel:InvalidInputVARDims',obj.pNumChannels));
                    end
                end
                if~isreal(varargin{2})
                    error(message('comm:system:DAWGN:varInNotRealNonNeg'));
                end
            end

        end

        function flag=isInactivePropertyImpl(obj,prop)
            switch getNoiseMethodIdx(obj)
            case 1
                props={'EsNo','SNR','VarianceSource','Variance'};
            case 2
                props={'EbNo','SNR','VarianceSource','Variance',...
                'BitsPerSymbol'};
            case 3
                props={'EbNo','EsNo','VarianceSource','Variance',...
                'BitsPerSymbol','SamplesPerSymbol'};
            case 4
                props={'EbNo','EsNo','SNR','BitsPerSymbol'...
                ,'SamplesPerSymbol','SignalPower'};
            case 5
                props={'EbNo','EsNo','SNR','BitsPerSymbol'...
                ,'SamplesPerSymbol','SignalPower','Variance'};
            end

            props=[props,'Seed'];

            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function flag=generatesCode()
            flag=false;
        end

    end

    methods(Access=private)
        function idx=getNoiseMethodIdx(obj)
            switch obj.NoiseMethod
            case 'Signal to noise ratio (Eb/No)'
                idx=1;
            case 'Signal to noise ratio (Es/No)'
                idx=2;
            case 'Signal to noise ratio (SNR)'
                idx=3;
            case 'Variance'
                idx=4+strcmp(obj.VarianceSource,'Input port');
            end
        end

        function checkPropertyDimensions(obj)

            noiseIdx=getNoiseMethodIdx(obj);
            switch noiseIdx
            case 1
                len=length(obj.EbNo);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertyEbNoDimensions','EbNo'));
                end

                len=length(obj.BitsPerSymbol);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertyBitsPerSymbolDimensions','BitsPerSymbol'));
                end
            case 2
                len=length(obj.EsNo);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertyEsNoDimensions','EsNo'));
                end
            case 3
                len=length(obj.SNR);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertySNRDimensions','SNR'));
                end
            case 4
                len=length(obj.Variance);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertyVarianceDimensions','Variance'));
                end
            end

            if noiseIdx<4
                len=length(obj.SignalPower);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertySignalPowerDimensions','SignalPower'));
                end
            end

            if noiseIdx<3
                len=length(obj.SamplesPerSymbol);
                if~(len==1||len==obj.pNumChannels)
                    error(message('comm:system:AWGNChannel:InvalidPropertySamplesPerSymbolDimensions','SamplesPerSymbol'));
                end
            end
        end

        function setVarianceFromProperty(obj)






            if isscalar(obj.Variance)
                obj.pVarianceInput=gpuArray(...
                cast(obj.Variance,obj.pDataType)*...
                ones(1,obj.pNumChannels,obj.pDataType));
            else
                obj.pVarianceInput=...
                gpuArray(cast(obj.Variance,obj.pDataType));
            end

        end
        function setVarianceFromEbNo(obj)
            obj.pVarianceInput=gpuArray(...
            (obj.SignalPower.*obj.SamplesPerSymbol)...
            ./((10.^(obj.EbNo/10).*obj.BitsPerSymbol)));
            if~obj.pComplexOutput
                obj.pVarianceInput=obj.pVarianceInput*0.5;
            end
        end
        function setVarianceFromEsNo(obj)
            obj.pVarianceInput=gpuArray(...
            (obj.SignalPower.*obj.SamplesPerSymbol)...
            ./(10.^(obj.EsNo/10)));
            if~obj.pComplexOutput
                obj.pVarianceInput=(obj.pVarianceInput*0.5);
            end
        end

        function setVarianceFromSNR(obj)
            obj.pVarianceInput=gpuArray(obj.SignalPower./(10.^(obj.SNR/10)));
        end
    end



    methods(Access=protected)
        function varargout=getOutputSizeImpl(obj)
            varargout={propagatedInputSize(obj,1)};
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout={propagatedInputDataType(obj,1)};
        end

        function varargout=isOutputComplexImpl(obj)
            varargout={propagatedInputComplexity(obj,1)};
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout={true};
        end

    end
end


