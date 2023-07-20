classdef(Abstract)AmiParameter<serdes.internal.ibisami.ami.Node







    properties
Usage
Types
Format
    end
    properties(SetAccess=protected)
        Editable=true;
    end
    properties(Dependent)
Type
Default
CurrentValue
CurrentValueDisplay
    end
    properties(Dependent,SetAccess=private)
DisplayValues
    end
    properties(Access=private)
CurrentValueBacking
    end
    methods

        function parameter=AmiParameter(varargin)
            parameter=parameter@serdes.internal.ibisami.ami.Node(varargin{:});
            if isa(parameter,'serdes.internal.ibisami.ami.parameter.ModelSpecificParameter')||...
                isa(parameter,'serdes.internal.ibisami.ami.parameter.ReservedParameter')

                parameter.Sterile=true;
            else
                error(message('serdes:ibis:NeedReservedOrModelSpecific'))
            end
        end
    end
    methods(Access=protected)


        function ok=validateUsage(~,~)
            ok=true;
        end
        function ok=validateType(~,~)
            ok=true;
        end
        function ok=validateFormat(~,~)
            ok=true;
        end
    end
    methods
        function currentValueDisplay=get.CurrentValueDisplay(param)

            currentValue=param.CurrentValue;
            if isempty(currentValue)
                currentValueDisplay="";
                return;
            end
            if isstring(currentValue)
                currentValueDisplay=char(currentValue);
            elseif ischar(currentValue)
                currentValueDisplay=currentValue;
            else
                currentValueDisplay=string(mat2str(currentValue));
            end
            if~isempty(param.Format)&&...
                isa(param.Format,'serdes.internal.ibisami.ami.format.List')&&...
                ~isempty(param.Format.ListTips)
                for tipIdx=1:numel(param.Format.Values)
                    value=string(param.Format.Values{tipIdx});
                    if param.Type.isEqual(value,currentValueDisplay)
                        currentValueDisplay=param.Format.ListTips{tipIdx};
                        break
                    end
                end
            end
        end
        function set.CurrentValueDisplay(param,newCurrentValueDisplay)
            validateattributes(newCurrentValueDisplay,...
            {'string','char'},{},...
            "AmiParameter","CurrentValueDisplay")
            newCurrentValue=string(newCurrentValueDisplay);
            if~isempty(param.Format)&&...
                isa(param.Format,'serdes.internal.ibisami.ami.format.List')&&...
                ~isempty(param.Format.ListTips)
                for tipIdx=1:numel(param.Format.ListTips)
                    tip=string(param.Format.ListTips{tipIdx});
                    if tip==newCurrentValue
                        newCurrentValue=param.Format.Values{tipIdx};
                        break
                    end
                end
            end
            param.CurrentValue=newCurrentValue;
        end
        function displayValues=get.DisplayValues(param)
            displayValues={};
            if isempty(param.Format)||...
                ~isa(param.Format,'serdes.internal.ibisami.ami.format.List')
                return
            end
            if~isempty(param.Format.ListTips)
                displayValues=param.Format.ListTips;
            else
                displayValues=param.Format.Values;
            end
        end
        function set.Usage(param,usage)
            if isa(usage,'serdes.internal.ibisami.ami.usage.AmiUsage')&&...
                isscalar(usage)
                if param.validateUsage(usage)
                    param.Usage=usage;
                end
            elseif(isa(usage,'char')||isa(usage,'string'))&&...
                serdes.internal.ibisami.ami.parameter.AmiParameter.isUsage(usage)
                param.Usage=serdes.internal.ibisami.ami.parameter.AmiParameter.getUsageFromName(usage);
                usage=serdes.internal.ibisami.ami.parameter.AmiParameter.getUsageFromName(usage);
                if param.validateUsage(usage)
                    param.Usage=usage;
                end
            else
                error(message('serdes:ibis:NotRecognized',string(type),'Usage'))
            end
        end
        function set.Types(param,types)









            if isvector(types)


                lTypes=cell(size(types));
                for idx=1:length(types)
                    type=types{idx};
                    if(isa(type,'char')||(isa(type,'string')&&isscalar(type)))&&...
                        serdes.internal.ibisami.ami.parameter.AmiParameter.isType(type)
                        type=serdes.internal.ibisami.ami.parameter.AmiParameter.getTypeFromName(type);
                    elseif~isa(type,'serdes.internal.ibisami.ami.type.AmiType')||...
                        ~isscalar(type)
                        error(message('serdes:ibis:NotRecognized',type.Name,'Type'))
                    end
                    if param.validateType(type)
                        lTypes{idx}=type;
                    end
                end
                param.Types=lTypes;
                param.validateFormatAndTypes()
            else
                error(message('serdes:ibis:NotRecognized',string(types),'Type'))
            end
        end
        function types=get.Types(param)

            types=param.Types;
        end
        function set.Type(param,type)


            if ischar(type)
                type=string(type);
            end
            validateattributes(type,{'string','serdes.internal.ibisami.ami.type.AmiType'},{'scalar'},"set.Type","type")
            param.Types={type};
        end
        function type=get.Type(param)

            if isempty(param.Types)
                type=[];
            else
                type=param.Types{1};
            end
        end
        function set.Format(param,format)
            szFormat=size(format);
            if isa(format,'serdes.internal.ibisami.ami.format.AmiFormat')&&...
                isscalar(format)
                if param.validateFormat(format)
                    param.Format=format;
                    param.validateFormatAndTypes()
                end
            elseif~((isa(format,'char')&&szFormat(1)==1)||...
                (isa(format,'string')&&isscalar(format)))
                error(message('serdes:ibis:NotRecognized',string(format),'Format'))
            else
                formatArgs=strsplit(strtrim(format));
                if strcmp(formatArgs,"")
                    error(message('serdes:ibis:EmptyFormat'))
                else
                    formatSpec=formatArgs(1);
                    if~(serdes.internal.ibisami.ami.parameter.AmiParameter.isFormatKeyWord(formatSpec))
                        error(message('serdes:ibis:NotRecognized',format,'Format'))
                    else
                        formatArgs(1)=[];
                        format=serdes.internal.ibisami.ami.parameter.AmiParameter.getFormatForFormatName(formatSpec,formatArgs);
                        if param.validateFormat(format)
                            param.Format=format;
                            param.validateFormatAndTypes()
                        end
                    end
                end
            end
        end
        function value=get.CurrentValue(param)
            if~isempty(param.Format)&&...
                isa(param.Format,'serdes.internal.ibisami.ami.format.Corner')
                value="NA";
            else
                value=param.CurrentValueBacking;
                if isempty(value)
                    value=param.Default;
                else
                    if~isempty(param.Type)&&(isa(value,'char')||isa(value,'string'))
                        value=param.Type.convertStringValueToType(value);
                    end
                end
            end
        end

        function default=get.Default(param)
            if~isempty(param.Format)
                currentValue=param.CurrentValueBacking;
                if~isempty(currentValue)&&~strcmp(currentValue,"NA")
                    default=currentValue;
                else
                    default=param.Format.Default;
                end
                if~isempty(param.Type)&&(isa(default,'char')||isa(default,'string'))
                    default=param.Type.convertStringValueToType(default);
                end
            else
                default=[];
            end
        end
        function set.Default(param,defaultValue)
            if~isempty(param.Format)
                param.Format.Default=defaultValue;
            else
                error(message('serdes:ibis:NeedItem',param.NodeName,'Format','Default'))
            end
        end
        function set.CurrentValue(parameter,value)
            value=parameter.currentValueChanging(value);
            if isempty(parameter.Format)%#ok<*MCSUP>
                error(message('serdes:ibis:NeedItem',parameter.NodeName,'Format','Current Value'))
            elseif isa(parameter.Format,'serdes.internal.ibisami.ami.format.Corner')


            elseif isempty(parameter.Type)
                error(message('serdes:ibis:NeedItem',parameter.NodeName,'Type','Current Value'))
            elseif~parameter.validateValue(value)
                err=serdes.internal.ibisami.ami.invalidTypeAndFormatError(parameter,value,"Current Value");
                error(err)
            else
                parameter.CurrentValueBacking=value;
            end
        end
    end
    methods(Access=protected)
        function value=currentValueChanging(parameter,value)





            format=parameter.Format;
            if isa(format,'serdes.internal.ibisami.ami.format.Value')
                if ischar(value)
                    value=string(value);
                end
                parameter.Format=serdes.internal.ibisami.ami.format.Value(value);
            end
        end
    end
    methods(Access=private)
        function validateFormatAndTypes(parameter)
            if isempty(parameter.Format)||isempty(parameter.Types)
                return
            end
            format=parameter.Format;
            for idx=1:length(parameter.Types)
                type=parameter.Types{idx};
                if~format.validateFormatAndType(type)
                    warning(message('serdes:ibis:InvalidFormatAndType',parameter.NodeName,format.Name,type.Name))
                end
            end
        end
    end
    methods

        function parameterStrings=addParameterStrings(parameter,indent)
            if isa(parameter.Format,'serdes.internal.ibisami.ami.format.Table')
                type=parameter.Types;
            else
                type=parameter.Type;
                if length(parameter.Types)>1
                    warning(message('serdes:ibis:MultipleTypesIgnored',parameter.NodeName))
                end
            end
            parameterStrings=" "+parameter.Usage.getKeyWordBranch(type,indent);
            parameterStrings=parameterStrings+" "+parameter.Type.getKeyWordBranch(parameter.Types,indent);



            format=parameter.Format;
            parameterStrings=parameterStrings+" "+format.getKeyWordBranch(type,indent);
            if~isa(format,'serdes.internal.ibisami.ami.format.Value')&&...
                ~isa(format,'serdes.internal.ibisami.ami.format.Table')&&...
                ~isa(parameter.Usage,'serdes.internal.ibisami.ami.usage.Out')&&...
                ~isempty(format.Default)
                default=parameter.Type.convertToAmiValue(format.Default);
                parameterStrings=parameterStrings+" (Default "+default+")";
            end
            if isa(format,'serdes.internal.ibisami.ami.format.List')
                listTipBranch=format.getListTipBranch;
                if listTipBranch~=""
                    parameterStrings=parameterStrings+newline+indent+"  "+listTipBranch;
                end
            end
        end
        function valid=validateValue(param,value)
            if~isempty(param.Format)&&~isempty(param.Type)
                valid=param.Format.verifyValueForType(param.Type,value);
            elseif isempty(param.Format)
                error(message('serdes:ibis:ValidateFailed',param.NodeName,'Format'))
            else
                error(message('serdes:ibis:ValidateFailed',param.NodeName,'Type'))
            end
        end
    end
    properties(Constant,Hidden)
        PropertyStrings={...
'Description'...
        ,'Usage'...
        ,'Type'...
        ,'Default'...
        ,'Format'...
        ,'List_Typ'...
        ,'Labels'...
        };
        FormatKeyWords={...
'Value'...
        ,'Range'...
        ,'List'...
        ,'Corner'...
        ,'Increment'...
        ,'Steps'...
        ,'Table'...
        ,'Gaussian'...
        ,'Dual-Dirac'...
        ,'DjRj'...
        };
        KeyWords=[serdes.internal.ibisami.ami.parameter.AmiParameter.PropertyStrings,...
        serdes.internal.ibisami.ami.parameter.AmiParameter.FormatKeyWords];
        TypeNames={...
'Boolean'...
        ,'Float'...
        ,'Integer'...
        ,'String'...
        ,'Tap'...
        ,'UI'...
        };
        UsageNames={...
'In'...
        ,'Out'...
        ,'Info'...
        ,'InOut'...
        ,'Dep'...
        };
        ReservedParameterNames={...
'AMI_Version'...
        ,'DLL_ID'...
        ,'DLL_Path'...
        ,'GetWave_Exists'...
        ,'Ignore_Bits'...
        ,'Init_Returns_Impulse'...
        ,'Max_Init_Aggressors'...
        ,'Model_Name'...
        ,'Modulation'...
        ,'Modulation_Levels'...
        ,'PAM4_Mapping'...
        ,'PAM4_CenterEyeOffset'...
        ,'PAM4_CenterThreshold'...
        ,'PAM4_LowerEyeOffset'...
        ,'PAM4_LowerThreshold'...
        ,'PAM4_UpperEyeOffset'...
        ,'PAM4_UpperThreshold'...
        ,'PAM_Thresholds'...
        ,'Repeater_Type'...
        ,'Resolve_Exists'...
        ,'Rx_Clock_Recovery_DCD'...
        ,'Rx_Clock_Recovery_Dj'...
        ,'Rx_Clock_Recovery_Mean'...
        ,'Rx_Clock_Recovery_Rj'...
        ,'Rx_Clock_Recovery_Sj'...
        ,'Rx_DCD'...
        ,'Rx_Dj'...
        ,'Rx_GaussianNoise'...
        ,'Rx_Noise'...
        ,'Rx_Receiver_Sensitivity'...
        ,'Rx_R'...
        ,'Rx_Rj'...
        ,'Rx_Sj'...
        ,'Rx_UniformNoise'...
        ,'Supporting_Files'...
        ,'Tx_DCD'...
        ,'Tx_Dj'...
        ,'Tx_R'...
        ,'Tx_Rj'...
        ,'Tx_Sj'...
        ,'Tx_Sj_Frequency'...
        ,'Tx_V'...
        ,'Ts4file'...
        ,'BCI_Protocol'...
        ,'BCI_ID'...
        ,'BCI_State'...
        ,'BCI_Message_Interval_UI'...
        ,'BCI_Training_UI'...
        ,'Rx_Use_Clock_Input'...
        ,'DC_Offset'...
        ,'Rx_Decision_Time'...
        };
    end
    methods(Static)


        function isPropertyString=isPropertyString(word)
            isPropertyString=ismember(lower(word),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.PropertyStrings));
        end
        function isFormatKeyWord=isFormatKeyWord(word)
            isFormatKeyWord=ismember(lower(word),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.FormatKeyWords));
        end
        function format=getFormatForFormatName(pFormatName,formatArgs)
            import serdes.internal.ibisami.ami.format.*
            formatName=lower(char(pFormatName));
            switch formatName
            case 'value'
                format=Value(formatArgs);
            case 'range'
                format=Range(formatArgs);
            case 'list'
                format=List(formatArgs);
            case 'corner'
                format=Corner(formatArgs);
            case 'increment'
                format=Increment(formatArgs);
            case 'steps'
                format=Steps(formatArgs);
            case 'table'
                format=Table(formatArgs);
            case 'gaussian'
                format=Gaussian(formatArgs);
            case 'dual-dirac'
                format=DualDirac(formatArgs);
            case 'djrj'
                format=DjRj(formatArgs);
            otherwise
                error(message('serdes:ibis:UnrecognizedItem','Format',pFormatName))
            end
        end
        function isKeyWord=isKeyWord(word)
            isKeyWord=ismember(lower(word),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.KeyWords));
        end
        function isType=isType(word)
            isType=ismember(lower(word),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.TypeNames));
        end
        function type=getTypeFromName(pTypeName)
            import serdes.internal.ibisami.ami.type.*
            typeName=lower(char(pTypeName));
            switch typeName
            case 'boolean'
                type=Boolean();
            case 'float'
                type=Float();
            case 'integer'
                type=Integer();
            case 'string'
                type=String();
            case 'tap'
                type=Tap();
            case 'ui'
                type=UI();
            otherwise
                error(message('serdes:ibis:UnrecognizedItem','Type',pTypeName))
            end
        end
        function isUsage=isUsage(word)
            isUsage=ismember(lower(word),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.UsageNames));
        end
        function usage=getUsageFromName(pUsageName)
            import serdes.internal.ibisami.ami.usage.*
            usageName=lower(char(pUsageName));
            switch usageName
            case 'in'
                usage=In();
            case 'out'
                usage=Out();
            case 'info'
                usage=Info();
            case 'inout'
                usage=InOut();
            case 'dep'
                usage=Dep();
            otherwise
                error(message('serdes:ibis:UnrecognizedItem','Usage',pUsageName))
            end
        end
        function isReserved=isReservedParameterName(name)
            isReserved=ismember(lower(name),...
            lower(serdes.internal.ibisami.ami.parameter.AmiParameter.ReservedParameterNames));
        end
        function reservedParameter=getReservedParameter(parameterNameIn)
            parameterName=lower(char(parameterNameIn));
            import serdes.internal.ibisami.ami.parameter.general.*
            import serdes.internal.ibisami.ami.parameter.datamanagement.*
            import serdes.internal.ibisami.ami.parameter.modulation.*
            import serdes.internal.ibisami.ami.parameter.repeater.*
            import serdes.internal.ibisami.ami.parameter.jitterandnoise.*
            import serdes.internal.ibisami.ami.parameter.analog_buffer_model.*
            import serdes.internal.ibisami.ami.parameter.bci.*
            import serdes.internal.ibisami.ami.parameter.clockforwarding.*
            import serdes.internal.ibisami.ami.parameter.dc_offset.*
            import serdes.internal.ibisami.ami.parameter.rxdecisiontime.*
            switch parameterName
            case 'ami_version'
                reservedParameter=AmiVersion();
            case 'dll_id'
                reservedParameter=DllID();
            case 'dll_path'
                reservedParameter=DllPath();
            case 'getwave_exists'
                reservedParameter=GetWaveExists();
            case 'ignore_bits'
                reservedParameter=IgnoreBits();
            case 'init_returns_impulse'
                reservedParameter=InitReturnsImpulse();
            case 'max_init_aggressors'
                reservedParameter=MaxInitAggressors();
            case 'model_name'
                reservedParameter=ModelName();
            case 'modulation'
                reservedParameter=Modulation();
            case 'modulation_levels'
                reservedParameter=ModulationLevels();
            case 'pam4_mapping'
                reservedParameter=Pam4Mapping();
            case 'pam4_centereyeoffset'
                reservedParameter=Pam4CenterEyeOffset();
            case 'pam4_centerthreshold'
                reservedParameter=Pam4CenterThreshold();
            case 'pam4_lowereyeoffset'
                reservedParameter=Pam4LowerEyeOffset();
            case 'pam4_lowerthreshold'
                reservedParameter=Pam4LowerThreshold();
            case 'pam4_uppereyeoffset'
                reservedParameter=Pam4UpperEyeOffset();
            case 'pam4_upperthreshold'
                reservedParameter=Pam4UpperThreshold();
            case 'pam_thresholds'
                reservedParameter=PAMThresholds();
            case 'repeater_type'
                reservedParameter=RepeaterType();
            case 'resolve_exists'
                reservedParameter=ResolveExists();
            case 'rx_clock_pdf'
                error(message('serdes:ibis:NotImplemented',parameterNameIn))
            case 'rx_clock_recovery_dcd'
                reservedParameter=RxClockRecoveryDCD();
            case 'rx_clock_recovery_dj'
                reservedParameter=RxClockRecoveryDj();
            case 'rx_clock_recovery_mean'
                reservedParameter=RxClockRecoveryMean();
            case 'rx_clock_recovery_rj'
                reservedParameter=RxClockRecoveryRj();
            case 'rx_clock_recovery_sj'
                reservedParameter=RxClockRecoverySj();
            case 'rx_dcd'
                reservedParameter=RxDCD();
            case 'rx_dj'
                reservedParameter=RxDj();
            case 'rx_noise'
                reservedParameter=RxNoise();
            case 'rx_gaussiannoise'
                reservedParameter=RxGaussianNoise();
            case 'rx_r'
                reservedParameter=Rx_R;
            case 'rx_receiver_sensitivity'
                reservedParameter=RxReceiverSensitivity();
            case 'rx_rj'
                reservedParameter=RxRj();
            case 'rx_sj'
                reservedParameter=RxSj();
            case 'rx_uniformnoise'
                reservedParameter=RxUniformNoise;
            case 'supporting_files'
                reservedParameter=SupportingFiles();
            case 'ts4file'
                reservedParameter=Ts4file;
            case 'tx_dcd'
                reservedParameter=TxDCD();
            case 'tx_dj'
                reservedParameter=TxDj();
            case 'tx_jitter'
                error(message('serdes:ibis:NotImplemented',parameterNameIn))
            case 'tx_rj'
                reservedParameter=TxRj();
            case 'tx_r'
                reservedParameter=Tx_R;
            case 'tx_sj'
                reservedParameter=TxSj();
            case 'tx_sj_frequency'
                reservedParameter=TxSjFrequency();
            case 'tx_v'
                reservedParameter=Tx_V;
            case 'bci_protocol'
                reservedParameter=BCI_Protocol;
            case 'bci_state'
                reservedParameter=BCI_State;
            case 'bci_id'
                reservedParameter=BCI_ID;
            case 'bci_message_interval_ui'
                reservedParameter=BCI_Message_Interval_UI;
            case 'bci_training_ui'
                reservedParameter=BCI_Training_UI;
            case 'rx_use_clock_input'
                reservedParameter=Rx_Use_Clock_Input;
            case 'dc_offset'
                reservedParameter=DC_Offset;
            case 'rx_decision_time'
                reservedParameter=Rx_Decision_Time;
            otherwise
                error(message('serdes:ibis:UnrecognizedItem','Reserved Parameter',parameterNameIn))
            end
        end
    end
end

