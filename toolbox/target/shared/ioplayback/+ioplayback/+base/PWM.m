classdef PWM<ioplayback.SinkSystem&ioplayback.system.mixin.Event


%#codegen
%#ok<*EMCA>



    properties(Hidden,Nontunable)
        Hw=[]
    end

    properties(Abstract,Nontunable)

Pin
    end

    properties(Nontunable)

        EnableInputFrequency(1,1)logical=false;


        CounterMode='Up';
        DataTypeWarningasError=0;


        InitialFrequency=2000;

        InitialDutyCycle=0;


        NotificationType='None';


        EnablePWMSync(1,1)logical=false;
    end

    properties(Abstract,Nontunable)

        PWMSync;
    end


    properties(Constant,Hidden)
        NotificationTypeSet=matlab.system.StringSet({...
        'None',...
        'Rising edge',...
        'Falling edge',...
        'Both rising and falling edges',...
        });






        CounterModeSet=matlab.system.StringSet({'Up','Down','Center aligned'});
    end

    properties(Access=private,Dependent)
        InitialFrequencyCast;
        InitialDutyCycleCast;
    end

    properties(Access=protected)
        MW_PWM_HANDLE;
    end


    methods
        function obj=PWM(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:});
        end


        function set.InitialFrequency(obj,value)
            if ioplayback.base.target
                validateattributes(value,...
                {'numeric','embedded.fi'},...
                {'scalar','real','nonnegative'},...
                '',...
                'InitialFrequency');
                if~isempty(obj.Hw)
                    validateattributes(value,...
                    {'numeric','embedded.fi'},...
                    {'scalar','real','>=',getMinimumPWMFrequency(obj.Hw),'<=',getMaximumPWMFrequency(obj.Hw)},...
                    '',...
                    'InitialFrequency');%#ok<*MCSUP>
                end
            end
            obj.InitialFrequency=value;
        end

        function ret=get.InitialFrequencyCast(obj)
            ret=double(obj.InitialFrequency);
        end


        function set.InitialDutyCycle(obj,value)
            if ioplayback.base.target
                validateattributes(value,...
                {'numeric','embedded.fi'},...
                {'scalar','real','>=',0,'<=',100},...
                '',...
                'InitialDutyCycle');
            end
            obj.InitialDutyCycle=value;
        end

        function ret=get.InitialDutyCycleCast(obj)
            ret=double(obj.InitialDutyCycle);
        end
    end


    methods(Hidden)



        function event=getNextEvent(obj,~,time)






            if isequal(obj.NotificationType,'None')
                event.EventID=obj.PWMSync;

                if isequal(obj.CounterMode,'Up')||...
                    isequal(obj.CounterMode,'Down')
                    event.Time=time+(1/obj.InitialFrequency);
                else











                    event.Time=time+(1/obj.InitialFrequency)/2;

                end
            else
                event=[];
            end
        end
    end


    methods
        function open(obj)
            if~ioplayback.base.target

                coder.cinclude('mw_pwm.h');
                obj.MW_PWM_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');


                CounterModeLoc=coder.const(@obj.getPwmCounterMode,obj.CounterMode);
                CounterModeLoc=coder.opaque('MW_PWM_CounterModes_T',CounterModeLoc);

                if isnumeric(obj.Pin)
                    obj.MW_PWM_HANDLE=coder.ceval('MW_PWM_Open',obj.Pin,...
                    CounterModeLoc,...
                    obj.InitialFrequencyCast,...
                    obj.InitialDutyCycleCast);
                else
                    pinname=coder.opaque('uint32_T',obj.Pin);
                    obj.MW_PWM_HANDLE=coder.ceval('MW_PWM_Open',pinname,...
                    CounterModeLoc,...
                    obj.InitialFrequencyCast,...
                    obj.InitialDutyCycleCast);
                end
            else

                obj.MW_PWM_HANDLE=coder.nullcopy(0);
            end
        end

        function setCounterMode(obj)
            if~ioplayback.base.target
                CounterModeLoc=coder.const(@obj.getPwmCounterMode,obj.CounterMode);
                CounterModeLoc=coder.opaque('MW_PWM_CounterModes_T',CounterModeLoc);
                coder.ceval('MW_PWM_SetCounterMode',obj.MW_PWM_HANDLE,CounterModeLoc);
            else

            end
        end

        function setPWMDutyCycle(obj,DutyCycle)
            if~ioplayback.base.target

                coder.ceval('MW_PWM_SetDutyCycle',obj.MW_PWM_HANDLE,...
                double(DutyCycle));
            else
                validateattributes(DutyCycle,...
                {'numeric','embedded.fi'},...
                {'scalar','>=',0,'<=',100},...
                '',...
                'Duty Cycle');

            end
        end

        function setPWMFrequency(obj,frequencyInHz)
            if~ioplayback.base.target
                coder.ceval('MW_PWM_SetFrequency',obj.MW_PWM_HANDLE,...
                double(frequencyInHz));
            else
                validateattributes(frequencyInHz,...
                {'numeric','embedded.fi'},...
                {'scalar','nonnegative'},...
                '',...
                'Frequency');


                if~isempty(obj.Hw)
                    minFreq=getMinimumPWMFrequency(obj.Hw);
                    maxFreq=getMaximumPWMFrequency(obj.Hw);
                    validateattributes(frequencyInHz,...
                    {'numeric','embedded.fi'},...
                    {'scalar','>=',minFreq,'<=',maxFreq},...
                    '',...
                    'Frequency');
                end

            end
        end

        function setNotificationType(obj,NotificationType)
            obj.NotificationType=NotificationType;
            if~ioplayback.base.target
                if~strcmp(obj.NotificationType,'None')

                    PWMNotifyLoc=coder.const(@obj.getPwmNotificationTypeValue,obj.NotificationType);
                    PWMNotifyLoc=coder.opaque('MW_PWM_EdgeNotification_T',PWMNotifyLoc);

                    coder.ceval('MW_PWM_EnableNotification',obj.MW_PWM_HANDLE,PWMNotifyLoc);
                end
            else

            end
        end

        function resetNotificationType(obj)
            if~ioplayback.base.target
                if~strcmp(obj.NotificationType,'None')

                    PWMNotifyLoc=coder.const(@obj.getPwmNotificationTypeValue,obj.NotificationType);
                    PWMNotifyLoc=coder.opaque('MW_PWM_EdgeNotification_T',PWMNotifyLoc);

                    coder.ceval('MW_PWM_DisableNotification',obj.MW_PWM_HANDLE,PWMNotifyLoc);
                end
            else

            end
        end

        function setSynchronization(obj)
            if~ioplayback.base.target
                pwmsync=coder.opaque('uint32_T',obj.PWMSync);
                coder.ceval('MW_PWM_SetSynchronization',obj.MW_PWM_HANDLE,pwmsync);
            else

            end
        end

        function start(obj)
            if~ioplayback.base.target

                coder.ceval('MW_PWM_Start',obj.MW_PWM_HANDLE);
            else

            end
        end

        function PwmOutStatus=getPWMOutputStatus(obj)
            PwmOutStatus=coder.nullcopy(double(0));
            if~ioplayback.base.target

                PwmOutStatus=coder.ceval('MW_PWM_GetOutputState',obj.MW_PWM_HANDLE);
            else

            end
        end

        function stop(obj)
            if~ioplayback.base.target

                resetNotificationType(obj);

                coder.ceval('MW_PWM_Stop',obj.MW_PWM_HANDLE);
            else

            end
        end

        function close(obj)
            if~ioplayback.base.target

                stop(obj);


                coder.ceval('MW_PWM_Close',obj.MW_PWM_HANDLE);
            else

            end
        end
    end

    methods(Access=protected)

        function numIn=getNumInputsImpl(obj)
            if obj.EnableInputFrequency
                numIn=2;
            else
                numIn=1;
            end
        end


        function varargout=getInputNamesImpl(obj)

            varargout{1}='Duty Cycle';
            if obj.EnableInputFrequency
                varargout{2}='Frequency';
            end
        end


        function numOut=getNumOutputsImpl(obj)
            if~isequal(obj.SendSimulationInputTo,'Output port')
                numOut=0;
            else
                numOut=1;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            if~isequal(obj.SendSimulationInputTo,'Output port')
                varargout=[];
            else

                varargout{1}=propagatedInputDataType(obj,1);
            end
        end


        function setupImpl(obj,varargin)
            if~ioplayback.base.target

                open(obj);

                setNotificationType(obj,obj.NotificationType);

                if obj.EnablePWMSync
                    setSynchronization(obj);
                end

                start(obj);
            else

                if isequal(obj.SendSimulationInputTo,'Data file')
                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='PWM';
                    obj.SignalInfo.Dimensions=[1,1];
                    obj.SignalInfo.DataType=class(varargin{1});
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SinkSystem(obj);
                end



                if obj.EnablePWMSync
                    EventSim=struct('EventID',obj.PWMSync,...
                    'CommType','pull',...
                    'TaskFcnPollCmd','');
                    soc.registerBlock(obj,EventSim);
                end
            end
        end


        function varargout=stepImpl(obj,varargin)

            if~ioplayback.base.target
                dutyCycle=double(varargin{1});
                setPWMDutyCycle(obj,dutyCycle);
                if obj.EnableInputFrequency
                    frequency=double(varargin{2});
                    setPWMFrequency(obj,frequency);
                end

            else
                if isequal(obj.SendSimulationInputTo,'Data file')
                    stepImpl@ioplayback.SinkSystem(obj,varargin{1});
                elseif isequal(obj.SendSimulationInputTo,'Terminate')

                end
            end


            if isequal(obj.SendSimulationInputTo,'Output port')
                if~ioplayback.base.target

                    varargout{1}=cast(0,class(varargin{1}));
                else
                    varargout{1}=varargin{1};
                end
            end
        end


        function releaseImpl(obj)

            if~ioplayback.base.target
                close(obj);
            else
                if isequal(obj.SendSimulationInputTo,'Data file')
                    releaseImpl@ioplayback.SinkSystem(obj);
                end
            end
        end

        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end


        function varargout=getOutputSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=[1,1];
            else

            end
        end

        function validateInputsImpl(~,varargin)
            if ioplayback.base.target

                validateattributes(varargin{end},...
                {'numeric','embedded.fi'},...
                {'scalar','>=',0,'<=',100},...
                '',...
                'Duty Cycle');
            end
        end

        function validatePropertiesImpl(obj)
            if ioplayback.base.target

                if~isempty(obj.Hw)&&obj.EnablePWMSync
                    if~isValidPWMSyncs(obj.Hw,obj.Pin,obj.PWMSync)
                        if isnumeric(obj.Pin)
                            error('ioplayback:svd:PWMSyncWrongSelection','Selected PWM Sync not available with pin %d',obj.Pin);
                        else
                            error('ioplayback:svd:PWMSyncWrongSelection','Selected PWM Sync not available with pin %s',obj.Pin);
                        end
                    end
                end
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

        function[groups,PropertyList]=getPropertyGroupsImpl

            GroupSimulation=ioplayback.SinkSystem.getPropertyGroupsList;



            PinProp=matlab.system.display.internal.Property('Pin','Description','Pin');

            CounterModeProp=matlab.system.display.internal.Property('CounterMode','Description','Counter modes');

            EnableInputFrequencyProp=matlab.system.display.internal.Property('EnableInputFrequency','Description','Enable frequency input');

            InitialFrequencyProp=matlab.system.display.internal.Property('InitialFrequency','Description','Initial frequency (Hz)');

            InitialDutyCycleProp=matlab.system.display.internal.Property('InitialDutyCycle','Description','Initial duty cycle (0 - 100)');

            EnablePWMSyncTypeProp=matlab.system.display.internal.Property('EnablePWMSync','Description','Enable synchronization');

            PWMSyncTypeProp=matlab.system.display.internal.Property('PWMSync','Description','Synchronization');

            NotificationTypeProp=matlab.system.display.internal.Property('NotificationType','Description','Notify on PWM');


            PropertyListOut={PinProp,CounterModeProp,EnableInputFrequencyProp,InitialFrequencyProp,InitialDutyCycleProp,EnablePWMSyncTypeProp,PWMSyncTypeProp,NotificationTypeProp};


            GroupMain=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'PropertyList',PropertyListOut);

            groups=[GroupMain,GroupSimulation];

            if nargout>1
                PropertyList=PropertyListOut;
            end
        end
    end

    methods(Static,Access=protected)
        function NotificationValue=getPwmNotificationTypeValue(NotificationValueStr)
            coder.inline('always');
            switch NotificationValueStr
            case 'Rising edge'
                NotificationValue='MW_PWM_RISING_EDGE';
            case 'Falling edge'
                NotificationValue='MW_PWM_FALLING_EDGE';
            case 'Both rising and falling edges'
                NotificationValue='MW_PWM_BOTH_EDGES';
            case 'Counter reaches to zero'
                NotificationValue='MW_PWM_COUNTER_REACHES_ZERO';
            case 'Counter overflows'
                NotificationValue='MW_PWM_COUNTER_OVERFLOWS';
            case 'Counter reaches to zero or overflows'
                NotificationValue='MW_PWM_COUNTER_REACHES_ZERO | MW_PWM_COUNTER_OVERFLOWS';
            otherwise
                NotificationValue='MW_PWM_NO_NOTIFICATION';
            end
        end

        function CounterModeValue=getPwmCounterMode(CounterModeStr)
            coder.inline('always');
            switch CounterModeStr
            case 'Up'
                CounterModeValue='MW_COUNTERMODE_UP';
            case 'Down'
                CounterModeValue='MW_COUNTERMODE_DOWN';
            case 'Center aligned'
                CounterModeValue='MW_COUNTERMODE_CENTERALIGNED';
            otherwise
                CounterModeValue='MW_COUNTERMODE_UP';
            end
        end
    end
end
