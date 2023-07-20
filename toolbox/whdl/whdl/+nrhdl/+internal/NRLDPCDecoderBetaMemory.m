classdef(StrictDefaults)NRLDPCDecoderBetaMemory<matlab.System




%#codegen

    properties(Nontunable)
        memDepth=384;
    end


    properties(Access=private)
        beta1;
        beta2;

        betaOut1;
        betaOut2;
        validOut;
    end

    methods


        function obj=NRLDPCDecoderBetaMemory(varargin)
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

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function resetImpl(obj)

            obj.betaOut1(:)=zeros(obj.memDepth,1);
            obj.betaOut2(:)=zeros(obj.memDepth,1);
            obj.validOut=false;
        end

        function setupImpl(obj,varargin)

            obj.beta1=cast(zeros(46,obj.memDepth),'like',varargin{1});
            obj.beta2=cast(zeros(46,obj.memDepth),'like',varargin{2});

            obj.betaOut1=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.betaOut2=cast(zeros(obj.memDepth,1),'like',varargin{2});
            obj.validOut=false;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.betaOut1;
            varargout{2}=obj.betaOut2;
            varargout{3}=obj.validOut;
        end

        function updateImpl(obj,varargin)

            betain1=varargin{1};
            betain2=varargin{2};
            count_layer=varargin{3};
            rd_enb=varargin{4};
            wr_enb=varargin{5};


            if(rd_enb)
                obj.betaOut1(:)=obj.beta1(double(count_layer),:);
                obj.betaOut2(:)=obj.beta2(double(count_layer),:);
            end


            if(wr_enb)
                obj.beta1(double(count_layer),:)=betain1;
                obj.beta2(double(count_layer),:)=betain2;
            end
            obj.validOut=rd_enb;
        end

        function num=getNumInputsImpl(~)
            num=5;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.beta1=obj.beta1;
                s.beta2=obj.beta2;
                s.betaOut1=obj.betaOut1;
                s.betaOut2=obj.betaOut2;
                s.validOut=obj.validOut;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end
end
