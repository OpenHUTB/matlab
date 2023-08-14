classdef AnalogInSingle<ioplayback.base.BlockSampleTime&...
    ioplayback.system.mixin.Event




%#codegen
%#ok<*EMCA>

    properties(Hidden)
        Hw=[];
    end


    properties(Abstract,Nontunable)

Pin
    end

    properties(Nontunable)

        ReadResultsOnly(1,1)logical=false;


        SampleAndHoldTime=1e-6;

        ConversionTime=1e-6;

        ConversionTriggerSource='Software';

    end

    properties(Abstract,Nontunable)

        ExternalTriggerType;
    end

    properties(Nontunable,Hidden)

        OutputDataType='uint16';
    end

    properties(Nontunable)

        EnableConversionCompleteNotify(1,1)logical=false

        EnableOuputStatus(1,1)logical=false;
    end


    properties(Constant,Hidden)
        ConversionTriggerSourceSet=matlab.system.StringSet({'Software','External trigger'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'int8',...
        'uint8',...
        'int16',...
        'uint16',...
        'int32',...
        'uint32',...
        'single',...
        'double'});
    end

    properties(Hidden,Nontunable)
        DataSize=[1,1]
    end

    properties(Abstract,Nontunable)

        EventID;
    end

    properties(Access=private)
        EventTick=0;
    end

    properties(Access=protected)
        MW_ANALOGIN_HANDLE;
    end


    methods
        function set.ConversionTime(obj,value)
            validateattributes(value,{'numeric','embedded.fi'},...
            {'scalar','nonnegative','nonnan','finite'},...
            '','Conversion time');

            obj.ConversionTime=value;
        end

        function set.SampleAndHoldTime(obj,value)
            validateattributes(value,{'numeric','embedded.fi'},...
            {'scalar','nonnegative','nonnan','finite'},...
            '','Sample and Hold time');

            obj.SampleAndHoldTime=value;
        end
    end


    methods

        function obj=AnalogInSingle(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end

        function open(obj)
            if ioplayback.base.target

                obj.MW_ANALOGIN_HANDLE=coder.nullcopy(0);
                if isempty(obj.Pin)
                    error('ioplayback:svd:EmptyPin',...
                    ['The property Pin is not defined. You must set Pin ',...
                    'to a valid value.'])
                end
            else

                coder.cinclude('mw_analogin.h');
                obj.MW_ANALOGIN_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if isnumeric(obj.Pin)
                    obj.MW_ANALOGIN_HANDLE=coder.ceval('MW_AnalogIn_Open',obj.Pin,uint32(obj.SampleAndHoldTime*1e6));
                else
                    pinname=coder.opaque('uint32_T',obj.Pin);
                    obj.MW_ANALOGIN_HANDLE=coder.ceval('MW_AnalogIn_Open',pinname,uint32(obj.SampleAndHoldTime*1e6));
                end

            end
        end

        function setTriggerSource(obj,ConversionTriggerSource,TriggerType)
            if nargin>1
                narginchk(3,3);

                obj.ConversionTriggerSource=ConversionTriggerSource;
                obj.ExternalTriggerType=TriggerType;
            else
                narginchk(1,1);
            end

            if ioplayback.base.target

            else

                AnalogInTriggerTypeLoc=coder.const(@obj.getAnalogInTriggerSourceType,obj.ConversionTriggerSource);
                AnalogInTriggerTypeLoc=coder.opaque('MW_AnalogIn_TriggerSource_T',AnalogInTriggerTypeLoc);
                if isempty(obj.ExternalTriggerType)
                    ExternalTriggerTypeLoc=coder.opaque('uint32_T','MW_UNDEFINED_VALUE');
                elseif isnumeric(obj.ExternalTriggerType)
                    ExternalTriggerTypeLoc=uint32(obj.ExternalTriggerType);
                else
                    ExternalTriggerTypeLoc=coder.opaque('uint32_T',obj.ExternalTriggerType);
                end

                coder.ceval('MW_AnalogIn_SetTriggerSource',obj.MW_ANALOGIN_HANDLE,AnalogInTriggerTypeLoc,ExternalTriggerTypeLoc);
            end
        end

        function setNotificationType(obj,EnableConversionCompleteNotify)
            narginchk(1,2);
            if nargin>1
                obj.EnableConversionCompleteNotify=EnableConversionCompleteNotify;
            end

            if obj.EnableConversionCompleteNotify
                if ioplayback.base.target

                else
                    if~isempty(obj.EventID)
                        ADCNotificationValueLoc=coder.opaque('uint32_T',obj.EventID);
                        coder.ceval('MW_AnalogIn_EnableNotification',obj.MW_ANALOGIN_HANDLE,ADCNotificationValueLoc);
                    end
                end
            end
        end

        function resetNotificationType(obj)
            if obj.EnableConversionCompleteNotify
                if ioplayback.base.target

                else
                    if~isempty(obj.EventID)
                        ADCNotificationValueLoc=coder.opaque('uint32_T',obj.EventID);
                        coder.ceval('MW_AnalogIn_DisableNotification',obj.MW_ANALOGIN_HANDLE,ADCNotificationValueLoc);
                    end
                end
            end
        end

        function AnalogInStatus=getAnalogInStatus(obj)
            AnalogInStatus=uint8(0);

            if ioplayback.base.target

            else
                AnalogInStatus=coder.ceval('MW_AnalogIn_GetStatus',obj.MW_ANALOGIN_HANDLE);
            end
        end

        function mw_analogin_result_out=readAnalogInResult(obj,varargin)

            switch obj.OutputDataType
            case 'int8'
                mw_analogin_result_out=int8(zeros(1,1));
            case 'uint8'
                mw_analogin_result_out=uint8(zeros(1,1));
            case 'int16'
                mw_analogin_result_out=int16(zeros(1,1));
            case 'uint16'
                mw_analogin_result_out=uint16(zeros(1,1));
            case 'int32'
                mw_analogin_result_out=int32(zeros(1,1));
            case 'uint32'
                mw_analogin_result_out=uint32(zeros(1,1));
            case 'single'
                mw_analogin_result_out=single(zeros(1,1));
            case 'double'
                mw_analogin_result_out=double(zeros(1,1));
            end

            if ioplayback.base.target
                if isequal(obj.SimulationOutput,'From input port')

                    mw_analogin_result_out=cast(varargin{1},obj.OutputDataType);
                end
            else

                DataTypeIDLoc=coder.const(@obj.getAnalogInOutputDataType,obj.OutputDataType);
                DataTypeIDLoc=coder.opaque('MW_AnalogIn_ResultDataType_T',DataTypeIDLoc);
                coder.ceval('MW_AnalogIn_ReadResult',obj.MW_ANALOGIN_HANDLE,coder.wref(mw_analogin_result_out),DataTypeIDLoc);
            end
        end

        function start(obj)
            if~obj.ReadResultsOnly&&isequal(obj.ConversionTriggerSource,'Software')
                if ioplayback.base.target

                else
                    coder.ceval('MW_AnalogIn_Start',obj.MW_ANALOGIN_HANDLE);
                end
            end
        end

        function stop(obj)
            if ioplayback.base.target

            else
                coder.ceval('MW_AnalogIn_Stop',obj.MW_ANALOGIN_HANDLE);
            end
        end

        function close(obj)
            if ioplayback.base.target

            else
                coder.ceval('MW_AnalogIn_Close',obj.MW_ANALOGIN_HANDLE);
            end
        end
    end


    methods
        function configSource(obj,hwObjHandle)
            configurePin(hwObjHandle,obj.Pin,'AnalogInput');
        end
        function configStreaming(obj,hwObjHandle)
            readVoltage(hwObjHandle,obj.Pin);
            setRate(hwObjHandle,obj.SampleTime);
        end
    end


    methods

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end
    end


    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            if isequal(prop,'ReadResultsOnly')||isequal(prop,'EnableOuputStatus')
                flag=true;


            elseif isequal(prop,'ExternalTriggerType')
                flag=isequal(obj.ConversionTriggerSource,'Software')...
                ||isempty(obj.ExternalTriggerType);
            elseif isequal(prop,'ConversionTriggerSource')
                flag=isempty(obj.ExternalTriggerType);
            elseif isequal(prop,'EnableConversionCompleteNotify')
                flag=isequal(obj.ConversionTriggerSource,'Software');
            elseif isequal(prop,'EventID')
                if isequal(obj.ConversionTriggerSource,'Software')
                    flag=true;
                else
                    flag=~(obj.EnableConversionCompleteNotify&&~isempty(obj.EventID));
                end
            else
                flag=isInactivePropertyImpl@ioplayback.SourceSystem(obj,prop);
            end
        end

        function validatePropertiesImpl(obj)
            if ioplayback.base.target


                if~isequal(obj.ConversionTriggerSource,'Software')...
                    &&isempty(obj.ExternalTriggerType)
                    error('ioplayback:svd:ErrorExternalTriggerType','External trigger source cannot be empty when conversion trigger selected is "External trigger"');
                end


                if~isempty(obj.Hw)&&~isequal(obj.ConversionTriggerSource,'Software')
                    if~isValidAnalogExternalTriggerType(obj.Hw,obj.Pin,obj.ExternalTriggerType)
                        if isnumeric(obj.Pin)
                            error('ioplayback:svd:ADCEndOfConvWrongSelection','Selected external trigger source is not available with pin %d',obj.Pin);
                        else
                            error('ioplayback:svd:ADCEndOfConvWrongSelection','Selected external trigger source is not available with pin %s',obj.Pin);
                        end
                    end
                end


                if~isempty(obj.Hw)&&obj.EnableConversionCompleteNotify
                    if~isValidAnalogEventsID(obj.Hw,obj.Pin,obj.EventID)
                        if isnumeric(obj.Pin)
                            error('ioplayback:svd:ADCEndOfConvWrongSelection','Selected end of conversion is not available with pin %d',obj.Pin);
                        else
                            error('ioplayback:svd:ADCEndOfConvWrongSelection','Selected end of conversion is not available with pin %s',obj.Pin);
                        end
                    end
                end
            end
        end

        function sts=getSampleTimeImpl(obj)
            sts=getSampleTimeImpl@ioplayback.base.BlockSampleTime(obj);
        end


        function numIn=getNumInputsImpl(obj)
            if~isequal(obj.SimulationOutput,'From input port')
                numIn=0;
            else
                numIn=1;
            end
        end


        function numOut=getNumOutputsImpl(obj)
            numOut=1+obj.EnableOuputStatus;
        end


        function varargout=getOutputNamesImpl(obj)
            varargout{1}='Data';

            if obj.EnableOuputStatus
                varargout{getNumOutputsImpl(obj)}='Status';
            end
        end


        function varargout=isOutputFixedSizeImpl(obj)
            for i=1:getNumOutputsImpl(obj)
                varargout{i}=true;
            end
        end


        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=obj.OutputDataType;

            if obj.EnableOuputStatus
                varargout{end+1}='uint8';
            end
        end


        function varargout=getOutputSizeImpl(obj)
            varargout{1}=[1,1];

            if obj.EnableOuputStatus
                varargout{end+1}=[1,1];
            end
        end


        function varargout=isOutputComplexImpl(obj)
            varargout{1}=false;
            if obj.EnableOuputStatus
                varargout{end+1}=false;
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end


        function getAnalogInHandle(obj)
            if~ioplayback.base.target
                obj.MW_ANALOGIN_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if isnumeric(obj.Pin)
                    obj.MW_ANALOGIN_HANDLE=coder.ceval('MW_AnalogIn_GetHandle',obj.Pin);
                else
                    pinname=coder.opaque('uint32_T',obj.Pin);
                    obj.MW_ANALOGIN_HANDLE=coder.ceval('MW_AnalogIn_GetHandle',pinname);
                end
            else
                obj.MW_ANALOGIN_HANDLE=coder.nullcopy(0);

            end
        end
    end


    methods(Hidden)
        function event=getNextEvent(obj,eventID,time)
            if isequal(obj.ConversionTriggerSource,'Software')&&obj.EnableConversionCompleteNotify
                if getSampleTime(obj)>=0
                    event.Time=time+getSampleTime(obj)+double(obj.ConversionTime)+double(obj.SampleAndHoldTime);
                else
                    if isequal(eventID,obj.EventID)

                    else
                        event.Time=obj.RecordedSampleTime*(obj.EventTick+1)+double(obj.ConversionTime)+double(obj.SampleAndHoldTime);
                    end
                    obj.EventTick=obj.EventTick+1;
                end
            else
                event=[];
            end
        end


        function event=eventCallback(obj,~,time)
            if obj.EnableConversionCompleteNotify
                event.Time=time+double(obj.ConversionTime)+double(obj.SampleAndHoldTime);
                event.ID=obj.EventID;
            else
                event=[];
            end
        end
    end


    methods(Access=protected)
        function setupImpl(obj)
            if~obj.ReadResultsOnly
                if ioplayback.base.target

                    if~isequal(obj.SimulationOutput,'From input port')
                        obj.DataFileFormat='TimeStamp';
                        obj.SignalInfo.Name='AnalogInSingle';
                        obj.SignalInfo.Dimensions=[obj.DataSize(1),obj.DataSize(2)];
                        obj.SignalInfo.DataType=obj.OutputDataType;
                        obj.SignalInfo.IsComplex=false;
                        setupImpl@ioplayback.SourceSystem(obj);
                        if isequal(obj.SimulationOutput,'From recorded file')
                            setup(obj.Reader,1);
                        end
                    end

                    try %#ok<EMTC>


                        Events=[];
                        if obj.EnableConversionCompleteNotify
                            Events=struct('EventID',obj.EventID,...
                            'CommType','pull',...
                            'TaskFcnPollCmd','');
                        end

                        if~isequal(obj.ConversionTriggerSource,'Software')
                            if isempty(Events)
                                Events=struct('EventID',obj.ExternalTriggerType,...
                                'CommType','listen',...
                                'TaskFcnPollCmd','');
                            else
                                Events(end+1)=struct('EventID',obj.ExternalTriggerType,...
                                'CommType','listen',...
                                'TaskFcnPollCmd','');%#ok<EMGRO>
                            end
                        end
                        if~isempty(Events)
                            soc.registerBlock(obj,Events);
                        end
                    catch ME
                        disp(ME.message)
                    end
                else

                    open(obj);

                    setTriggerSource(obj);

                    setNotificationType(obj);
                end
            end
        end

        function varargout=stepImpl(obj,varargin)

            if~obj.ReadResultsOnly
                start(obj);
            end


            if obj.EnableOuputStatus
                varargout{2}=uint8(0);
            end


            if obj.ReadResultsOnly
                getAnalogInHandle(obj);
            end

            if ioplayback.base.target
                if~isequal(obj.SimulationOutput,'From input port')
                    varargout{1}=cast(stepImpl@ioplayback.SourceSystem(obj),obj.OutputDataType);
                else
                    varargout{1}=cast(readAnalogInResult(obj,varargin{1}),obj.OutputDataType);
                end
            else
                varargout{1}=readAnalogInResult(obj);
            end


            if obj.EnableOuputStatus
                varargout{obj.NumberOfChannels+1}=getAnalogInStatus(obj);
            end
        end

        function releaseImpl(obj)
            if~obj.ReadResultsOnly

                resetNotificationType(obj);

                stop(obj);

                close(obj);
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','Analog Input',...
            'Text',[['Measure the voltage of an analog input pin.',newline,newline]...
            ,'Do not assign the same Pin number to multiple blocks within a model.']);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            PinProp=matlab.system.display.internal.Property('Pin','Description','Pin');

            ReadResultsOnlyProp=matlab.system.display.internal.Property('ReadResultsOnly','Description','Read results only');

            SampleAndHoldTimeProp=matlab.system.display.internal.Property('SampleAndHoldTime','Description','Sample and hold time');

            ConversionTriggerSourceProp=matlab.system.display.internal.Property('ConversionTriggerSource','Description','Trigger A/D conversion');

            ExternalTriggerTypeProp=matlab.system.display.internal.Property('ExternalTriggerType','Description','External trigger source');



            EnableConversionCompleteNotifyProp=matlab.system.display.internal.Property('EnableConversionCompleteNotify','Description','Enable conversion complete notification');

            EventIDProp=matlab.system.display.internal.Property('EventID','Description','Event ID');

            EnableOuputStatusProp=matlab.system.display.internal.Property('EnableOuputStatus','Description','Output A/D conversion status');

            SampleTimeProp=matlab.system.display.internal.Property('SampleTime','Description','Sample time');



            PropertyListOut={PinProp,...
            ReadResultsOnlyProp,...
            SampleAndHoldTimeProp,...
            ConversionTriggerSourceProp,...
            ExternalTriggerTypeProp,...
            EnableConversionCompleteNotifyProp,...
            EventIDProp,...
            EnableOuputStatusProp,...
            SampleTimeProp};



            GroupMain=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'PropertyList',PropertyListOut);


            ConversionTimeProp=matlab.system.display.internal.Property('ConversionTime','Description','Conversion time');
            GroupSimulation=ioplayback.SourceSystem.getPropertyGroupsList;
            GroupSimulation.PropertyList=[{ConversionTimeProp},GroupSimulation.PropertyList];

            groups=[GroupMain,GroupSimulation];

            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end

    methods(Static,Access=protected)
        function TriggerValue=getAnalogInTriggerSourceType(TriggerSource)
            coder.inline('always');
            switch TriggerSource
            case 'Software'
                TriggerValue='MW_ANALOGIN_SOFTWARE_TRIGGER';
            case 'External trigger'
                TriggerValue='MW_ANALOGIN_EXTERNAL_TRIGGER';
            otherwise
                TriggerValue='MW_ANALOGIN_SOFTWARE_TRIGGER';
            end
        end

        function DataTypeID=getAnalogInOutputDataType(OutputDataType)
            coder.inline('always');

            switch OutputDataType
            case 'int8'
                DataTypeID='MW_ANALOGIN_INT8';
            case 'uint8'
                DataTypeID='MW_ANALOGIN_UINT8';
            case 'int16'
                DataTypeID='MW_ANALOGIN_INT16';
            case 'uint16'
                DataTypeID='MW_ANALOGIN_UINT16';
            case 'int32'
                DataTypeID='MW_ANALOGIN_INT32';
            case 'uint32'
                DataTypeID='MW_ANALOGIN_UINT32';
            case 'single'
                DataTypeID='MW_ANALOGIN_FLOAT';
            case 'double'
                DataTypeID='MW_ANALOGIN_DOUBLE';
            otherwise
                DataTypeID='MW_ANALOGIN_UINT16';
            end
        end
    end
end
