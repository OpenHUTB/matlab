classdef(Sealed=true)XCPProtocolConfiguration<matlab.mixin.SetGet







    properties



        HostInterface=struct('value','Simulink','visible',false)
        LoggingBufferAuto=struct('value',false,'visible',false)
        LoggingBufferSize=struct('value','1000','visible',false)
        LoggingBufferNum=struct('value','3','visible',false)
        MaxContigSamples=struct('value','10','visible',false)


MaxDAQ
MinDAQ
MaxEventChannel
MaxCTOSize
MaxDTOSize
MaxODTEntrySize
IdentificationFieldSizeInBytes
TimestampSizeInBytes
WidthOfTargetDoubleInBytes
MaxNumOfODTsWithThirdPartyHost
MaxNumOfODTEntriesWithThirdPartyHost


        IsByteAddressGranularityEmulation=false;
    end

    methods(Access={?codertarget.attributes.ExternalModeInfo})
        function h=XCPProtocolConfiguration(structVal)


            if isstruct(structVal)
                if isfield(structVal,'hostinterface')
                    h.HostInterface=structVal.hostinterface;
                end
                if isfield(structVal,'isloggingbuffersizeautomatic')
                    h.LoggingBufferAuto=structVal.isloggingbuffersizeautomatic;
                elseif isfield(structVal,'loggingbufferauto')
                    h.LoggingBufferAuto=structVal.loggingbufferauto;
                end
                if isfield(structVal,'loggingbuffersize')
                    h.LoggingBufferSize=structVal.loggingbuffersize;
                end
                if isfield(structVal,'loggingbuffernum')
                    h.LoggingBufferNum=structVal.loggingbuffernum;
                end
                if isfield(structVal,'maxcontigsamples')
                    h.MaxContigSamples=structVal.maxcontigsamples;
                end
                if isfield(structVal,'maxdaq')
                    h.MaxDAQ=structVal.maxdaq;
                end
                if isfield(structVal,'mindaq')
                    h.MinDAQ=structVal.mindaq;
                end
                if isfield(structVal,'maxeventchannel')
                    h.MaxEventChannel=structVal.maxeventchannel;
                end
                if isfield(structVal,'maxctosize')
                    h.MaxCTOSize=structVal.maxctosize;
                end
                if isfield(structVal,'maxdtosize')
                    h.MaxDTOSize=structVal.maxdtosize;
                end
                if isfield(structVal,'maxodtentrysize')
                    h.MaxODTEntrySize=structVal.maxodtentrysize;
                end
                if isfield(structVal,'idsize')
                    h.IdentificationFieldSizeInBytes=structVal.idsize;
                end
                if isfield(structVal,'timestampsize')
                    h.TimestampSizeInBytes=structVal.timestampsize;
                end
                if isfield(structVal,'sizeofdouble')
                    h.WidthOfTargetDoubleInBytes=structVal.sizeofdouble;
                end
                if isfield(structVal,'maxodtswith3phost')
                    h.MaxNumOfODTsWithThirdPartyHost=structVal.maxodtswith3phost;
                end
                if isfield(structVal,'maxodtentrieswith3phost')
                    h.MaxNumOfODTEntriesWithThirdPartyHost=structVal.maxodtentrieswith3phost;
                end
                if isfield(structVal,'isbyteaddressgranularityemulation')
                    h.IsByteAddressGranularityEmulation=structVal.isbyteaddressgranularityemulation;
                end
                assert(~isequal(h.LoggingBufferSize.visible,h.LoggingBufferNum.visible),...
                'Visibility of LoggingBufferSize and NumOfLoggingBuffers External Mode widgets cannot be same');
            end
        end
    end




    methods
        function set.HostInterface(obj,val)
            val=obj.refineProtocolSubField(val,'HostInterface');
            validatestring(val.value,obj.getSupportedHostInterfaces(),'','HostInterface');
            obj.HostInterface=val;
        end
        function set.LoggingBufferAuto(obj,val)
            val=obj.refineProtocolSubField(val,'LoggingBufferAuto');
            if~islogical(val.value)
                if ischar(val.value)
                    val.value=~isequal(val.value,'false')&&~isequal(val.value,'0');
                else
                    DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','LoggingBufferAuto');
                end
            end
            obj.LoggingBufferAuto=val;
        end
        function set.LoggingBufferSize(obj,val)
            val=obj.refineProtocolSubField(val,'LoggingBufferSize');
            validateattributes(str2double(val.value),{'numeric'},{'scalar','positive'},'','LoggingBufferSize');
            obj.LoggingBufferSize.value=val.value;
            obj.LoggingBufferSize.visible=val.visible;
        end
        function set.LoggingBufferNum(obj,val)
            val=obj.refineProtocolSubField(val,'LoggingBufferNum');
            validateattributes(str2double(val.value),{'numeric'},{'scalar','positive'},'','LoggingBufferNum');
            obj.LoggingBufferNum.value=val.value;
            obj.LoggingBufferNum.visible=val.visible;
        end
        function set.MaxContigSamples(obj,val)
            val=obj.refineProtocolSubField(val,'MaxContigSamples');
            validateattributes(str2double(val.value),{'numeric'},{'scalar','positive'},'','MaxContigSamples');
            obj.MaxContigSamples.value=val.value;
            obj.MaxContigSamples.visible=val.visible;
        end
        function set.MaxDAQ(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxDAQ');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',0xFFFF},'','MaxDAQ');
            obj.MaxDAQ=val;
        end
        function set.MinDAQ(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MinDAQ');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',0xFF},'','MinDAQ');
            obj.MinDAQ=val;
        end
        function set.MaxEventChannel(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxEventChannel');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',0xFFFF},'','MaxEventChannel');
            obj.MaxEventChannel=val;
        end
        function set.MaxCTOSize(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxCTOSize');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',8,'<=',0xFF},'','MaxCTOSize');
            obj.MaxCTOSize=val;
        end
        function set.MaxDTOSize(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxDTOSize');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',8,'<=',0xFFFF},'','MaxDTOSize');
            obj.MaxDTOSize=val;
        end
        function set.MaxODTEntrySize(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxODTEntrySize');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',0,'<=',0xFF},'','MaxODTEntrySize');
            obj.MaxODTEntrySize=val;
        end
        function set.IdentificationFieldSizeInBytes(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','IdentificationFieldSizeInBytes');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','>=',1,'<=',4},'','IdentificationFieldSizeInBytes');
            obj.IdentificationFieldSizeInBytes=val;
        end
        function set.TimestampSizeInBytes(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','TimestampSizeInBytes');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar'},'','TimestampSizeInBytes');
            if(val~=1)&&(val~=2)&&(val~=4)
                DAStudio.error('codertarget:targetapi:IllegalNumericPropertyArray','TimestampSizeInBytes','1, 2, 4');
            end
            obj.TimestampSizeInBytes=val;
        end
        function set.WidthOfTargetDoubleInBytes(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','WidthOfTargetDoubleInBytes');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar'},'','WidthOfTargetDoubleInBytes');
            if(val~=4)&&(val~=8)
                DAStudio.error('codertarget:targetapi:IllegalNumericPropertyArray','WidthOfTargetDoubleInBytes','4, 8');
            end
            obj.WidthOfTargetDoubleInBytes=val;
        end
        function set.MaxNumOfODTsWithThirdPartyHost(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxNumOfODTsWithThirdPartyHost');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','positive'},'','MaxNumOfODTsWithThirdPartyHost');
            obj.MaxNumOfODTsWithThirdPartyHost=val;
        end
        function set.MaxNumOfODTEntriesWithThirdPartyHost(obj,val)
            validateattributes(val,{'char'},{'scalartext'},'','MaxNumOfODTEntriesWithThirdPartyHost');
            val=str2double(val);
            validateattributes(val,{'numeric'},{'scalar','positive'},'','MaxNumOfODTEntriesWithThirdPartyHost');
            obj.MaxNumOfODTEntriesWithThirdPartyHost=val;
        end
        function set.IsByteAddressGranularityEmulation(obj,val)
            if~islogical(val)
                if ischar(val)
                    val=~isequal(val,'false')&&~isequal(val,'0');
                else
                    DAStudio.error('codertarget:targetapi:InvalidLogicalProperty','IsByteAddressGranularityEmulation');
                end
            end
            obj.IsByteAddressGranularityEmulation=val;
        end
    end

    methods(Access=private,Static)





        function value=refineProtocolSubField(value,name)
            p=isstruct(value)&&isfield(value,'value')&&isfield(value,'visible');
            if~p
                DAStudio.error('codertarget:targetapi:StructureInputInvalid',name,'''value'' and ''visible''');
            end
            if isfield(value,'visible')
                val=value.visible;
                if isempty(val)
                    val=false;
                elseif ischar(val)
                    val=~isequal(val,'false')&&~isequal(val,'0');
                end
                value.visible=val;
            end
        end
    end

    methods(Static)
        function out=getSupportedHostInterfaces()
            out={DAStudio.message('codertarget:ui:ExternalModeSimulinkHostInterface'),...
            DAStudio.message('codertarget:ui:ExternalModeThirdPartyHostInterface')};
        end

        function out=getProtocolConfigurationWidgetNames()
            out={'HostInterface',...
            'LoggingBufferAuto',...
            'LoggingBufferSize',...
            'LoggingBufferNum',...
            'MaxContigSamples'};
        end
    end
end