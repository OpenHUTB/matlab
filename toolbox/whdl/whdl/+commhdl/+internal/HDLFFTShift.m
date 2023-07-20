classdef(StrictDefaults)HDLFFTShift<matlab.System




%#codegen
%#ok<*EMCLS>




    properties(Nontunable)
        resetPort(1,1)logical=false;
    end
    properties(Access=private)
        rePart;
        imPart;
        count;
        validOut;
        resetSig;
    end





    methods



        function obj=HDLFFTShift(varargin)
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





        function num=getNumInputsImpl(obj)
            rPort=0;
            if obj.resetPort
                rPort=1;
            end
            num=2+rPort;
        end



        function num=getNumOutputsImpl(~)
            num=2;
        end



        function setupImpl(obj,varargin)
            obj.count=false;
            obj.rePart=cast(zeros(length(varargin{1}),1),'like',real(varargin{1}));
            obj.imPart=cast(zeros(length(varargin{1}),1),'like',imag(varargin{1}));
            obj.validOut=false;
            obj.resetSig=false;
        end


        function resetImpl(obj)
            obj.rePart(:)=0;
            obj.imPart(:)=0;
            obj.count=false;
            obj.validOut=false;
        end


        function varargout=outputImpl(obj,varargin)
            varargout{1}=complex(obj.rePart,obj.imPart);
            varargout{2}=obj.validOut;
        end



        function updateImpl(obj,varargin)


            dataIn=varargin{1};
            validIn=varargin{2};

            if obj.resetPort
                obj.resetSig=varargin{3};
            end

            temp1=-real(dataIn);
            temp2=-imag(dataIn);

            if validIn
                for ii=0:(length(varargin{1})-1)
                    if obj.count
                        obj.rePart(ii+1)=cast(temp1(ii+1),'like',real(dataIn(1)));
                        obj.imPart(ii+1)=cast(temp2(ii+1),'like',real(dataIn(1)));
                        obj.count=false;
                    else
                        obj.rePart(ii+1)=real(dataIn(ii+1));
                        obj.imPart(ii+1)=imag(dataIn(ii+1));
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
                s.resetSig=obj.resetSig;
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

