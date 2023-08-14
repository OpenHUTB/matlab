classdef(StrictDefaults)FIRRateConverter<matlab.System
















































































































































%#codegen
%#ok<*EMCLS>






    properties(Nontunable)




        InterpolationFactor=3;




        DecimationFactor=2;










        Numerator=firpm(70,[0,.28,.32,1],[1,1,0,0]);






        ReadyPort(1,1)logical=false;










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
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Same word length as input',...
        'Full precision',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);

    end

    properties(Access=private)
        phaseSeqLUT;
        inputCountLUT;
        inputCount;
        outputCount;
        readyReg;
        xPipe;
        W;
        y;
        yValid;
        yPipe;
        yValidPipe;
        pReadyState;
        pRdyReg;
        pSavedData;
        pSavedDataVld;
        pVldInReg;

    end

    properties(Access=private,Nontunable)
        pNumberOfChannels;
    end





    methods(Static,Access=protected)



        function header=getHeaderImpl

            text=['Upsample, filter and downsample a signal using an efficient polyphase FIR structure.',char(10)...
            ,'Use the ready port to determine if the block is ready to accept a new input sample.'];

            header=matlab.system.display.Header('dsphdl.FIRRateConverter',...
            'Title','FIR Rate Converter',...
            'Text',text,...
            'ShowSourceLink',false);

        end



        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'InterpolationFactor','DecimationFactor','Numerator'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',[algorithmParameters]);

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






            matlab.system.dispFixptHelp('dsphdl.FIRRateConverter',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','OutputDataType'});
        end

    end

    methods



        function obj=FIRRateConverter(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},...
            'InterpolationFactor','DecimationFactor','Numerator');
        end



        function set.InterpolationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'integer','scalar','>',0,'<=',1024},'FIRRateConverter','InterpolationFactor');
            obj.InterpolationFactor=value;
        end



        function set.DecimationFactor(obj,value)
            validateattributes(value,{'numeric'},...
            {'integer','scalar','>',0,'<=',1024},'FIRRateConverter','DecimationFactor');
            obj.DecimationFactor=value;
        end



        function set.Numerator(obj,value)
            validateattributes(value,{'numeric'},...
            {'finite','nonempty','vector','real'},'FIRRateConverter','Numerator');
            obj.Numerator=value;
        end



    end

    methods(Access=protected)



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.phaseSeqLUT=obj.phaseSeqLUT;
                s.inputCountLUT=obj.inputCountLUT;
                s.inputCount=obj.inputCount;
                s.outputCount=obj.outputCount;
                s.readyReg=obj.readyReg;
                s.xPipe=obj.xPipe;
                s.W=obj.W;
                s.y=obj.y;
                s.yValid=obj.yValid;
                s.yPipe=obj.yPipe;
                s.yValidPipe=obj.yValidPipe;
                s.pSavedData=obj.pSavedData;
                s.pSavedDataVld=obj.pSavedDataVld;
                s.pReadyState=obj.pReadyState;
                s.pRdyReg=obj.pRdyReg;
                s.pVldInReg=obj.pVldInReg;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end



        function icon=getIconImpl(obj)
            icon=sprintf('x[%in/%i]\nFIR Rate Converter',obj.DecimationFactor,obj.InterpolationFactor);
        end



        function validateInputsImpl(obj,varargin)
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{1},...
                {'single','double','embedded.fi',...
                'uint8','int8','uint16','int16','uint32','int32','uint64','int64'},...
                {'row'},...
                'FIRRateConverter','data');

                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'FIRRateConverter','valid');



            end
        end



        function num=getNumInputsImpl(obj)

            num=2;

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



        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end



        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            varargout{1}=false;
            varargout{2}=false;
        end



        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end



        function setupImpl(obj,varargin)

            dataIn=varargin{1};

            phaseSeqUnwrapped=obj.DecimationFactor*(0:obj.InterpolationFactor).';
            obj.phaseSeqLUT=mod(phaseSeqUnwrapped(1:end-1),obj.InterpolationFactor);
            obj.inputCountLUT=diff(floor(phaseSeqUnwrapped/obj.InterpolationFactor));
            obj.inputCount=1;
            obj.outputCount=0;
            obj.readyReg=true;


            polyphaseCoeffs=obj.getPolyphaseCoeffs();

            dataInDT=cast(0,'like',dataIn);


            dataTypes=coder.const(...
            obj.determineDataTypes(dataInDT,polyphaseCoeffs));

            xDT=dataTypes.xDT;
            wDT=dataTypes.wDT;
            yDT=dataTypes.yDT;


            numberOfChannels=size(dataIn,2);
            obj.pNumberOfChannels=numberOfChannels;


            delayLineLength=size(polyphaseCoeffs,2);
            obj.xPipe=zeros(delayLineLength,numberOfChannels,'like',xDT);


            obj.W=cast(polyphaseCoeffs,'like',wDT);


            captureDelay=1;
            multPipeDelay=4;
            adderTreeDelay=ceil(log2(delayLineLength));
            yPipeDepth=captureDelay+multPipeDelay+adderTreeDelay+1;

            obj.yPipe=zeros(yPipeDepth,numberOfChannels,'like',yDT);
            obj.yValid=false;
            obj.yValidPipe=false(yPipeDepth,1);


            obj.y=zeros(1,numberOfChannels,'like',yDT);

            if isreal(dataIn)
                obj.pSavedData=cast(zeros(1,numberOfChannels),'like',dataIn);
            else
                obj.pSavedData=cast(complex(zeros(1,numberOfChannels)),'like',dataIn);
            end

            obj.pSavedDataVld=false;

            obj.pReadyState=0;
            obj.pRdyReg=true;
            obj.pVldInReg=false;
        end


        function resetImpl(obj)
            obj.inputCount=1;
            obj.outputCount=0;
            obj.readyReg=true;


            obj.xPipe(:)=0;

            obj.yPipe(:)=0;
            obj.yValid=false;
            obj.yValidPipe(:)=false;


            obj.y(:)=0;

            obj.pRdyReg=true;
            obj.pVldInReg=false;

            obj.pReadyState=0;
            obj.pSavedData(:,:)=0;
            obj.pSavedDataVld=false;
        end



        function polyphaseCoeffs=getPolyphaseCoeffs(obj)


            delayLineLength=ceil(length(obj.Numerator)/obj.InterpolationFactor);
            numeratorPadded=zeros(delayLineLength*obj.InterpolationFactor,1,...
            'like',obj.Numerator);
            numeratorPadded(1:length(obj.Numerator))=obj.Numerator(:);
            polyphaseCoeffs=reshape(numeratorPadded,obj.InterpolationFactor,delayLineLength);
        end



        function dataTypes=determineDataTypes(obj,dataInDT,polyphaseCoeffs)

            coder.extrinsic('dsphdl.FIRRateConverter.getPrecision');



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

                [accNT,yNT]=coder.const(@dsphdl.FIRRateConverter.getPrecision,...
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



        function varargout=outputImpl(obj,varargin)






            varargout{1}=obj.yPipe(end,:);


            varargout{2}=obj.yValidPipe(end);


            if obj.ReadyPort
                if obj.InterpolationFactor>obj.DecimationFactor
                    varargout{3}=obj.pRdyReg;
                else
                    varargout{3}=true;
                end
            end
        end



        function updateImpl(obj,varargin)





            dataIn=varargin{1};
            validIn=varargin{2};



            obj.yPipe(:)=[obj.y;obj.yPipe(1:end-1,:)];
            obj.yValidPipe(:)=[obj.yValid;obj.yValidPipe(1:end-1)];


            if obj.InterpolationFactor>obj.DecimationFactor

                [newInputCount,advanceOutput]=obj.nextInputCount((validIn&&obj.pReadyState==0)||...
                (obj.pSavedDataVld&&obj.pReadyState==4));

                countReached=newInputCount~=0;

                [dIn,dInVld]=updateReady(obj,validIn,dataIn,countReached,false);
                obj.inputCount=newInputCount;

            else
                [newInputCount,advanceOutput]=obj.nextInputCount(validIn);
                obj.inputCount=newInputCount;

                dIn=dataIn;
                dInVld=validIn;

            end




            if dInVld
                obj.xPipe(:)=[dIn;obj.xPipe(1:end-1,:)];
            end

            if advanceOutput

                phase=obj.phaseSeqLUT(obj.outputCount+1);
                obj.y(:)=obj.W(phase+1,:)*obj.xPipe;
                obj.outputCount(:)=mod(obj.outputCount+1,obj.InterpolationFactor);
            end

            obj.yValid(:)=advanceOutput;


        end



        function[inputCount,advanceOutput]=nextInputCount(obj,dataValid)

            inputCount=obj.inputCount;

            readyToAdvance=(inputCount==0)||((inputCount==1)&&dataValid);
            advanceOutput=readyToAdvance;


            if advanceOutput
                inputCount=obj.inputCountLUT(obj.outputCount+1);
            elseif dataValid
                inputCount=obj.inputCount-1;
            end

        end


        function[dIn,dInVld]=updateReady(obj,validIn,dataIn,countReached,resetIn)
            IDLE=0;
            LOAD=1;
            SAVE=2;
            WAIT=3;
            UNLOAD=4;



            vldIn=validIn(1);
            serializationFactor=floor(obj.InterpolationFactor/obj.DecimationFactor);

            if~resetIn
                switch obj.pReadyState
                case IDLE
                    dIn=dataIn;
                    dInVld=validIn;
                    obj.pReadyState=IDLE;
                    obj.pRdyReg=true;
                    obj.pSavedData(:,:)=0;
                    obj.pSavedDataVld=false;
                    if vldIn
                        obj.pReadyState=LOAD;
                        obj.pRdyReg=false;
                    end
                case LOAD
                    dIn=cast(zeros(1,obj.pNumberOfChannels),'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=WAIT;
                    if serializationFactor>2
                        if vldIn
                            obj.pReadyState=SAVE;
                            obj.pSavedData(:,:)=dataIn;
                            obj.pSavedDataVld=validIn;
                        end
                    else
                        if vldIn
                            obj.pReadyState=UNLOAD;
                            obj.pSavedData(:,:)=dataIn;
                            obj.pSavedDataVld=validIn;
                        else
                            obj.pRdyReg=true;
                            obj.pReadyState=IDLE;
                            dIn=dataIn;
                            dInVld=validIn;
                        end
                    end
                case SAVE
                    dIn=cast(zeros(1,obj.pNumberOfChannels),'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=SAVE;
                    if countReached
                        obj.pReadyState=UNLOAD;
                    end
                    obj.pRdyReg=false;

                case WAIT
                    dIn=cast(zeros(1,obj.pNumberOfChannels),'like',dataIn);
                    dInVld=false;
                    if countReached
                        obj.pRdyReg=true;
                        obj.pReadyState=IDLE;

                    end
                case UNLOAD
                    if serializationFactor>2

                        obj.pReadyState=WAIT;

                    else
                        obj.pReadyState=IDLE;
                    end
                    dIn=obj.pSavedData;
                    dInVld=obj.pSavedDataVld;
                    obj.pSavedData(:,:)=dataIn;
                    obj.pSavedDataVld=vldIn;

                    if serializationFactor>=2
                        obj.pRdyReg=false;
                    else
                        obj.pRdyReg=countReached;
                    end

                otherwise
                    dIn=cast(zeros(1,obj.pNumberOfChannels),'like',dataIn);
                    dInVld=false;
                    obj.pReadyState=IDLE;
                    obj.pRdyReg=true;
                    obj.pSavedData(:,:)=0;
                    obj.pSavedDataVld=false;
                end
            else
                dIn=cast(zeros(1,obj.pNumberOfChannels),'like',dataIn);
                dInVld=false;
                obj.pReadyState=IDLE;
                obj.pRdyReg=true;
                obj.pSavedData(:,:)=0;
                obj.pSavedDataVld=false;
            end
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

