classdef(StrictDefaults)CCSDSLDPCCheckNodeRAM<matlab.System

%#codegen

    properties(Nontunable)
        memDepth=64;
    end


    properties(Access=private)
        beta1;
        beta2;
        beta3;
        beta4;

        betaOut1;
        betaOut2;
        betaOut3;
        betaOut4;
        validOut;
    end

    methods


        function obj=CCSDSLDPCCheckNodeRAM(varargin)
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
            obj.betaOut3(:)=zeros(obj.memDepth,1);
            obj.betaOut4(:)=zeros(obj.memDepth,1);
            obj.validOut(:)=false;
        end

        function setupImpl(obj,varargin)

            if obj.memDepth==64
                nrow=16;
            else
                nrow=192;
            end

            obj.beta1=cast(zeros(nrow,obj.memDepth),'like',varargin{1});
            obj.beta2=cast(zeros(nrow,obj.memDepth),'like',varargin{2});
            obj.beta3=cast(zeros(nrow,obj.memDepth),'like',varargin{3});
            obj.beta4=cast(zeros(nrow,obj.memDepth),'like',varargin{4});

            obj.betaOut1=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.betaOut2=cast(zeros(obj.memDepth,1),'like',varargin{2});
            obj.betaOut3=cast(zeros(obj.memDepth,1),'like',varargin{3});
            obj.betaOut4=cast(zeros(obj.memDepth,1),'like',varargin{4});
            obj.validOut=false;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.betaOut1;
            varargout{2}=obj.betaOut2;
            varargout{3}=obj.betaOut3;
            varargout{4}=obj.betaOut4;
            varargout{5}=obj.validOut;
        end

        function updateImpl(obj,varargin)

            betain1=varargin{1};
            betain2=varargin{2};
            betain3=varargin{3};
            betain4=varargin{4};
            count_layer=varargin{5};
            rd_enb=varargin{6};
            wr_enb=varargin{7};


            if(rd_enb)
                obj.betaOut1(:)=obj.beta1(double(count_layer),:);
                obj.betaOut2(:)=obj.beta2(double(count_layer),:);
                obj.betaOut3(:)=obj.beta3(double(count_layer),:);
                obj.betaOut4(:)=obj.beta4(double(count_layer),:);
            end


            if(wr_enb)
                obj.beta1(double(count_layer),:)=betain1;
                obj.beta2(double(count_layer),:)=betain2;
                obj.beta3(double(count_layer),:)=betain3;
                obj.beta4(double(count_layer),:)=betain4;
            end
            obj.validOut=rd_enb;
        end

        function num=getNumInputsImpl(~)
            num=7;
        end

        function num=getNumOutputsImpl(~)
            num=5;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.beta1=obj.beta1;
                s.beta2=obj.beta2;
                s.beta3=obj.beta3;
                s.beta4=obj.beta4;
                s.betaOut1=obj.betaOut1;
                s.betaOut2=obj.betaOut2;
                s.betaOut3=obj.betaOut3;
                s.betaOut4=obj.betaOut4;
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
