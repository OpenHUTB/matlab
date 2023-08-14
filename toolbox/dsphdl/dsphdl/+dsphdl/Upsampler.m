classdef(StrictDefaults)Upsampler<matlab.System


























































%#codegen


    properties(Nontunable)



        UpsampleFactor=3;




        SampleOffset=0;




        NumCycles=1;




        ResetInputPort(1,1)logical=false;





        ReadyPort(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        vectorSize=2;
        outvecsize;
        residuevect;
    end


    properties(Access=private)
        inDisp;
        resetreg;
        readyReg;
        dataUsReg;
        validUsReg;
        count;
        dOut;
        vOut;
        state1;
        count1;
        stagevecsize;
        buffreg;
        buffstate;
        buffcount;
        buffreg1;
        buffstate1;
        pInitialize(1,1)logical=true;
    end

    methods

        function obj=Upsampler(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:})
        end
        function set.UpsampleFactor(obj,value)
            validateattributes(value,{'double'},{'integer','scalar',...
            '>=',1,'<=',2^16},'Upsampler','UpsampleFactor');
            obj.UpsampleFactor=value;
        end
        function set.SampleOffset(obj,value)
            validateattributes(value,{'double'},{'integer',...
            'scalar','>=',0},'Upsampler','SampleOffset');
            if value<obj.UpsampleFactor %#ok
                obj.SampleOffset=value;
            else
                coder.internal.error('dsphdl:Upsampler:InvalidOffset');
            end
        end
        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive'},...
            'Upsampler','NumCycles');
            if~isinf(value)
                validateattributes(value,...
                {'numeric'},...
                {'integer'},...
                'Upsampler','NumCycles');
            end
            obj.NumCycles=value;
        end
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            if nargin==2
                if isempty(varargin{1})
                    len=1;
                else
                    len=(varargin{1});
                end
            else
                len=obj.vectorSize;
                if isempty(len)
                    len=1;
                end
            end
            if obj.UpsampleFactor==1
                latency=1;
            elseif len==1
                latency=3;
            else
                latency=2;
            end
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            text=sprintf('Upsample by adding L-1 zeros between input samples');
            header=matlab.system.display.Header(...
            'Title','Upsampler',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'UpsampleFactor','SampleOffset','NumCycles'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            rstPort=matlab.system.display.Section(...
            'PropertyList',{'ResetInputPort','ReadyPort'});

            ctrlGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',rstPort);

            groups=[mainGroup,ctrlGroup];
        end
        function isVisible=showSimulateUsingImpl




            isVisible=false;
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)


            obj.pInitialize=true;
            L=obj.UpsampleFactor;
            obj.vectorSize=length(varargin{1});
            obj.validUsReg=false;
            obj.count=fi(0,0,ceil(log2(L+1))+1,0,hdlfimath);
            obj.count1=fi(0,0,max(1,1+ceil(log2(L))),0,'OverflowAction','Wrap');
            if obj.UpsampleFactor==1
                obj.outvecsize=obj.vectorSize;
            else
                if((obj.NumCycles<obj.UpsampleFactor)||obj.vectorSize>1)
                    if obj.vectorSize==1
                        obj.outvecsize=(L*obj.vectorSize)/obj.NumCycles;
                    else
                        obj.outvecsize=(L*obj.vectorSize);
                    end
                else
                    obj.outvecsize=L;
                end
                obj.stagevecsize=obj.UpsampleFactor/obj.NumCycles;
            end

            if((obj.NumCycles<obj.UpsampleFactor)||obj.vectorSize>1)
                if(obj.UpsampleFactor==1)
                    val1=zeros(obj.vectorSize,1);
                elseif obj.vectorSize==1
                    val1=zeros((L*obj.vectorSize)/obj.NumCycles,1);
                else
                    val1=zeros((L*obj.vectorSize),1);
                end
            else
                val1=0;
            end

            if isreal(varargin{1})
                obj.dOut=cast(val1,'like',varargin{1});
                obj.dataUsReg=cast(val1,'like',varargin{1});
                obj.buffreg=cast(zeros(obj.SampleOffset+1,1),'like',varargin{1});
                obj.buffreg1=cast(zeros(obj.outvecsize,floor(obj.SampleOffset/obj.outvecsize)+1),'like',varargin{1});
            else
                obj.dOut=complex(cast(val1,'like',varargin{1}));
                obj.dataUsReg=complex(cast(val1,'like',varargin{1}));
                obj.buffreg=complex(cast(zeros(obj.SampleOffset+1,1),'like',varargin{1}));
                obj.buffreg1=complex(cast(zeros(obj.outvecsize,floor(obj.SampleOffset/obj.outvecsize)+1),'like',varargin{1}));
            end
            obj.vOut=false;
            obj.resetreg=false;
            obj.readyReg=true;
            obj.state1=fi(0,0,3,0);
            obj.residuevect=rem(obj.SampleOffset,obj.outvecsize);
            obj.buffstate=false;
            obj.buffcount=fi(0,0,ceil(log2(L))+1,0,hdlfimath);
            obj.buffstate1=false;
        end

        function varargout=outputImpl(obj,varargin)
            if(obj.NumCycles>=obj.UpsampleFactor)&&isscalar(varargin{1})
                if obj.resetreg
                    varargout{1}=cast(0,'like',obj.dOut);
                    varargout{2}=false;
                elseif(obj.vOut)
                    varargout{1}=obj.dOut;
                    varargout{2}=obj.vOut;
                else
                    varargout{1}=cast(0,'like',obj.dOut);
                    varargout{2}=false;
                end
            else
                if obj.resetreg
                    varargout{1}=cast(zeros(obj.outvecsize,1),'like',obj.dOut);
                    varargout{2}=false;
                elseif(obj.vOut)
                    varargout{1}=obj.dOut;
                    varargout{2}=obj.vOut;
                else
                    varargout{1}=cast(zeros(obj.outvecsize,1),'like',obj.dOut);
                    varargout{2}=false;
                end
            end
            varargout{3}=obj.readyReg;
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            validIn=varargin{2};
            if obj.ResetInputPort
                reset=varargin{3};
            else
                reset=false;
            end

            if obj.UpsampleFactor==1
                upOut=dataIn;
                upVld=validIn;
            else

                [dIn,dInVld]=readyLogic(obj,dataIn,validIn,reset);


                if(obj.NumCycles==1)||obj.vectorSize>1
                    [upOut1,upVld1]=upSampleSection(obj,dataIn,validIn,reset);
                else
                    [upOut1,upVld1]=upSampleSection(obj,dIn,dInVld,reset);
                end


                if obj.vectorSize>1
                    upOut=upOut1;
                    upVld=upVld1;
                else
                    if(obj.NumCycles>=obj.UpsampleFactor)
                        [upOut,upVld]=bufferSection(obj,upOut1,upVld1,reset);
                    else
                        [upOut,upVld]=bufferSection1(obj,upOut1,upVld1,reset);
                    end
                end
            end
            obj.dOut=upOut;
            obj.vOut=upVld;
            obj.resetreg=reset;
        end

        function[upOut,upVld]=bufferSection(obj,upOut1,upVld1,reset)
            upOut=obj.buffreg(1);
            upVld=obj.buffstate(1);
            if reset
                obj.buffreg(:)=0;
            elseif upVld1
                obj.buffreg(1:end-1)=obj.buffreg(2:end);
                obj.buffreg(end)=upOut1;
            end
            if reset
                obj.buffstate=false;
            elseif upVld1
                obj.buffstate=upVld1;
            else
                obj.buffstate=false;
            end
        end

        function[upOut,upVld]=bufferSection1(obj,upOut1,upVld1,reset)
            upOut=obj.buffreg1(:,1);
            upVld=obj.buffstate1(1);
            if reset
                obj.buffreg1(:)=0;
            elseif upVld1
                obj.buffreg1(:,1:end-1)=obj.buffreg1(:,2:end);
                obj.buffreg1(:,end)=upOut1;
            end
            if reset
                obj.buffstate1=false;
            elseif upVld1
                obj.buffstate1=upVld1;
            else
                obj.buffstate1=false;
            end
        end

        function[dIn,dInVld]=readyLogic(obj,dataIn,validIn,reset)
            L=obj.UpsampleFactor;
            if L==2
                finalValue=fi(0,0,16,0);
            else
                if obj.NumCycles<obj.UpsampleFactor&&obj.NumCycles~=1
                    finalValue=fi(obj.NumCycles-1,0,16,0);
                else
                    finalValue=fi(L-1,0,16,0);
                end
            end
            if~reset
                switch obj.state1
                case fi(0,0,3,0)
                    dIn=dataIn;
                    dInVld=validIn;
                    obj.state1=fi(0,0,3,0);
                    obj.readyReg=true;
                    if validIn
                        obj.state1=fi(1,0,3,0);
                        obj.readyReg=false;
                    end
                case fi(1,0,3,0)
                    if obj.count1(:)==finalValue
                        obj.readyReg=true;
                        obj.state1=fi(0,0,3,0);
                        dIn=dataIn;
                        dInVld=false;
                    else
                        dIn=cast(0,'like',dataIn);
                        dInVld=false;
                    end
                otherwise
                    dIn=cast(0,'like',dataIn);
                    dInVld=false;
                    obj.state1=fi(0,0,3,0);
                    obj.readyReg=true;
                end

                if validIn||(obj.count1(:)>0)||dInVld
                    if obj.count1(:)==finalValue
                        obj.count1(:)=0;
                    else
                        obj.count1(:)=obj.count1+1;
                    end
                end
            else
                dIn=cast(0,'like',dataIn);
                dInVld=false;
                obj.readyReg=false;
                obj.state1=fi(1,0,3,0);
                obj.count1(:)=finalValue;
            end
            if(obj.NumCycles==1||obj.UpsampleFactor==1||(obj.vectorSize>1))
                obj.readyReg=true;
            end
        end

        function[dataOutus,validOutus]=upSampleSection(obj,dataInus,validInus,reset)
            if obj.NumCycles>=obj.UpsampleFactor&&obj.vectorSize==1
                dataOutus=obj.dataUsReg(:);
                validOutus=obj.validUsReg;

                if reset
                    obj.dataUsReg(:)=0;
                elseif validInus
                    obj.dataUsReg(:)=dataInus;
                elseif obj.validUsReg
                    obj.dataUsReg(:)=0;
                end
                if reset
                    obj.validUsReg=false;
                elseif validInus
                    obj.validUsReg=true;
                elseif obj.count==(obj.UpsampleFactor-1)
                    obj.validUsReg=false;
                end

                if(reset)
                    obj.count(:)=0;
                else
                    if validInus
                        obj.count(:)=0;


                    elseif validOutus
                        if(obj.count<(obj.UpsampleFactor-1))
                            obj.count(:)=obj.count+fi(1,0,1,0);
                        else
                            obj.count(:)=0;
                        end
                    end
                end
            elseif isscalar(dataInus)
                dataOutus=obj.dataUsReg(:);
                if obj.NumCycles==1
                    validOutus=obj.validUsReg;
                else
                    validOutus=obj.buffstate;
                end
                if reset
                    obj.dataUsReg(:)=0;
                elseif validInus
                    obj.dataUsReg(obj.residuevect+1)=dataInus;
                else
                    obj.dataUsReg(:)=0;
                end
                if reset
                    obj.validUsReg=false;
                elseif validInus
                    obj.validUsReg=true;
                else
                    obj.validUsReg=false;
                end
                if validInus&&~reset
                    obj.buffstate=true;
                    obj.buffcount(:)=0;
                elseif obj.buffcount(:)==fi((obj.UpsampleFactor-obj.stagevecsize),0,16,0,hdlfimath)||reset
                    obj.buffstate=false;
                    obj.buffcount(:)=0;
                elseif obj.buffstate
                    obj.buffcount(:)=obj.buffcount+obj.stagevecsize;
                end
            else
                dataOutus=obj.dataUsReg(:);
                validOutus=obj.validUsReg;
                if reset
                    obj.dataUsReg(:)=0;
                elseif validInus
                    obj.dataUsReg(1+obj.SampleOffset:obj.UpsampleFactor:end)=dataInus;
                else
                    obj.dataUsReg(:)=0;
                end
                if reset
                    obj.validUsReg=false;
                elseif validInus
                    obj.validUsReg=true;
                else
                    obj.validUsReg=false;
                end
            end
        end

        function resetImpl(obj)
            L=obj.UpsampleFactor;
            obj.validUsReg=false;
            obj.count=fi(0,0,ceil(log2(L+1))+1,0,hdlfimath);
            obj.count1=fi(0,0,max(1,1+ceil(log2(L))),0,'OverflowAction','Wrap');
            obj.dOut(:)=0;
            obj.dataUsReg(:)=0;
            obj.vOut=false;
            obj.state1=fi(0,0,3,0);
            obj.residuevect=rem(obj.SampleOffset,obj.outvecsize);
            obj.buffcount=fi(0,0,ceil(log2(L))+1,0,hdlfimath);
            obj.buffreg(:)=0;
            obj.buffreg1(:)=0;
            obj.buffstate=false;
            obj.buffstate1=false;
            if obj.pInitialize
                obj.readyReg=true;
                obj.pInitialize=false;
            else
                obj.readyReg=false;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end
    end

    methods(Access=protected)

        function validatePropertiesImpl(obj)
            if(obj.UpsampleFactor>128)
                coder.internal.error('dsphdl:Upsampler:InvalidDataConfig');
            end
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{1},{'embedded.fi','int8','int16',...
                'int32','int64','uint8','uint16','uint32','uint64','double',...
                'single'},{},'Upsampler','data');
                if(~isvector(varargin{1}))||(~(iscolumn(varargin{1})))
                    coder.internal.error('dsphdl:Upsampler:InvalidVectorSize');
                end
                if size(varargin{1},1)==1&&~((obj.NumCycles>=obj.UpsampleFactor)||(obj.NumCycles==1)...
                    ||(mod(obj.UpsampleFactor,obj.NumCycles)==0))
                    coder.internal.error('dsphdl:Upsampler:InvalidNumCyclesValue');
                end
                if(obj.UpsampleFactor*size(varargin{1},1))>128
                    coder.internal.error('dsphdl:Upsampler:InvalidDataConfig');
                end

                [inpWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                errCond=(inpWL>128);
                if(errCond)
                    coder.internal.error('dsphdl:Upsampler:InvalidDataTypeDataIn');
                end
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},'Upsampler','valid');

                if(obj.ResetInputPort)
                    validateattributes(varargin{3},{'logical'},...
                    {'scalar'},'Upsampler','reset');
                end
                obj.inDisp=~isempty(varargin{1});
                obj.vectorSize=length(varargin{1});
            end
        end

        function[DT,VAR]=getInputDT(~,data)

            if~isempty(data)

                if isnumerictype(data)
                    DT=data;
                    VAR=fi(0,DT);
                elseif isa(data,'embedded.fi')||isa(data,'Simulink.NumericType')||isa(data,'embedded.numerictype')
                    DT=numerictype(data);
                    VAR=fi(0,DT);
                elseif isinteger(data)
                    DT=numerictype(class(data));
                    VAR=fi(0,DT);
                elseif ischar(data)
                    DT=numerictype(data);
                    VAR=fi(0,DT);
                else
                    DT=numerictype(class(data));
                    VAR=cast(0,'like',data);
                end

            else
                DT=data;
            end
        end

        function[outputDT]=getOutputDT(~,inputDT)
            coder.extrinsic('dsphdl.internal.Upsampler');
            if isdouble(inputDT)
                outputDT=numerictype('double');
            elseif issingle(inputDT)
                outputDT=numerictype('single');
            else
                wordLength=inputDT.WordLength;
                fractionLength=inputDT.FractionLength;
                signed=inputDT.SignednessBool;
                outputDT=numerictype(signed,wordLength,fractionLength);
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            dt1=propagatedInputDataType(obj,1);
            inputDT=getInputDT(obj,dt1);
            if isempty(dt1)
                varargout{1}=[];
            elseif~isempty(inputDT)
                [outputDT]=getOutputDT(obj,inputDT);
                varargout{1}=outputDT;
            else
                varargout{1}=[];
            end
            varargout{2}='logical';
            varargout{3}='logical';
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            if obj.ReadyPort
                varargout{3}=true;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            size=propagatedInputSize(obj,1);
            if(obj.NumCycles>=obj.UpsampleFactor)&&size(1)==1
                varargout{1}=[1,1];
            elseif size(1)==1
                varargout{1}=[floor((obj.UpsampleFactor*size(1))/obj.NumCycles),1];
            else
                varargout{1}=[(obj.UpsampleFactor*size(1)),1];
            end
            varargout{2}=1;
            if obj.ReadyPort
                varargout{3}=1;
            end
        end

        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            if obj.ReadyPort
                varargout{3}=false;
            end
        end

        function num=getNumInputsImpl(obj)
            num=2+obj.ResetInputPort;
        end

        function num=getNumOutputsImpl(obj)
            num=2+obj.ReadyPort;
        end

        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';
            if obj.ReadyPort
                varargout{3}='ready';
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';
            if obj.ResetInputPort
                varargout{3}='reset';
            end
        end

        function icon=getIconImpl(obj)

            interpstr=sprintf('x[n/%i]\n',obj.UpsampleFactor);
            if isempty(obj.inDisp)||isempty(obj.vectorSize)
                icon=sprintf('%sUpsampler \nLatency = --',interpstr);
            else
                icon=sprintf('%sUpsampler \nLatency = %d',interpstr,...
                getLatency(obj,obj.vectorSize));
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.readyReg=obj.readyReg;
                s.inDisp=obj.inDisp;
                s.resetreg=obj.resetreg;
                s.dataUsReg=obj.dataUsReg;
                s.validUsReg=obj.validUsReg;
                s.count=obj.count;
                s.dOut=obj.dOut;
                s.vOut=obj.vOut;
                s.vectorSize=obj.vectorSize;
                s.outvecsize=obj.outvecsize;
                s.residuevect=obj.residuevect;
                s.state1=obj.state1;
                s.count1=obj.count1;
                s.stagevecsize=obj.stagevecsize;
                s.buffreg=obj.buffreg;
                s.buffreg1=obj.buffreg1;
                s.buffstate=obj.buffstate;
                s.buffstate1=obj.buffstate1;
                s.buffcount=obj.buffcount;
                s.pInitialize=obj.pInitialize;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for i=1:numel(fn)
                obj.(fn{i})=s.(fn{i});
            end
        end

    end
end