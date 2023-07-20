classdef preambleDetector<wt.internal.AppBase




    properties(Access=protected)
        ApplicationID='preambleDetector'
        PackageBase='wt.internal.preambledetector'
    end

    properties(Nontunable)
        FilterCoefficients=zeros(16,1);
        ThresholdMethod{mustBeText,mustBeMember(ThresholdMethod,["adaptive","fixed"])}="adaptive";
        AdaptiveThresholdWindowLength(1,1){mustBeNumeric,mustBeInteger,mustBeInRange(AdaptiveThresholdWindowLength,1,2047)}=16;
        CaptureDataType(1,1){mustBeMember(CaptureDataType,["int16","double","single"])}="int16";
        TransmitDataType(1,1){mustBeMember(TransmitDataType,["int16","double","single"])}="int16";
        PacketSize(1,1){mustBeNumeric,mustBeInteger,mustBeInRange(PacketSize,2,65535)}=63;
    end

    properties
        FixedThreshold(1,1){mustBeNumeric,mustBeInRange(FixedThreshold,0,4095)}=0;
        AdaptiveThresholdOffset(1,1){mustBeNumeric,mustBeInRange(AdaptiveThresholdOffset,0,2)}=0;
        AdaptiveThresholdGain(1,1){mustBeNumeric,mustBeInRange(AdaptiveThresholdGain,0,64)}=0;
        TriggerOffset(1,1){mustBeNumeric,mustBeInteger,mustBeInRange(TriggerOffset,-3096,4096)}=0;
    end

    properties(Hidden)


        pRecordLength=1000;
        pCalibrationMux=0;
        pAvailableReceiveAntennas;
        pAvailableTransmitAntennas;
        pTransmitSamplesAllocated;
    end

    properties(Access=protected)

        pFilterReuseFactor;
        pFilterCoefficientsHW;
        pFilterSelect;
    end

    properties
        DroppedSamplesAction(1,1){mustBeMember(DroppedSamplesAction,["error","warning","none"])}="error";
    end

    properties(Access=protected,Constant)
        CLEAR_FILTER=0;
        FILTER_ARCH=1;
        TIMEOUT_SEC=3;
        WAIT_NUM=0;
    end

    methods

        function set.FilterCoefficients(obj,preambleVal)

            if(~isa(preambleVal,"int16"))
                validateattributes(preambleVal,{'double','single','embedded.fi'},{'column','>=',-1,'<',1});
                if(isa(preambleVal,'embedded.fi'))
                    if((preambleVal.WordLength~=16)||(preambleVal.FractionLength~=15)||~strcmp(preambleVal.Signedness,'Signed'))
                        error(message('wt:preambledetector:NotCorrectFiType'));
                    end
                end
                obj.FilterCoefficients=flipud(conj(preambleVal));
            else
                obj.FilterCoefficients=flipud(conj(preambleVal));
            end
        end
    end

    methods
        function obj=preambleDetector(radioID,varargin)
            obj=obj@wt.internal.AppBase(radioID,varargin{:});
            obj.pAvailableReceiveAntennas=obj.Radio.AvailableReceiveAntennas;
            obj.pAvailableTransmitAntennas=obj.Radio.AvailableTransmitAntennas;


            obj.ReceiveAntennas=obj.pAvailableReceiveAntennas(1);
            obj.TransmitAntennas=obj.pAvailableTransmitAntennas(1);
        end

        function[data,status,timestamp,droppedSamples]=detect(obj,recordLength,timeout)

            obj.pCalibrationMux=0;

            [obj.pRecordLength,~,CroppedFlag]=getCaptureLengthSamples(obj,recordLength);
            step(obj);

            timestamp=datetime;

            [data,status,~,droppedSamples]=obj.readDataFromDDR(obj.pRecordLength,CroppedFlag,timeout);
        end

        function[filterOutput,scaledSignalPower,detectionInd,droppedSamples]=readCalibrationSignals(obj,recordLength)

            obj.pCalibrationMux=1;

            [obj.pRecordLength,~,CroppedFlag]=getCaptureLengthSamples(obj,recordLength);

            step(obj);

            [data,~,~,droppedSamples]=obj.readDataFromDDR(obj.pRecordLength,CroppedFlag,1);
            if~strcmp(obj.CaptureDataType,"int16")
                data=int16(data*32768);
            end


            exponent=double(wt.internal.rfnoc.FPTools.bitGet(real(data),15,11));
            mantissa=double(wt.internal.rfnoc.FPTools.bitGet(real(data),10,1));
            signalpower=2.^(exponent-15).*(1+mantissa/1024);
            signalpower((exponent==0)&(mantissa==0))=0;

            exponent=double(wt.internal.rfnoc.FPTools.bitGet(imag(data),15,11));
            mantissa=double(wt.internal.rfnoc.FPTools.bitGet(imag(data),10,1));
            filterpower=2.^(exponent-15).*(1+mantissa/1024);
            filterpower((exponent==0)&(mantissa==0))=0;

            detectionInd=find(wt.internal.rfnoc.FPTools.bitGet(real(data),16,16)==1);
            filterOutput=filterpower;
            scaledSignalPower=signalpower;
        end

        function[data,status,overflow,droppedSamples]=readDataFromDDR(obj,recordLength,CroppedFlag,timeout)

            if isduration(timeout)

                timeout_seconds=seconds(timeout);
            else
                if isnumeric(timeout)
                    if timeout<0
                        error(message('wt:preambledetector:TimeoutInvalid'));
                    else
                        timeout_seconds=timeout;
                    end
                else
                    error(message('wt:preambledetector:TimeoutInvalid'));
                end
            end
            allocateHardwareMemory(obj,1,recordLength,"wt:preambledetector:NotEnoughMemoryRx");

            try
                [data,numSamps,overflow]=readPDOutputData(obj.Driver,recordLength,timeout_seconds);
            catch ME
                freeHardwareMemory(obj,1,recordLength);
                rethrow(ME);
            end
            freeHardwareMemory(obj,1,recordLength);
            if isequal(numSamps,0)&&~overflow
                droppedSamples=false;
                status=false;
            elseif overflow||~(numSamps==recordLength)
                droppedSamples=true;
                switch obj.DroppedSamplesAction
                case "error"
                    error(message('wt:preambledetector:DroppedSamples',string(obj.AvailableHardwareMemory/4)));
                case "warning"
                    warning(message('wt:preambledetector:DroppedSamples',string(obj.AvailableHardwareMemory/4)));
                otherwise
                end
                status=true;
            else
                droppedSamples=false;
                if(CroppedFlag)
                    data=data(1:(numSamps-1));
                end
                status=true;
            end
        end

        function transmitRepeat(obj,waveform)





            step(obj);


            [waveform,farrowFactor]=obj.Driver.prepareTxWaveform(waveform,obj.SampleRate,obj.TransmitAntennas,wt.internal.TransmitModes.continuous);


            [waveformLength,numWaveforms]=size(waveform);




            if rem(waveformLength,2)


                error(message('wt:preambledetector:TransmitEvenNoFarrow'))
            end

            if farrowFactor~=1
                allocateHardwareMemory(obj,numWaveforms,waveformLength,"wt:preambledetector:NotEnoughMemoryTxFarrowRequired");
            else
                allocateHardwareMemory(obj,numWaveforms,waveformLength,"wt:preambledetector:NotEnoughMemoryTxNoFarrow");
            end

            obj.pTransmitSamplesAllocated=waveformLength;

            try
                transmitRepeat(obj.Driver,waveform);
            catch ME
                freeHardwareMemory(obj,numWaveforms,obj.pTransmitSamplesAllocated);
                rethrow(ME)
            end

        end

        function stopTransmission(obj)

            stopTransmitRepeat(obj.Driver);
            freeHardwareMemory(obj,1,obj.pTransmitSamplesAllocated);
        end
    end

    methods(Access=protected)
        function setupImpl(obj,varargin)

            setupImpl@wt.internal.AppBase(obj,varargin)


            verifyFilterDesign(obj);

            initDetector(obj)
        end

        function processTunedPropertiesImpl(obj)

            processTunedPropertiesImpl@wt.internal.AppBase(obj);

            if isChangedProperty(obj,'FixedThreshold')

                FixedThresholdInt=typecast(single(obj.FixedThreshold),'uint32');
                writeRegister(obj.Driver,'customThreshold',FixedThresholdInt);
            end
            if isChangedProperty(obj,'AdaptiveThresholdOffset')
                writeRegister(obj.Driver,'minThreshold',uint32(wt.internal.rfnoc.FPTools.FPConvert(obj.AdaptiveThresholdOffset,1,32,30)));
            end
            if isChangedProperty(obj,'AdaptiveThresholdGain')
                HWScaler=sqrt(double(obj.AdaptiveThresholdGain));
                writeRegister(obj.Driver,'thresholdScaler',uint32(wt.internal.rfnoc.FPTools.FPConvert(HWScaler,1,16,12)));
            end




            if isChangedProperty(obj,'pRecordLength')
                writeRegister(obj.Driver,'recordNum',obj.pRecordLength-1);
            end
            if isChangedProperty(obj,'pCalibrationMux')
                writeRegister(obj.Driver,'dftControl',obj.pCalibrationMux);
            end
        end
    end

    methods(Access=protected)

        function[CaptureLengthSamples,CaptureLengthTime,CropFlag]=getCaptureLengthSamples(obj,CaptureLength)

            if isduration(CaptureLength)

                CaptureLengthTime=CaptureLength;

                time_seconds=seconds(CaptureLength);

                numSamples=ceil(time_seconds*obj.SampleRate);
            else
                if isnumeric(CaptureLength)



                    numSamples=CaptureLength;
                    if(numSamples>0)

                        CaptureLengthSamples=CaptureLength;

                        time_seconds=CaptureLengthSamples/obj.SampleRate;

                        CaptureLengthTime=seconds(time_seconds);
                    else
                        error(message('wt:preambledetector:CaptureLengthInvalid'))
                    end
                else
                    error(message('wt:preambledetector:CaptureLengthInvalid'))
                end
            end
            if numSamples>0
                if rem(numSamples,2)
                    CaptureLengthSamples=numSamples+1;
                    CropFlag=1;
                else
                    CaptureLengthSamples=numSamples;
                    CropFlag=0;
                end
            else
                error(message('wt:preambledetector:CaptureLengthInvalid'))
            end
        end

        function verifyFilterDesign(obj)








            MACs=16;
            filterLength=length(obj.FilterCoefficients);
            possibleReuseFactor=ceil(ceil(filterLength/MACs)./[1,2,3]);

            maxReuseFactor=floor(obj.Radio.MasterClockRate/obj.Driver.App.SampleRate);
            if(min(possibleReuseFactor)>maxReuseFactor)
                error(message('wt:preambledetector:FilterNotAchievable',maxReuseFactor*MACs*3));
            end
            obj.pFilterReuseFactor=min(possibleReuseFactor);

            FiltersetNum=find(possibleReuseFactor==obj.pFilterReuseFactor,1);
            paddingNum=obj.pFilterReuseFactor*MACs*FiltersetNum-filterLength;
            paddedMatchedFilter=[obj.FilterCoefficients;cast(zeros(paddingNum,1),'like',obj.FilterCoefficients(1))];
            temp=reshape(paddedMatchedFilter,[],MACs*FiltersetNum);
            temp(:,(16*FiltersetNum+1):48)=0;
            temp(obj.pFilterReuseFactor+1:32,:)=0;
            temp=temp(:);
            temp((length(temp)+1):1536)=0;

            if(isa(obj.FilterCoefficients,'embedded.fi'))
                quantFilterCoefficients=temp.storedInteger;
            elseif(isa(obj.FilterCoefficients,'int16'))
                quantFilterCoefficients=temp;
            else
                quantFilterCoefficients=int16(wt.internal.rfnoc.FPTools.FPConvert(temp,1,16,15));
            end
            if isrow(quantFilterCoefficients)
                quantFilterCoefficients=quantFilterCoefficients.';
            end

            obj.pFilterCoefficientsHW={complex(quantFilterCoefficients(1:512));complex(quantFilterCoefficients(513:1024));...
            complex(quantFilterCoefficients(1025:1536))};
            obj.pFilterSelect=FiltersetNum-1;

        end

        function initDetector(obj)

            writeRegister(obj.Driver,'programEnable',uint32(0));
            writeRegister(obj.Driver,'dataInEnable',0);
            writeRegister(obj.Driver,'packetSize',obj.PacketSize);

            resetRecorder(obj);

            setTriggerOffset(obj,double(obj.TriggerOffset));
            writeRegister(obj.Driver,'dftControl',obj.pCalibrationMux);
            writeRegister(obj.Driver,'clearFilter',obj.CLEAR_FILTER);
            writeRegister(obj.Driver,'serialParallel',obj.FILTER_ARCH);
            writeRegister(obj.Driver,'reuseFactor',obj.pFilterReuseFactor-1);
            writeRegister(obj.Driver,'triggerSelect',obj.pFilterSelect);
            switch obj.ThresholdMethod
            case 'adaptive'
                writeRegister(obj.Driver,'thresholdSelect',0);
            case 'fixed'
                writeRegister(obj.Driver,'thresholdSelect',1);
            otherwise


                writeRegister(obj.Driver,'thresholdSelect',0);
            end

            FixedThresholdInt=typecast(single(obj.FixedThreshold),'uint32');
            HWScaler=sqrt(double(obj.AdaptiveThresholdGain));
            writeRegister(obj.Driver,'customThreshold',FixedThresholdInt);
            writeRegister(obj.Driver,'recordNum',uint32(obj.pRecordLength-1));
            writeRegister(obj.Driver,'windowLength',uint32(obj.AdaptiveThresholdWindowLength));
            writeRegister(obj.Driver,'thresholdScaler',uint32(wt.internal.rfnoc.FPTools.FPConvert(HWScaler,1,16,12)));
            writeRegister(obj.Driver,'minThreshold',uint32(wt.internal.rfnoc.FPTools.FPConvert(obj.AdaptiveThresholdOffset,1,32,30)));

            programFilter(obj);
        end

        function programFilter(obj)
            resetFilterCoeff(obj);

            writeRegister(obj.Driver,'programEnable',1);
            writeRegister(obj.Driver,'dataInEnable',1);

            for i=1:3
                writeRegister(obj.Driver,'programChannel',i);
                writeCoefficients(obj.Driver,obj.pFilterCoefficientsHW{i});
            end

            writeRegister(obj.Driver,'programEnable',0);
            writeRegister(obj.Driver,'dataInEnable',0);
        end

        function resetRecorder(obj)
            writeRegister(obj.Driver,'recorderReset',0);
            writeRegister(obj.Driver,'recorderReset',1);
            writeRegister(obj.Driver,'recorderReset',0);
        end

        function resetFilterCoeff(obj)
            writeRegister(obj.Driver,'resetFilter',0);
            writeRegister(obj.Driver,'resetFilter',1);
            writeRegister(obj.Driver,'resetFilter',0);
        end

        function setTriggerOffset(obj,delay)
            delay=delay-1;


            if(delay>0)
                delayNum=1;
                waitNum=delay;
            elseif(delay<0)
                delayNum=-delay+1;
                waitNum=1;
            else
                delayNum=2;
                waitNum=2;
            end
            writeRegister(obj.Driver,'waitNum',waitNum);
            writeRegister(obj.Driver,'delayNum',delayNum);
        end
    end

    methods(Access=public,Hidden=true)

        function regs=readbackRegisters(obj)
            regs=readbackRegisters(obj.Driver);
        end

        function state=getStatus(obj)








            firStateRegisterValue=readRegister(obj.Driver,'firState');
            fifoStateRegisterValue=readRegister(obj.Driver,'fifoState');
            state.filter_mode=readRegister(obj.Driver,'serialParallel');
            state.fifoNum=wt.internal.rfnoc.FPTools.bitGet(fifoStateRegisterValue,11,1);
            state.fifoFull=wt.internal.rfnoc.FPTools.bitGet(fifoStateRegisterValue,12,12);
            state.fifoEmpty=wt.internal.rfnoc.FPTools.bitGet(fifoStateRegisterValue,13,13);
            state.fifoState=wt.internal.rfnoc.FPTools.bitGet(fifoStateRegisterValue,16,14);
            state.fir1=wt.internal.rfnoc.FPTools.bitGet(firStateRegisterValue,5,1);
            state.fir2=wt.internal.rfnoc.FPTools.bitGet(firStateRegisterValue,10,6);
            state.fir3=wt.internal.rfnoc.FPTools.bitGet(firStateRegisterValue,15,11);
            state.recordNum=readRegister(obj.Driver,'countNum');
            state.recordState=readRegister(obj.Driver,'recorderState');
        end
    end
end


