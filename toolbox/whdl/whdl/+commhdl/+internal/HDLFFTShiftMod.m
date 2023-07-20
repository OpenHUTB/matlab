classdef(StrictDefaults)HDLFFTShiftMod<matlab.System




%#codegen
%#ok<*EMCLS>



    properties(Nontunable)
        OFDMParametersSource='Property';
        MaxFFTLength=2048;
        FFTLength=1024;
        CPLength=16;
        winLength=4;
        maxWinLength=8;
    end

    properties(Constant,Hidden)
        OFDMParametersSourceSet=matlab.system.StringSet({...
        'Property','Input port'});
    end

    properties(Nontunable)
        ResetInputPort(1,1)logical=false;
        Windowing(1,1)logical=false;
    end
    properties(Access=private)
        rePart;
        imPart;
        count;
        validOut;
        FFTLen;
        CPLen;
        resetSig;
        winLen;
    end





    methods


        function obj=HDLFFTShiftMod(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end




    end

    methods(Access=protected)


        function flag=isInactivePropertyImpl(obj,prop)


            props={};
            if~strcmpi(obj.OFDMParametersSource,'Property')
                props=[props,{'FFTLength'},{'CPLength'}];
            else
                props=[props,{'MaxFFTLength'}];
            end
            if~obj.Windowing
                props=[props,{'winLength'},{'maxWinLength'}];
            end
            flag=ismember(prop,props);
        end


        function num=getNumInputsImpl(obj)
            rPort=0;
            oPort=0;
            if obj.ResetInputPort
                rPort=1;
            end
            if strcmpi(obj.OFDMParametersSource,'Input port')
                if obj.Windowing
                    oPort=3;
                else
                    oPort=2;
                end
            end
            num=2+rPort+oPort;
        end



        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.OFDMParametersSource,'Input port')
                if obj.Windowing
                    num=5;
                else
                    num=4;
                end
            else
                num=2;
            end
        end



        function setupImpl(obj,varargin)
            obj.count=false;
            obj.rePart=cast(zeros(length(varargin{1}),1),'like',real(varargin{1}));
            obj.imPart=cast(zeros(length(varargin{1}),1),'like',imag(varargin{1}));
            obj.validOut=false;
            obj.resetSig=false;
            if strcmp(obj.OFDMParametersSource,'Input port')
                obj.FFTLen=cast(64,'like',varargin{3});
                obj.CPLen=cast(16,'like',varargin{4});
                if obj.Windowing
                    obj.winLen=cast(0,'like',varargin{5});
                end
            end
        end


        function resetImpl(obj)
            obj.rePart(:)=0;
            obj.imPart(:)=0;
            obj.count=false;
            obj.validOut=false;
            if obj.Windowing
                obj.winLen(:)=0;
            end
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=complex(obj.rePart,obj.imPart);
            varargout{2}=obj.validOut;
            if strcmp(obj.OFDMParametersSource,'Input port')
                varargout{3}=obj.FFTLen;
                varargout{4}=obj.CPLen;
                if obj.Windowing
                    varargout{5}=obj.winLen;
                end
            end
        end



        function updateImpl(obj,varargin)





            dataIn=varargin{1};
            validIn=varargin{2};
            if strcmp(obj.OFDMParametersSource,'Input port')
                obj.FFTLen(:)=varargin{3};
                obj.CPLen(:)=varargin{4};
                if obj.Windowing
                    obj.winLen(:)=varargin{5};
                    if obj.ResetInputPort
                        obj.resetSig=varargin{6};
                    end
                else
                    if obj.ResetInputPort
                        obj.resetSig=varargin{5};
                    end
                end
            else
                if obj.ResetInputPort
                    obj.resetSig=varargin{3};
                end
            end

            temp1=-real(dataIn);
            temp2=-imag(dataIn);
            if validIn
                for ii=1:length(varargin{1})
                    if obj.count
                        obj.rePart(ii)=cast(temp1(ii),'like',real(dataIn(1)));
                        obj.imPart(ii)=cast(temp2(ii),'like',real(dataIn(1)));
                        obj.count=false;
                    else
                        obj.rePart(ii)=real(dataIn(ii));
                        obj.imPart(ii)=imag(dataIn(ii));
                        obj.count=true;
                    end
                end
            else
                obj.rePart(:)=real(dataIn);
                obj.imPart(:)=imag(dataIn);
            end
            obj.validOut=validIn;
            ifResetTrue(obj);
        end
        function ifResetTrue(obj)
            if obj.resetSig
                resetImpl(obj);
            end
        end
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.count=obj.count;
                s.rePart=obj.rePart;
                s.imPart=obj.imPart;
                s.validOut=obj.validOut;
                s.FFTLen=obj.FFTLen;
                s.CPLen=obj.CPLen;
                s.winLen=obj.winLen;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end



        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

    end


end

