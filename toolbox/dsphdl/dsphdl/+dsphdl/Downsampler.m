classdef(StrictDefaults)Downsampler<matlab.System





















































%#codegen



    properties(Nontunable)



        DownsampleFactor=2;




        SampleOffset=0;




        ResetInputPort(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        vectorSize=2;
        vectorcountds=0;
        index;
        intOff;
        residue;
        numOfInp;
        InputDT;
    end


    properties(Access=private)
        inDisp;
        resetreg;
        dOut;
        vOut;
        dataDsReg;
        validDsReg;
        dataOuttmp1;
        validInreg1;
        count;
        countds;
    end

    methods

        function obj=Downsampler(varargin)
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
        function set.DownsampleFactor(obj,value)
            validateattributes(value,{'double'},{'integer','scalar',...
            '>=',1,'<=',2^16},'Downsampler','DownsampleFactor');
            obj.DownsampleFactor=value;
        end
        function set.SampleOffset(obj,value)
            validateattributes(value,{'double'},{'integer',...
            'scalar','>=',0},'Downsampler','SampleOffset');
            if value<obj.DownsampleFactor %#ok
                obj.SampleOffset=value;
            else
                coder.internal.error('dsphdl:Downsampler:InvalidOffset');
            end
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)


            [~,VAR]=getInputDT(obj,varargin{1});
            K=obj.DownsampleFactor;
            obj.vectorSize=length(varargin{1});
            WL=ceil(log2(K+1))+1;
            obj.count=fi(0,0,WL,0,hdlfimath);
            obj.countds=fi(0,0,WL,0,hdlfimath);
            obj.vectorcountds=fi((K/obj.vectorSize)-1,0,WL,0,hdlfimath);
            obj.intOff=fi(floor((obj.SampleOffset/obj.vectorSize)),0,WL,0,hdlfimath);
            obj.residue=fi(mod(obj.SampleOffset,obj.vectorSize),0,WL,0,hdlfimath);
            if obj.vectorSize<=K
                obj.numOfInp=1;
            else
                obj.numOfInp=length(varargin{1})/K;
            end

            if isreal(varargin{1})
                obj.InputDT=cast(0,'like',VAR);
                obj.dOut=cast(zeros(obj.numOfInp,1),'like',obj.InputDT);
                obj.dataDsReg=cast(zeros(obj.numOfInp,1),'like',obj.InputDT);
                obj.dataOuttmp1=cast(zeros(obj.vectorSize,1),'like',obj.InputDT);
            else
                obj.InputDT=complex(cast(0,'like',VAR));
                obj.dOut=complex(cast(zeros(obj.numOfInp,1),'like',obj.InputDT));
                obj.dataDsReg=complex(cast(zeros(obj.numOfInp,1),'like',obj.InputDT));
                obj.dataOuttmp1=complex(cast(zeros(obj.vectorSize,1),'like',obj.InputDT));
            end
            obj.vOut=false;
            obj.validDsReg=false;
            obj.validInreg1=false;
            obj.resetreg=false;
            tmp=(obj.SampleOffset+1):obj.DownsampleFactor:(obj.SampleOffset+length(varargin{1}));
            obj.index=coder.const(tmp);
        end

        function[dataOut,validOut]=outputImpl(obj,varargin)
            if obj.vectorSize>obj.DownsampleFactor
                if obj.resetreg
                    dataOut=cast(zeros(obj.numOfInp,1),'like',obj.dOut);
                    validOut=false;
                elseif(obj.vOut)
                    dataOut=cast(obj.dOut,'like',obj.dOut);
                    validOut=obj.vOut;
                else
                    dataOut=cast(zeros(obj.numOfInp,1),'like',obj.dOut);
                    validOut=false;
                end
            else
                if obj.resetreg
                    dataOut=cast(0,'like',obj.dOut);
                    validOut=false;
                elseif(obj.vOut)
                    dataOut=cast(obj.dOut,'like',obj.dOut);
                    validOut=obj.vOut;
                else
                    dataOut=cast(0,'like',obj.dOut);
                    validOut=false;
                end
            end
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            validIn=varargin{2};

            if obj.ResetInputPort
                reset=varargin{3};
            else
                reset=false;
            end

            if obj.DownsampleFactor==1
                dsOut=cast(dataIn,'like',obj.dOut);
                dsVld=validIn;
            else

                [dsOut,dsVld]=downSampleSection(obj,dataIn,validIn,reset);
            end
            obj.resetreg=reset;
            obj.dOut=dsOut;
            obj.vOut=dsVld;
        end

        function[dataOutds,validOutds]=downSampleSection(obj,dataIn,validIn,reset)
            if isscalar(dataIn)
                dataOutds=obj.dataDsReg(:);
                validOutds=obj.validDsReg;
                if(reset)
                    obj.dataDsReg(:)=0;
                    obj.validDsReg=false;
                else
                    if(validIn)&&(obj.count(:)==obj.SampleOffset)
                        obj.dataDsReg(:)=dataIn;
                        obj.validDsReg=true;
                    else
                        obj.dataDsReg(:)=obj.dataDsReg(:);
                        obj.validDsReg=false;
                    end
                end

                if(reset)
                    obj.count(:)=0;
                else
                    if validIn
                        if(obj.count<(obj.DownsampleFactor-1))
                            obj.count(:)=obj.count+fi(1,0,1,0);
                        else
                            obj.count(:)=0;
                        end
                    end
                end
            elseif obj.DownsampleFactor>=obj.vectorSize
                if reset
                    dataOutds=cast(0,'like',obj.dOut);
                    validOutds=false;
                else
                    dataOutds=cast(dataIn(obj.residue+1),'like',obj.dOut);
                    validOutds=obj.countds(:)==obj.intOff&&validIn;
                end

                if reset||(obj.countds(:)==obj.vectorcountds&&validIn)
                    obj.countds(:)=0;
                elseif validIn
                    obj.countds(:)=obj.countds(:)+1;
                end
            else
                if reset
                    dataOutds=cast(zeros(obj.numOfInp,1),'like',obj.InputDT);
                    validOutds=false;
                elseif validIn
                    dataOutds=cast([obj.dataOuttmp1(obj.index)],'like',obj.InputDT);
                    validOutds=obj.validInreg1;
                else
                    dataOutds=cast(zeros(obj.numOfInp,1),'like',obj.InputDT);
                    validOutds=false;
                end

                if reset
                    obj.dataOuttmp1(:)=cast(zeros(obj.vectorSize,1),'like',obj.InputDT);
                    obj.validInreg1=false;
                elseif validIn
                    obj.dataOuttmp1(:)=cast(dataIn,'like',obj.InputDT);
                    obj.validInreg1=validIn;
                end
            end
        end

        function resetImpl(obj)
            obj.dOut(:)=0;
            obj.dataDsReg(:)=0;
            obj.dataOuttmp1(:)=0;
            obj.vOut=false;
            obj.validDsReg=false;
            obj.validInreg1=false;
            K=obj.DownsampleFactor;
            WL=ceil(log2(K+1))+1;
            obj.count=fi(0,0,WL,0,hdlfimath);
            obj.countds=fi(0,0,WL,0,hdlfimath);
            obj.vectorcountds=fi((K/obj.vectorSize)-1,0,WL,0,hdlfimath);
            obj.intOff=fi(floor((obj.SampleOffset/obj.vectorSize)),0,WL,0,hdlfimath);
            obj.residue=fi(mod(obj.SampleOffset,obj.vectorSize),0,WL,0,hdlfimath);
        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
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
            if obj.DownsampleFactor==1
                latency=1;
            elseif len==1
                latency=2+obj.SampleOffset;
            else
                if obj.DownsampleFactor>=len
                    latency=1+floor(obj.SampleOffset/len);
                else
                    latency=2;
                end
            end
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            text=sprintf('Downsample by removing K-1 data samples between input samples');
            header=matlab.system.display.Header(...
            'Title','Downsampler',...
            'Text',text,...
            'ShowSourceLink',false);
        end

        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'DownsampleFactor','SampleOffset'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            rstPort=matlab.system.display.Section(...
            'Title','Initialize data path registers',...
            'PropertyList',{'ResetInputPort'});

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
        function validatePropertiesImpl(~)
        end

        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{1},{'embedded.fi','int8',...
                'int16','int32','int64','uint8','uint16','uint32','uint64','double','single'},{},'Downsampler','data');
                if(~isvector(varargin{1}))||(~(iscolumn(varargin{1})))
                    coder.internal.error('dsphdl:Downsampler:InvalidVectorSize');
                end
                vecLen=size(varargin{1},1);
                if vecLen>1
                    if vecLen>64||vecLen<1
                        coder.internal.error('dsphdl:Downsampler:InvalidVectorSize');
                    elseif~isequal(mod(obj.DownsampleFactor,vecLen),0)&&~isequal(mod(vecLen,obj.DownsampleFactor),0)
                        coder.internal.error('dsphdl:Downsampler:InvalidVectorSize');
                    end
                end
                [inpWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                errCond=(inpWL>128);
                if(errCond)
                    coder.internal.error('dsphdl:Downsampler:InvalidDataTypeDataIn');
                end
                validateattributes(varargin{2},{'logical'},...
                {'scalar'},'Downsampler','valid');

                if(obj.ResetInputPort)
                    validateattributes(varargin{3},{'logical'},...
                    {'scalar'},'Downsampler','reset');
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
            coder.extrinsic('dsphdl.internal.Downsampler');
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
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
        end

        function varargout=getOutputSizeImpl(obj)
            inSize=propagatedInputSize(obj,1);
            if inSize<=obj.DownsampleFactor
                varargout{1}=[1,1];
            else
                varargout{1}=[ceil(inSize(1)/obj.DownsampleFactor),1];
            end
            varargout{2}=1;
        end

        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
        end

        function num=getNumInputsImpl(obj)
            num=2+obj.ResetInputPort;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='valid';
        end

        function varargout=getInputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';
            if obj.ResetInputPort
                varargout{3}='reset';
            end
        end

        function icon=getIconImpl(obj)
            downstr=sprintf('x[%in]\n',obj.DownsampleFactor);
            if isempty(obj.inDisp)||isempty(obj.vectorSize)
                icon=sprintf('%sDownsampler\nLatency = --',downstr);
            else
                icon=sprintf('%sDownsampler\nLatency = %d',downstr,...
                getLatency(obj,obj.vectorSize));
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inDisp=obj.inDisp;
                s.resetreg=obj.resetreg;
                s.dOut=obj.dOut;
                s.vOut=obj.vOut;
                s.dataDsReg=obj.dataDsReg;
                s.validDsReg=obj.validDsReg;
                s.dataOuttmp1=obj.dataOuttmp1;
                s.validInreg1=obj.validInreg1;
                s.count=obj.count;
                s.countds=obj.countds;
                s.numOfInp=obj.numOfInp;
                s.vectorSize=obj.vectorSize;
                s.vectorcountds=obj.vectorcountds;
                s.index=obj.index;
                s.intOff=obj.intOff;
                s.residue=obj.residue;
                s.InputDT=obj.InputDT;
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