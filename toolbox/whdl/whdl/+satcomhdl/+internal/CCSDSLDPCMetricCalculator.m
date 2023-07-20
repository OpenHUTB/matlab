classdef(StrictDefaults)CCSDSLDPCMetricCalculator<matlab.System




%#codegen

    properties(Nontunable)
        alphaWL=6;
        alphaFL=0;
        betaWL=4;
        minWL=3;
        betaCompWL=32;
        betaIdxWL=8;
        memDepth=64;
    end


    properties(Access=private)


        functionalUnit;
        checkNodeRAM;

        betaDelayBalancer1;
        betaDelayBalancer2;
        betaDelayBalancer3;
        betaDelayBalancer4;
        betaDelayBalancer5;


        betaDecomp1;
        betaDecomp2;
        betaDecomp3;
        betaDecomp4;
        betaValid;
        colVal;
        shiftValReg;
        shiftData;
        shiftValid;
        sValid;


        gammaOut;
        gammaValid;
        gData;
        grdEnable;
    end

    methods


        function obj=CCSDSLDPCMetricCalculator(varargin)
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

            reset(obj.functionalUnit);
            reset(obj.checkNodeRAM);
            reset(obj.betaDelayBalancer1);
            reset(obj.betaDelayBalancer2);
            reset(obj.betaDelayBalancer3);
            reset(obj.betaDelayBalancer4);
            reset(obj.betaDelayBalancer5);

            obj.gammaOut(:)=zeros(obj.memDepth,1);
            obj.gammaValid(:)=false;
            obj.gData(:)=zeros(obj.memDepth,1);
            obj.grdEnable(:)=zeros(obj.memDepth,1);
        end

        function setupImpl(obj,varargin)


            obj.checkNodeRAM=satcomhdl.internal.CCSDSLDPCCheckNodeRAM('memDepth',obj.memDepth);


            obj.functionalUnit=satcomhdl.internal.CCSDSLDPCFunctionalUnit('alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,...
            'betaWL',obj.betaWL,'minWL',obj.minWL,'betaCompWL',obj.betaCompWL,...
            'betaIdxWL',obj.betaIdxWL,'memDepth',obj.memDepth);


            obj.betaDelayBalancer1=dsp.Delay(obj.memDepth);
            obj.betaDelayBalancer2=dsp.Delay(obj.memDepth);
            obj.betaDelayBalancer3=dsp.Delay(obj.memDepth);
            obj.betaDelayBalancer4=dsp.Delay(obj.memDepth);
            obj.betaDelayBalancer5=dsp.Delay(1);


            obj.betaDecomp1=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaDecomp2=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaDecomp3=fi(zeros(obj.memDepth,1),0,obj.betaIdxWL,0);
            obj.betaDecomp4=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValid=false;
            obj.shiftValReg=fi(0,0,7,0);
            obj.shiftData=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.shiftValid=false;
            obj.sValid=false;


            obj.gammaOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.gammaValid=false;
            obj.gData=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.grdEnable=fi(zeros(obj.memDepth,1),0,1,0);
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.gammaOut;
            varargout{2}=obj.gammaValid;
            varargout{3}=obj.gData;
            varargout{4}=obj.grdEnable;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            valid=varargin{2};
            shift=varargin{3};
            count=varargin{4};
            betaread=varargin{5};
            rdenable=varargin{6};
            layeridx=varargin{7};
            reset=varargin{8};
            shiftsel=varargin{9};


            if obj.memDepth==64
                data_adj=data;
            else
                if shiftsel==0
                    data_adj=data;
                elseif shiftsel==1
                    data_adj=[data(1:64),data(1:64)];
                elseif shiftsel==2
                    data_adj=[data(1:32),data(1:32),data(1:32),data(1:32)];
                else
                    data_adj=data;
                end
            end
            sdata=circshift(data_adj,int32(obj.memDepth-double(shift)));


            betaenb=(valid&&(~obj.sValid))&&betaread;
            obj.sValid(:)=valid;


            betain1=obj.betaDecomp1;
            betain2=obj.betaDecomp2;
            betain3=obj.betaDecomp3;
            betain4=obj.betaDecomp4;
            wrenbbeta=obj.betaValid;
            [cnudecomp1,cnudecomp2,cnudecomp3,cnudecomp4,cnuvalid]=obj.checkNodeRAM(...
            betain1,betain2,betain3,betain4,layeridx,betaenb,wrenbbeta);


            [gamma,gvalid,betadecomp1,betadecomp2,betadecomp3,betadecomp4,betavalid,...
            shiftout,rdenbout]=obj.functionalUnit(obj.shiftData,obj.shiftValid,...
            count,rdenable,cnudecomp1,cnudecomp2,cnudecomp3,cnudecomp4,...
            cnuvalid,reset,obj.shiftValReg);
            obj.shiftValReg(:)=shift;
            obj.shiftData(:)=sdata;
            obj.shiftValid(:)=valid;

            obj.betaDecomp1(:)=obj.betaDelayBalancer1(betadecomp1);
            obj.betaDecomp2(:)=obj.betaDelayBalancer2(betadecomp2);
            obj.betaDecomp3(:)=obj.betaDelayBalancer3(betadecomp3);
            obj.betaDecomp4(:)=obj.betaDelayBalancer4(betadecomp4);
            obj.betaValid(:)=obj.betaDelayBalancer5(betavalid);


            if obj.memDepth==64
                gamma_adj=gamma;
            else
                if shiftsel==0
                    gamma_adj=gamma;
                elseif shiftsel==1
                    gamma_adj=[gamma(1:64),gamma(1:64)];
                elseif shiftsel==2
                    gamma_adj=[gamma(1:32),gamma(1:32),gamma(1:32),gamma(1:32)];
                else
                    gamma_adj=gamma;
                end
            end
            obj.gammaOut(:)=circshift(gamma_adj,int32(shiftout));
            obj.gammaValid(:)=gvalid;
            obj.gData(:)=gamma;
            obj.grdEnable(:)=rdenbout;

        end

        function num=getNumInputsImpl(~)
            num=9;
        end

        function num=getNumOutputsImpl(~)
            num=4;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;
                s.betaWL=obj.betaWL;
                s.minWL=obj.minWL;
                s.betaCompWL=obj.betaCompWL;
                s.betaIdxWL=obj.betaIdxWL;
                s.memDepth=obj.memDepth;


                s.functionalUnit=obj.functionalUnit;
                s.checkNodeRAM=obj.checkNodeRAM;
                s.betaDelayBalancer1=obj.betaDelayBalancer1;
                s.betaDelayBalancer2=obj.betaDelayBalancer2;
                s.betaDelayBalancer3=obj.betaDelayBalancer3;
                s.betaDelayBalancer4=obj.betaDelayBalancer4;
                s.betaDelayBalancer5=obj.betaDelayBalancer5;


                s.betaDecomp1=obj.betaDecomp1;
                s.betaDecomp2=obj.betaDecomp2;
                s.betaDecomp3=obj.betaDecomp3;
                s.betaDecomp4=obj.betaDecomp4;
                s.betaValid=obj.betaValid;
                s.shiftData=obj.shiftData;
                s.shiftValid=obj.shiftValid;
                s.sValid=obj.sValid;
                s.shiftValReg=obj.shiftValReg;


                s.gammaOut=obj.gammaOut;
                s.gammaValid=obj.gammaValid;
                s.gData=obj.gData;
                s.grdEnable=obj.grdEnable;

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


