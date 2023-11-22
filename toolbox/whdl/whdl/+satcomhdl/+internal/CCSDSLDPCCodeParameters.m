classdef(StrictDefaults)CCSDSLDPCCodeParameters<matlab.System

%#codegen

    properties(Nontunable)
        LDPCConfiguration='(8160,7136) LDPC'
    end


    properties(Access=private)
        resetReg;
        initValid;
        zeroData;
        dataMux;
        dataReg;
        validReg;
        endReg;
        validO;
        frameValid;

        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        dataRegW;
        dataOutW;
        dataOutW1;
        frameValidW;
        endRegW;
        endRegW1;
        selCount;
        count;
        validOutW;
        endInd;
        endReg1;
        extraDelay;
        dataRegW1;
        frameValidB;
        resetW;
        resetW1;

        dataOut;
        validOut;
        frameValidOut;
        resetOut;
        endIndOut;
    end


    properties(Nontunable,Access=private)
        vectorSize;
    end

    properties(Constant,Hidden)
        LDPCConfigurationSet=matlab.system.StringSet({'(8160,7136) LDPC','AR4JA LDPC'});
    end

    methods

        function obj=CCSDSLDPCCodeParameters(varargin)
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

            obj.dataOut(:)=zeros(obj.vectorSize,1);
            obj.validOut=false;
            obj.frameValidOut=false;
            obj.resetOut=false;
            obj.endIndOut=false;
        end

        function setupImpl(obj,varargin)

            obj.vectorSize=size(varargin{1},1);

            obj.resetReg=false;
            obj.resetW=false;
            obj.resetW1=false;
            obj.initValid=false;
            obj.zeroData=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataMux=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataReg=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.validReg=false;
            obj.endReg=false;
            obj.validO=false;
            obj.frameValid=false;
            obj.frameValidB=false;

            obj.extraDelay=false;
            obj.dataRegW=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataRegW1=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataOutW=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataOutW1=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.frameValidW=false;
            obj.endRegW=false;
            obj.endRegW1=false;
            obj.selCount=fi(1,0,4,0,hdlfimath);
            obj.count=fi(0,0,7,0,hdlfimath);
            obj.validOutW=false;
            obj.endInd=false;
            obj.endReg1=false;

            obj.delayBalancer1=dsp.Delay(2*obj.vectorSize,"ResetInputPort",true);
            obj.delayBalancer2=dsp.Delay(2,"ResetInputPort",true);
            obj.delayBalancer3=dsp.Delay(2,"ResetInputPort",true);
            obj.delayBalancer4=dsp.Delay(2,"ResetInputPort",true);

            obj.dataOut=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.validOut=false;
            obj.frameValidOut=false;
            obj.resetOut=false;
            obj.endIndOut=false;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.frameValidOut;
            varargout{4}=obj.resetOut;
            varargout{5}=obj.endIndOut;
        end

        function updateImpl(obj,varargin)

            datai=varargin{1};
            starti=varargin{2}.start;
            endi=varargin{2}.end;
            validi=varargin{2}.valid;
            nframe=varargin{3};

            if obj.vectorSize==8&&strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                reset=starti&&validi||nframe;


                if reset
                    end_tmp=false;
                else
                    end_tmp=endi;
                end
                data_delay=obj.delayBalancer1(datai,reset);
                start_delay=obj.delayBalancer2(starti,reset);
                end_delay=obj.delayBalancer3(end_tmp,reset);
                valid_delay=obj.delayBalancer4(validi,reset);



                [datamux,starto,endo,valido]=frameControllerBase(obj,reset,data_delay,start_delay,end_delay,valid_delay);



                [datao,valido,framevalid,endind]=writeController(obj,reset,datamux,starto,endo,valido);
            else



                [reset,datao,valido,framevalid,endind]=frameController(obj,datai,starti,endi,validi);
            end
            obj.dataOut(:)=datao;
            obj.validOut(:)=valido;
            obj.frameValidOut(:)=framevalid;
            obj.resetOut(:)=reset;
            obj.endIndOut(:)=endind;

        end

        function[datao,starto,endo,valido]=frameControllerBase(obj,reset,datai,starti,endi,validi)

            if reset
                valido=false;
                starto=false;
            else
                valido=obj.initValid||obj.validReg;
                starto=obj.resetReg;
            end

            if reset||obj.resetReg
                endo=false;
            else
                endo=obj.endReg&&obj.validReg;
            end

            if obj.initValid
                datao=obj.zeroData;
            else
                datao=obj.dataMux;
            end

            if reset||obj.resetReg
                obj.initValid(:)=true;
            else
                obj.initValid(:)=false;
            end
            obj.resetReg(:)=reset;

            if reset
                obj.frameValidB(:)=false;
            else
                if starti&&validi
                    obj.frameValidB(:)=true;
                elseif obj.endReg&&obj.validReg
                    obj.frameValidB(:)=false;
                end
            end

            if reset
                obj.dataMux(:)=zeros(8,1);
                obj.dataReg(:)=zeros(8,1);
            else
                if obj.frameValidB
                    if validi
                        obj.dataMux=[obj.dataReg(7);obj.dataReg(8);datai(1);...
                        datai(2);datai(3);datai(4);datai(5);datai(6)];
                        obj.dataReg(:)=datai;
                    end
                else
                    obj.dataMux(:)=zeros(8,1);
                    obj.dataReg(:)=zeros(8,1);
                end
            end

            obj.validReg=validi;
            obj.endReg=endi;
        end

        function[datao,valido,framevalid,endind]=writeController(obj,reset,data,starti,endi,validi)

            if obj.validOutW
                obj.dataOutW1(:)=obj.dataOutW;
            end

            datao=obj.dataOutW1;
            valido=obj.validOutW;
            framevalid=obj.frameValidW;
            endind=obj.endInd;

            if reset
                obj.frameValidW(:)=false;
                obj.endInd(:)=false;
            else
                if starti&&validi
                    obj.frameValidW(:)=true;
                    obj.endInd(:)=false;
                elseif obj.endReg1
                    obj.frameValidW(:)=false;
                    obj.endInd(:)=true;
                end
            end

            if obj.resetW1
                obj.endReg1(:)=false;
            else
                obj.endReg1(:)=obj.endRegW1;
            end

            if obj.resetW
                obj.endRegW1(:)=false;
            else
                obj.endRegW1(:)=obj.endRegW;
            end

            if reset
                obj.endRegW(:)=false;
            else
                obj.endRegW(:)=endi&&validi;
            end

            obj.resetW1(:)=obj.resetW;
            obj.resetW(:)=reset;

            if reset
                obj.selCount(:)=1;
                obj.count(:)=0;
                obj.extraDelay(:)=false;
            elseif obj.frameValidW&&validi
                if obj.count==fi(64,0,7,0)
                    obj.count(:)=1;
                    if obj.selCount==fi(8,0,4,0)
                        obj.selCount(:)=1;
                        obj.extraDelay(:)=true;
                    else
                        obj.selCount(:)=obj.selCount+1;
                    end
                else
                    obj.count(:)=obj.count+1;
                end
            end

            edelay=obj.extraDelay;
            if edelay
                if obj.selCount==fi(1,0,4,0)
                    obj.dataOutW(:)=obj.dataRegW;
                elseif obj.selCount==fi(2,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);obj.dataRegW(3);obj.dataRegW(4);obj.dataRegW(5);obj.dataRegW(6);obj.dataRegW(7)];
                elseif obj.selCount==fi(3,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);obj.dataRegW(3);obj.dataRegW(4);obj.dataRegW(5);obj.dataRegW(6)];
                elseif obj.selCount==fi(4,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(6);obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);obj.dataRegW(3);obj.dataRegW(4);obj.dataRegW(5)];
                elseif obj.selCount==fi(5,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(5);obj.dataRegW1(6);obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);obj.dataRegW(3);obj.dataRegW(4)];
                elseif obj.selCount==fi(6,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(4);obj.dataRegW1(5);obj.dataRegW1(6);obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);obj.dataRegW(3)];
                elseif obj.selCount==fi(7,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(3);obj.dataRegW1(4);obj.dataRegW1(5);obj.dataRegW1(6);obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);obj.dataRegW(2);];
                elseif obj.selCount==fi(8,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW1(2);obj.dataRegW1(3);obj.dataRegW1(4);obj.dataRegW1(5);obj.dataRegW1(6);obj.dataRegW1(7);obj.dataRegW1(8);obj.dataRegW(1);];
                else
                    obj.dataOutW(:)=obj.dataRegW;
                end
            else
                if obj.selCount==fi(1,0,4,0)
                    obj.dataOutW(:)=data;
                elseif obj.selCount==fi(2,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(8);data(1);data(2);data(3);data(4);data(5);data(6);data(7)];
                elseif obj.selCount==fi(3,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(7);obj.dataRegW(8);data(1);data(2);data(3);data(4);data(5);data(6)];
                elseif obj.selCount==fi(4,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(6);obj.dataRegW(7);obj.dataRegW(8);data(1);data(2);data(3);data(4);data(5)];
                elseif obj.selCount==fi(5,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(5);obj.dataRegW(6);obj.dataRegW(7);obj.dataRegW(8);data(1);data(2);data(3);data(4)];
                elseif obj.selCount==fi(6,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(4);obj.dataRegW(5);obj.dataRegW(6);obj.dataRegW(7);obj.dataRegW(8);data(1);data(2);data(3)];
                elseif obj.selCount==fi(7,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(3);obj.dataRegW(4);obj.dataRegW(5);obj.dataRegW(6);obj.dataRegW(7);obj.dataRegW(8);data(1);data(2);];
                elseif obj.selCount==fi(8,0,4,0)
                    obj.dataOutW(:)=[obj.dataRegW(2);obj.dataRegW(3);obj.dataRegW(4);obj.dataRegW(5);obj.dataRegW(6);obj.dataRegW(7);obj.dataRegW(8);data(1);];
                else
                    obj.dataOutW(:)=data;
                end
            end

            obj.validOutW(:)=validi||(obj.endReg1&&obj.frameValidW)||(obj.endRegW1&&obj.frameValidW);

            if obj.validOutW(:)
                obj.dataRegW1(:)=obj.dataRegW;
            end

            if validi
                obj.dataRegW(:)=data;
            end


        end

        function[reset,datao,valido,framevalid,endind]=frameController(obj,data,starti,endi,validi)

            reset=starti&&validi;
            datao=obj.dataReg;
            endind=obj.endInd;

            valido=obj.validO;
            framevalid=obj.frameValid;

            if starti&&validi
                obj.frameValid(:)=true;
                obj.endInd(:)=false;
            elseif obj.endReg
                obj.frameValid(:)=false;
                obj.endInd(:)=true;
            end

            obj.endReg(:)=endi&&validi;
            obj.dataReg(:)=data;

            obj.validO(:)=validi&&obj.frameValid;
        end

        function num=getNumInputsImpl(~)
            num=3;
        end

        function num=getNumOutputsImpl(~)
            num=5;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.vectorSize=obj.vectorSize;
                s.resetReg=obj.resetReg;
                s.initValid=obj.initValid;
                s.zeroData=obj.zeroData;
                s.dataMux=obj.dataMux;
                s.dataReg=obj.dataReg;
                s.validReg=obj.validReg;
                s.endReg=obj.endReg;
                s.validO=obj.validO;
                s.frameValid=obj.frameValid;
                s.frameValidB=obj.frameValidB;

                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.dataRegW=obj.dataRegW;
                s.dataOutW=obj.dataOutW;
                s.frameValidW=obj.frameValidW;
                s.endRegW=obj.endRegW;
                s.endRegW1=obj.endRegW1;
                s.selCount=obj.selCount;
                s.count=obj.count;
                s.validOutW=obj.validOutW;
                s.endInd=obj.endInd;
                s.endReg1=obj.endReg1;
                s.extraDelay=obj.extraDelay;
                s.dataRegW1=obj.dataRegW1;
                s.dataOutW1=obj.dataOutW1;
                s.resetW=obj.resetW;
                s.resetW1=obj.resetW1;

                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.frameValidOut=obj.frameValidOut;
                s.resetOut=obj.resetOut;
                s.endIndOut=obj.endIndOut;
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
