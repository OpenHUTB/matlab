classdef(StrictDefaults)HDLFIRRateConverter<matlab.System






































































































































%#codegen
%#ok<*EMCLS>






    properties(Nontunable)




        InterpolationFactor=3;




        DecimationFactor=2;










        Numerator=firpm(70,[0,.28,.32,1],[1,1,0,0]);




        ReadyPort(1,1)logical=false;

    end


    properties(Nontunable)








        RoundingMethod='Floor';







        OverflowAction='Wrap';





        CoefficientsDataType=numerictype(1,16,16);







        OutputDataType='Same word length as input';

    end

    properties(Constant,Hidden)



        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...
        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet({...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'ValuePropertyName','Numerator',...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Same word length as input',...
        'Full precision',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',true,...
        'HasDesignMaximum',true);

    end

    properties(Access=private)


        phaseSeqLUT;
        inputCountLUT;
        W;


        regs;

    end





    methods(Static,Access=protected)



        function header=getHeaderImpl

            text=['Upsample, filter and downsample a signal using an efficient polyphase FIR structure.',newline...
            ,'Use the ready port to determine if the block is ready to accept a new input sample.',newline...
            ,'Use the request port to request a new output sample.'];

            header=matlab.system.display.Header('dsphdl.private.HDLFIRRateConverter',...
            'Title','FIR Rate Conversion HDL Optimized',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'InterpolationFactor','DecimationFactor','Numerator'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            dtGroup=matlab.system.display.internal.DataTypesGroup(mfilename('class'));

            portsGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'PropertyList',{'ReadyPort'});

            groups=[mainGroup,dtGroup,portsGroup];

        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end



    end

    methods(Static)

        function helpFixedPoint






            matlab.system.dispFixptHelp('dsphdl.private.HDLFIRRateConverter',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end

    methods



        function obj=HDLFIRRateConverter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Signal_Blocks'))
                    error(message('dsp:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Signal_Blocks');
            end

            setProperties(obj,nargin,varargin{:},...
            'InterpolationFactor','DecimationFactor','Numerator');
        end



        function set.InterpolationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'integer','scalar','>',0,'<=',1024},'','InterpolationFactor');
            obj.InterpolationFactor=value;
        end



        function set.DecimationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'integer','scalar','>',0,'<=',1024},'','DecimationFactor');
            obj.DecimationFactor=value;
        end



        function set.Numerator(obj,value)
            validateattributes(value,{'numeric'},...
            {'finite','nonempty','vector','real'},'','Numerator');
            obj.Numerator=value;
        end



    end

    methods(Access=protected)



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.phaseSeqLUT=obj.phaseSeqLUT;
                s.inputCountLUT=obj.inputCountLUT;
                s.W=obj.W;
                s.regs=obj.regs;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end



        function icon=getIconImpl(obj)
            icon=sprintf('x[%in/%i]\nHDL Optimized',obj.DecimationFactor,obj.InterpolationFactor);
        end



        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{1},...
                {'single','double','embedded.fi',...
                'uint8','int8','uint16','int16','uint32','int32','uint64','int64'},...
                {'row'},...
                'HDLFIRRateConverter','dataIn');

                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'HDLFIRRateConverter','validIn');

                validateattributes(varargin{3},{'logical'},{'scalar'},...
                'HDLFIRRateConverter','request');

            end
        end



        function num=getNumInputsImpl(obj)
            num=3;
        end



        function num=getNumOutputsImpl(obj)
            if obj.ReadyPort
                num=3;
            else
                num=2;
            end
        end



        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,obj.getNumInputs());
            varargout{1}='data';
            varargout{2}='valid';
            varargout{3}='request';
        end



        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,obj.getNumOutputs());
            varargout{1}='data';
            varargout{2}='valid';
            if obj.ReadyPort
                varargout{3}='ready';
            end
        end



        function varargout=getOutputDataTypeImpl(obj)

            dt1=propagatedInputDataType(obj,1);
            if(~isempty(dt1))
                if ischar(dt1)
                    inputDT=eval([dt1,'(0)']);
                else
                    inputDT=fi(0,dt1);
                end

                polyphaseCoeffs=obj.getPolyphaseCoeffs();
                dataTypes=determineDataTypes(obj,inputDT,polyphaseCoeffs);

                if isfi(dataTypes.yDT)
                    varargout{1}=dataTypes.yDT.numerictype();
                else
                    varargout{1}=class(dataTypes.yDT);
                end
            else
                varargout{1}=[];
            end
            varargout{2}='logical';
            if obj.ReadyPort
                varargout{3}='logical';
            end

        end



        function varargout=isOutputComplexImpl(obj,varargin)
            varargout{1}=(~isreal(obj.Numerator))|propagatedInputComplexity(obj,1);

            varargout{2}=false;

            if obj.ReadyPort
                varargout{3}=false;
            end
        end



        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=1;
            if obj.ReadyPort
                varargout{3}=1;
            end
        end



        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            if obj.ReadyPort
                varargout{3}=true;
            end
        end



        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end



        function varargout=isInputDirectFeedthroughImpl(obj,varargin)

            varargout{1}=false;


            if obj.ReadyPort
                varargout{2}=true;
            else
                varargout{2}=false;
            end


            varargout{3}=true;

        end



        function polyphaseCoeffs=getPolyphaseCoeffs(obj)


            delayLineLength=ceil(length(obj.Numerator)/obj.InterpolationFactor);
            numeratorPadded=zeros(delayLineLength*obj.InterpolationFactor,1,...
            'like',obj.Numerator);
            numeratorPadded(1:length(obj.Numerator))=obj.Numerator(:);
            polyphaseCoeffs=reshape(numeratorPadded,obj.InterpolationFactor,delayLineLength);
        end



        function dataTypes=determineDataTypes(obj,dataInDT,polyphaseCoeffs)

            coder.extrinsic('dsphdl.private.HDLFIRRateConverter.getPrecision');



            wDTInit=cast(0,'like',polyphaseCoeffs);
            if isreal(dataInDT)&&isreal(wDTInit)

                accDTInit=0;
                yDTInit=0;
            else

                accDTInit=complex(0,0);
                yDTInit=complex(0,0);
            end

            if isa(dataInDT,'single')||isa(dataInDT,'double')


                xDT=dataInDT;
                wDT=cast(wDTInit,'like',dataInDT);
                yDT=cast(yDTInit,'like',dataInDT);
                accDT=cast(accDTInit,'like',dataInDT);

            elseif isinteger(dataInDT)||isfixed(dataInDT)




                quantizedCoeffs=fi(polyphaseCoeffs,obj.CoefficientsDataType);

                [inputWL,inputFL,inputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);
                dataInNT=numerictype(inputS,inputWL,inputFL);

                [accNT,yNT]=coder.const(@dsphdl.private.HDLFIRRateConverter.getPrecision,...
                quantizedCoeffs,dataInNT,obj.OutputDataType);

                xDT=fi(dataInDT,inputS,inputWL,inputFL);
                wDT=fi(wDTInit,obj.CoefficientsDataType);
                accDT=fi(accDTInit,accNT);


                yFimath=fimath(...
                'OverflowAction',obj.OverflowAction,...
                'RoundingMethod',obj.RoundingMethod);

                yDT=fi(yDTInit,yNT,yFimath);

            end

            dataTypes=struct(...
            'xDT',xDT,...
            'wDT',wDT,...
            'accDT',accDT,...
            'yDT',yDT);

        end



        function setupImpl(obj,varargin)

            dataIn=varargin{1};

            phaseSeqUnwrapped=obj.DecimationFactor*(0:obj.InterpolationFactor).';
            obj.phaseSeqLUT=mod(phaseSeqUnwrapped(1:end-1),obj.InterpolationFactor);
            obj.inputCountLUT=diff(floor(phaseSeqUnwrapped/obj.InterpolationFactor));


            polyphaseCoeffs=obj.getPolyphaseCoeffs();

            dataInDT=cast(0,'like',dataIn);


            dataTypes=coder.const(...
            obj.determineDataTypes(dataInDT,polyphaseCoeffs));

            xDT=dataTypes.xDT;
            wDT=dataTypes.wDT;
            yDT=dataTypes.yDT;


            obj.W=cast(polyphaseCoeffs,'like',wDT);


            numberOfChannels=size(dataIn,2);


            delayLineLength=size(polyphaseCoeffs,2);

            initializeRegisters(obj,xDT,yDT,delayLineLength,numberOfChannels);

        end



        function resetImpl(obj)

            inputDT=obj.regs.delayLine(1,1);
            outputDT=obj.regs.yPipe(1,1);
            delayLineLength=size(obj.regs.delayLine,1);
            numberOfChannels=size(obj.regs.delayLine,2);

            initializeRegisters(obj,inputDT,outputDT,delayLineLength,numberOfChannels);

        end



        function initializeRegisters(obj,inputDT,outputDT,delayLineLength,numberOfChannels)



            adderTreeDelay=ceil(log2(delayLineLength));
            yPipeDepth=adderTreeDelay+5;


            obj.regs=struct(...
            'delayLine',zeros(delayLineLength,numberOfChannels,'like',inputDT),...
            'request',false,...
            'inputCount',1,...
            'outputCount',0,...
            'phase',0,...
            'phaseValid',false,...
            'ready',true,...
            'sumOfProds',zeros(1,numberOfChannels,'like',outputDT),...
            'sumOfProdsValid',false,...
            'yPipe',zeros(yPipeDepth,numberOfChannels,'like',outputDT),...
            'yValidPipe',false(yPipeDepth,1));

        end



        function varargout=outputImpl(obj,varargin)


            validIn=varargin{2};
            request=varargin{3};


            varargout{1}=obj.regs.yPipe(end,:);


            varargout{2}=obj.regs.yValidPipe(end)&&obj.regs.request;


            if obj.ReadyPort
                dataValid=validIn&&obj.regs.ready;
                [~,~,ready,~]=obj.updateInputCount(dataValid,request);
                varargout{3}=ready;
            end

        end



        function updateImpl(obj,varargin)


            dataIn=varargin{1};
            validIn=varargin{2};
            request=varargin{3};


            dataValid=validIn&&obj.regs.ready;





            next=obj.regs;


            if dataValid
                next.delayLine=[dataIn;obj.regs.delayLine(1:end-1,:)];
            end


            next.request=request;


            [advance,readyToAdvance,next.ready,next.inputCount]=obj.updateInputCount(dataValid,request);

            if advance
                next.outputCount=mod(obj.regs.outputCount+1,obj.InterpolationFactor);
                next.phase=obj.phaseSeqLUT(obj.regs.outputCount+1);
            end

            if request
                next.phaseValid=readyToAdvance;
            end

            if obj.regs.request


                if obj.regs.phaseValid
                    next.sumOfProds(:)=obj.W(obj.regs.phase+1,:)*obj.regs.delayLine;
                end
                next.sumOfProdsValid(:)=obj.regs.phaseValid;


                next.yPipe(:)=[obj.regs.sumOfProds;obj.regs.yPipe(1:end-1,:)];
                next.yValidPipe(:)=[obj.regs.sumOfProdsValid;obj.regs.yValidPipe(1:end-1)];

            end





            obj.regs=next;

        end



        function[advance,readyToAdvance,ready,nextInputCount]=updateInputCount(obj,dataValid,request)

            inputCount=obj.regs.inputCount;

            readyToAdvance=(inputCount==0)||((inputCount==1)&&dataValid);
            advance=request&&readyToAdvance;


            if advance
                nextInputCount=obj.inputCountLUT(obj.regs.outputCount+1);
            elseif dataValid
                nextInputCount=inputCount-1;
            else
                nextInputCount=inputCount;
            end

            ready=nextInputCount~=0;

        end



    end

    methods(Static,Hidden)



        function[accNT,yNT]=getPrecision(W,xNT,outputDataType)













            [accLimits,yLimits]=dsp.internal.FIRFilterPrecision(W,xNT);

            accNT=accLimits.numerictype;

            if isnumerictype(outputDataType)

                yNT=outputDataType;
            else

                switch outputDataType
                case 'Full precision'
                    yNT=accNT;
                case 'Same word length as input'
                    yNT=yLimits.numerictype;
                end
            end

        end

    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end

