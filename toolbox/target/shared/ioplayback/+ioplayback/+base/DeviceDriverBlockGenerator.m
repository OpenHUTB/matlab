classdef DeviceDriverBlockGenerator<handle




    properties
HwConstructor
Name
        DeviceClass='Digital Read'
        Logo='Generic'
        SourceFiles={}
        SourcePaths={}
        IncludeFiles={}
        IncludePaths={}
        Libraries={}
        LinkerFlags={}
        Defines={}
        EnableViewPinMapButton=false
ViewPinMapOpenFcn
ViewPinMapCloseFcn
    end

    properties(Constant)
        SupportedPropertyDataTypes={'numeric','string'};

    end

    properties(Access=private,Dependent)
SVDDevice
SVDHeaderFile
    end


    properties(Hidden,Constant)
        AvailableDeviceClasses={...
        'Digital Read',...
        'Digital Write',...
        'Analog Input',...
        'PWM Output',...
        'TCP Read',...
        'TCP Write',...
        'UDP Read',...
        'UDP Write'}
    end


    methods
        function obj=DeviceDriverBlockGenerator(varargin)

            p=inputParser;
            addParameter(p,'HwConstructor','');
            addParameter(p,'Name','');
            addParameter(p,'DeviceClass','Digital Read');
            addParameter(p,'Logo','Generic');
            addParameter(p,'SourceFiles',{});
            addParameter(p,'SourcePaths',{});
            addParameter(p,'IncludeFiles',{});
            addParameter(p,'IncludePaths',{});
            addParameter(p,'Libraries',{});
            addParameter(p,'LinkerFlags',{});
            addParameter(p,'Defines',{});
            addParameter(p,'EnableViewPinMapButton',false);
            addParameter(p,'ViewPinMapOpenFcn','');
            addParameter(p,'ViewPinMapCloseFcn','');
            parse(p,varargin{:});


            obj.HwConstructor=p.Results.HwConstructor;
            obj.Name=p.Results.Name;
            obj.DeviceClass=p.Results.DeviceClass;
            obj.Logo=p.Results.Logo;
            obj.SourceFiles=p.Results.SourceFiles;
            obj.SourcePaths=p.Results.SourcePaths;
            obj.IncludeFiles=p.Results.IncludeFiles;
            obj.IncludePaths=p.Results.IncludePaths;
            obj.Libraries=p.Results.Libraries;
            obj.LinkerFlags=p.Results.LinkerFlags;
            obj.Defines=p.Results.Defines;
            obj.EnableViewPinMapButton=p.Results.EnableViewPinMapButton;
            obj.ViewPinMapOpenFcn=p.Results.ViewPinMapOpenFcn;
            obj.ViewPinMapCloseFcn=p.Results.ViewPinMapCloseFcn;
        end
    end


    methods
        function set.HwConstructor(obj,value)
            validateattributes(value,{'char'},{},...
            '','HwConstructor');
            obj.HwConstructor=value;
        end

        function set.Logo(obj,value)
            validateattributes(value,{'char'},{'nonempty','row'},...
            '','Logo');
            obj.Logo=value;
        end

        function set.DeviceClass(obj,value)
            value=validatestring(value,obj.AvailableDeviceClasses);
            obj.DeviceClass=value;
        end

        function set.SourceFiles(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.SourceFiles=value;
        end

        function set.SourcePaths(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.SourcePaths=value;
        end

        function set.IncludeFiles(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.IncludeFiles=value;
        end

        function set.IncludePaths(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.IncludePaths=value;
        end

        function set.Libraries(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.Libraries=value;
        end

        function set.LinkerFlags(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.LinkerFlags=value;
        end

        function set.Defines(obj,value)
            if~iscell(value)
                error('ioplayback:svd:InputIsNotCellString',...
                'Input must be a cell array of strings.');
            end
            obj.Defines=value;
        end

        function set.EnableViewPinMapButton(obj,value)
            validateattributes(value,{'numeric','logical'},{'scalar','binary'},'','EnableViewPinMapButton');
            obj.EnableViewPinMapButton=value;
        end

        function set.ViewPinMapOpenFcn(obj,value)
            if~isempty(value)
                validateattributes(value,{'char'},{'nonempty','row'},...
                '','ViewPinMapOpenFcn');
            end
            obj.ViewPinMapOpenFcn=strtrim(value);
        end

        function set.ViewPinMapCloseFcn(obj,value)
            if~isempty(value)
                validateattributes(value,{'char'},{'nonempty','row'},...
                '','ViewPinMapCloseFcn');
            end
            obj.ViewPinMapCloseFcn=strtrim(value);
        end

        function ret=get.SVDDevice(obj)
            switch(obj.DeviceClass)
            case 'Digital Write'
                ret='DigitalWrite';
            case 'Digital Read'
                ret='DigitalRead';
            case 'Analog Input'
                ret='AnalogInput';
            case 'PWM Output'
                ret='PWMOutput';
            case 'TCP Read'
                ret='TCPRead';
            case 'TCP Write'
                ret='TCPWrite';
            case 'UDP Read'
                ret='UDPRead';
            case 'UDP Write'
                ret='UDPWrite';
            end
        end

        function ret=get.SVDHeaderFile(obj)
            switch(obj.DeviceClass)
            case{'Digital Read','Digital Write'}
                ret='mw_digitalio.h';
            case 'Analog Input'
                ret='mw_analogin.h';
            case 'PWM Output'
                ret='mw_pwm.h';
            case{'TCP Read','TCP Write'}
                ret='mw_tcp.h';
            case{'UDP Read','UDP Write'}
                ret='mw_udp.h';
            end
        end

        function generateSystemObject(obj,PropertyDataType)

            if nargin<2
                PropertyDataType='numeric';
            else
                PropertyDataType=validatestring(PropertyDataType,obj.SupportedPropertyDataTypes);
            end

            obj.validateHwObject(obj.HwConstructor,obj.DeviceClass);
            switch(obj.DeviceClass)
            case 'Digital Write'
                generateDigitalWrite(obj,PropertyDataType);
            case 'Digital Read'
                generateDigitalRead(obj,PropertyDataType);
            case 'Analog Input'
                generateAnalogInput(obj,PropertyDataType);
            case 'PWM Output'
                generatePWMOutput(obj,PropertyDataType);
            case 'TCP Read'
                generateTCPRead(obj,PropertyDataType);
            case 'TCP Write'
                generateTCPWrite(obj,PropertyDataType);
            case 'UDP Read'
                generateUDPRead(obj,PropertyDataType);
            case 'UDP Write'
                generateUDPWrite(obj,PropertyDataType);
            end
        end
    end

    methods(Access=private)
        function generateDigitalWrite(obj,PropertyDataType)

            s=StringWriter;
            hline='Set the logical value of a digital output pin.';
            s=writeClassdef(obj,s,hline);


            s=generateDigitalIOPinProperties(obj,s,PropertyDataType);


            s=generateDigitalIOConstructor(obj,s);


            s=generateCoderExternalDependency(obj,s);


            s=generateViewPinMapButton(obj,s,'Pin');


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generateDigitalRead(obj,PropertyDataType)


            s=StringWriter;
            hline='Read the logical state of a digital input pin.';
            s=writeClassdef(obj,s,hline);


            s=generateDigitalIOPinProperties(obj,s,PropertyDataType);


            s=generateDigitalIOConstructor(obj,s);


            s=generateCoderExternalDependency(obj,s);


            s=generateViewPinMapButton(obj,s,'Pin');


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generatePWMOutput(obj,PropertyDataType)

            s=StringWriter;
            hline=['%PWMOUT Generate square waveform on the specified analog output pin.',newline,...
            '% The block input controls the duty cycle of the square waveform. An',newline,...
            '% input value of 0 produces a 0 percent duty cycle and an input value',newline,...
            '% of 100 produces a 100 percent duty cycle.',newline,...
            '% Enter the number of the analog output pin. Do not assign the same pin',newline,...
            '% number to multiple blocks within a model.'];
            s=writeClassdef(obj,s,hline);


            s=generatePWMOutputPinProperties(obj,s,PropertyDataType);


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=generateViewPinMapButton(obj,s,'Pin');


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generateAnalogInput(obj,PropertyDataType)

            s=StringWriter;
            hline=['%ANALOGINPUT Measure the voltage of an analog input pin.',newline,'%',newline...
            ,'% The block output emits the voltage as a decimal value (0.0-1.0, minimum to maximum). The maximum voltage is determined by the input reference voltage, VREFH, which defaults to 3.3 volt.',newline,'%',newline...
            ,'% Do not assign the same Pin number to multiple blocks within a model.'];
            s=writeClassdef(obj,s,hline);


            s=generateAnalogInputPinProperties(obj,s,PropertyDataType);

            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end


            if~isempty(hw)&&isprop(hw,'AnalogExternalTriggerType')&&~isempty(hw.AnalogExternalTriggerType)
                s=generateAbstractProperties(obj,s,'ExternalTriggerType','External trigger source',hw.AnalogExternalTriggerType,...
                'isValidAnalogExternalTriggerType','''ioplayback:svd:ExternalTriggerWrongSelection'',''Selected External trigger not available with selected Analog pin''','string','obj.Pin');
            else

                s.addcr('properties (Nontunable)');
                s.addcr(sprintf('%%%s %s','ExternalTriggerType','External trigger source'));
                s.addcr('ExternalTriggerType = '''';');
                s.addcr('end');
            end


            if~isempty(hw)&&isprop(hw,'AnalogEventsID')&&~isempty(hw.AnalogEventsID)
                s=generateAbstractProperties(obj,s,'EventID','Event ID',hw.AnalogEventsID,...
                'isValidAnalogEventsID','''ioplayback:svd:AnalogEventWrongSelection'',''Selected event not available with selected Analog pin''','string','obj.Pin');
            else

                s.addcr('properties (Nontunable)');
                s.addcr(sprintf('%%%s %s','EventID','Event ID'));
                s.addcr('EventID = '''';');
                s.addcr('end');
            end


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=generateViewPinMapButton(obj,s,'Pin');


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end


        function generateTCPRead(obj,~)

            s=StringWriter;
            hline=['Receive TCP/IP packets from another TCP/IP host on an Internet network.',newline...
            ,'% The Data port outputs the received data as a [Nx1] array.',newline...
            ,'% In Server connection mode, set the Local IP port to the listening port of the TCP/IP Server.',newline...
            ,'% In Client connection mode, set the Remote IP address and Remote IP port parameters to the IP address and port number of the sending TCP/IP host, respectively.'];

            s=writeClassdef(obj,s,hline);


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generateTCPWrite(obj,~)

            s=StringWriter;
            hline=['Send TCP/IP packets to another TCP/IP host on an Internet network.',newline...
            ,'% The block accepts a 1-D array of type uint8, int8, uint16, int16, uint32, int32, uint64, int64, single-precision, or double-precision.',newline...
            ,'% In Server connection mode, set the Local IP port parameter to the listening port of the local TCP/IP Server.',newline...
            ,'% In Client connection mode, set the Remote IP address and Remote IP port parameters to the IP address and port number of the receiving TCP/IP host, respectively.',newline];

            s=writeClassdef(obj,s,hline);

            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);%#ok<*NASGU>
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generateUDPRead(obj,~)

            s=StringWriter;
            hline=['Receives UDP packets from another UDP host specified by the Remote IP address.',newline...
            ,'% The block outputs the values received as an [Nx1] array. ',newline...
            ,'% The sending UDP host must send UDP packets from the Remote IP Address to the Local IP port specified.',newline];

            s=writeClassdef(obj,s,hline);


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end

        function generateUDPWrite(obj,~)

            s=StringWriter;
            hline=['Send UDP packets to another UDP host.',newline...
            ,'% The block accepts a 1-D array of type uint8, int8, uint16, int16, uint32, int32, single or double. ',newline...
            ,'% Set the Remote IP address and Remote IP port parameters to the IP address and port number of the receiving UDP host, respectively. ',newline...
            ,'% Set the Local IP Port parameter to the desired local port to be used.',newline];

            s=writeClassdef(obj,s,hline);

            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end


            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);
            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end
            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;


            s=generateCoderExternalDependency(obj,s);


            s=finalizeClassdef(obj,s);


            s.indentCode;
            s.write([obj.SVDDevice,'.m']);
        end


        function s=writeClassdef(obj,s,hline,BaseClass)
            if nargin<4
                BaseClass=['ioplayback.base.',obj.SVDDevice];
            end

            s.addcr(['classdef ',obj.SVDDevice,' < ',BaseClass,' ...']);
            s.addcr('& coder.ExternalDependency');
            s.addcr(['%',upper(obj.SVDDevice),' ',hline]);
            s.addcr('');
            s.addcr('%#codegen');
            s.addcr('');
        end

        function s=generateDigitalIOConstructor(obj,s)

            s.addcr('methods');
            s.addcr(['function obj = ',obj.SVDDevice,'(varargin)']);
            s.addcr('coder.allowpcode(''plain'');');




            addIncludeFiles(obj,s);

            if~isempty(obj.HwConstructor)
                s.addcr(['obj.Hw = ',obj.HwConstructor,';']);
            end

            s.addcr(['obj.Logo = ''',obj.Logo,''';']);
            s.addcr('setProperties(obj,nargin,varargin{:});');
            s.addcr('end');
            s.addcr('end');
            s.addcr;
        end

        function s=finalizeClassdef(~,s)
            s.addcr('end');
            s.addcr('%[EOF]');
        end

        function s=generateCoderExternalDependency(obj,s)
            s.addcr('methods (Static)');
            s.addcr('function name = getDescriptiveName(~)');
            s.addcr(['    name = ''',obj.DeviceClass,''';']);
            s.addcr('end');
            s.addcr('');
            s.addcr('function b = isSupportedContext(context)');
            s.addcr('    b = context.isCodeGenTarget(''rtw'') || context.isCodeGenTarget(''sfun'');');
            s.addcr('end');
            s.addcr('');
            s.addcr('function updateBuildInfo(buildInfo, context)');
            s.addcr('if context.isCodeGenTarget(''rtw'') || context.isCodeGenTarget(''sfun'')');
            s.addcr('    svdDir = ioplayback.base.getRootDir;');
            s.addcr('    addIncludePaths(buildInfo,fullfile(svdDir,''include''));');
            s.addcr(['   addIncludeFiles(buildInfo,''',obj.SVDHeaderFile,''');']);


            for i=1:numel(obj.SourceFiles)
                [p,f]=obj.getStringPath(obj.SourceFiles{i});
                s.addcr(['addSourceFiles(buildInfo,''',f,''',',p,',''SkipForSil'');']);
            end

            for i=1:numel(obj.SourcePaths)
                p=obj.getStringPath(obj.SourcePaths{i});
                s.addcr(['addSourcePaths(buildInfo,',p,',''SkipForSil'');']);
            end

            for i=1:numel(obj.IncludePaths)
                p=obj.getStringPath(obj.IncludePaths{i});
                s.addcr(['addIncludePaths(buildInfo,',p,',''SkipForSil'');']);
            end

            for k=1:numel(obj.Libraries)
                [p,f]=obj.getStringPath(obj.Libraries{i});
                s.addcr(['addLinkObjects(buildInfo,''',f,''', ',p,', 1000, true, true);']);
            end

            for k=1:numel(obj.IncludeFiles)
                s.addcr(['addIncludeFiles(buildInfo,''',obj.IncludeFiles{k},''');']);
            end
            for k=1:numel(obj.LinkerFlags)
                s.addcr(['addLinkFlags(buildInfo,''',obj.LinkerFlags{k},''');']);
            end
            for k=1:numel(obj.Defines)
                s.addcr(['addDefines(buildInfo,''',obj.Defines{k},''');']);
            end
            s.addcr('end');
            s.addcr('end');
            s.addcr('end');
        end


        function s=generateDigitalIOPinProperties(obj,s,pinDataType)
            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end

            if~isempty(obj.HwConstructor)
                if isequal(pinDataType,'numeric')
                    pins=getDigitalPinNumber(hw);
                else
                    pins=getDigitalPinName(hw);
                end
            else
                if isequal(pinDataType,'numeric')
                    pins=1;
                else
                    pins={'1'};
                end
            end


            s=generatePinProperties(obj,s,pins,'isValidDigitalPin',pinDataType);
        end


        function s=generatePWMOutputPinProperties(obj,s,pinDataType)
            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end

            if~isempty(obj.HwConstructor)
                if isequal(pinDataType,'numeric')
                    pins=getPWMPinNumber(hw);
                else
                    pins=getPWMPinName(hw);
                end
            else
                if isequal(pinDataType,'numeric')
                    pins=1;
                else
                    pins={'1'};
                end
            end


            s=generatePinProperties(obj,s,pins,'isValidPWMPin',pinDataType);


            if~isempty(hw)&&isprop(hw,'PWMSyncs')&&~isempty(hw.PWMSyncs)
                s=generateAbstractProperties(obj,s,'PWMSync','Synchronization',hw.PWMSyncs,...
                '','''ioplayback:svd:PWMSyncWrongSelection'',''Selected PWM Sync not available with selected PWM pin''','string','obj.Pin');
            else

                s.addcr('properties (Nontunable)');
                s.addcr(sprintf('%%%s %s','PWMSync','Synchronization'));
                s.addcr('PWMSync = '''';');
                s.addcr('end');
            end
        end


        function s=generateAnalogInputPinProperties(obj,s,pinDataType)
            if~isempty(obj.HwConstructor)
                try
                    hw=feval(obj.HwConstructor);
                catch ME
                    baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                    'Error while construction a hardware object.');
                    EX=addCause(baseME,ME);
                    throw(EX);
                end
            else
                hw=[];
            end

            if~isempty(obj.HwConstructor)
                if isequal(pinDataType,'numeric')
                    pins=getAnalogPinNumber(hw);
                else
                    pins=getAnalogPinName(hw);
                end
            else
                if isequal(pinDataType,'numeric')
                    pins=1;
                else
                    pins={'1'};
                end
            end


            s=generatePinProperties(obj,s,pins,'isValidAnalogPin',pinDataType);
        end


        function s=generatePinProperties(obj,s,pins,pinValidateFcnName,pinDataType)

            s.addcr('properties (Nontunable)');
            s.addcr('%Pin Pin');
            if~isempty(obj.HwConstructor)
                if isequal(pinDataType,'numeric')
                    s.addcr(['Pin = ',num2str(pins(1)),';']);
                else
                    s.addcr(['Pin = ''',pins{1},''';']);
                end
            else
                if isequal(pinDataType,'numeric')
                    s.addcr('Pin = 1;');
                else
                    s.addcr('Pin = ''1'';');
                end
            end
            s.addcr('end');

            if isequal(pinDataType,'string')&&~isempty(obj.HwConstructor)

                s.addcr('properties (Constant, Hidden)');
                s.addcr(['PinSet = matlab.system.StringSet(',obj.convertCell2String(pins),')']);
                s.addcr('end');
            end


            s.addcr('methods');
            s.addcr('function set.Pin(obj,value)');
            s.addcr('if ioplayback.base.target');
            s.addcr('if ~isempty(obj.Hw)');
            s.addcr(['if ~',pinValidateFcnName,'(obj.Hw,value)']);%#ok<*MCSUP>
            s.addcr(['error(message(''ioplayback:svd:PinNotFound'',value,''',obj.DeviceClass,'''));']);
            s.addcr('end');
            s.addcr('end');
            s.addcr('end');
            if~isequal(pinDataType,'numeric')
                s.addcr('obj.Pin = value;');
            else
                s.addcr('obj.Pin = uint32(value);');
            end
            s.addcr('end');
            s.addcr('end');
        end


        function s=generateAbstractProperties(obj,s,PropertyName,PropertyDescription,PropertyValues,PropertyValidateFcn,ErrorMessage,PropertyDataType,ValidateFcnArgStr)
            if nargin<=8
                ValidateFcnArgStr=[];
            else
                ValidateFcnArgStr=[',',ValidateFcnArgStr];
            end

            if~ischar(PropertyName)
                error('ioplayback:svd:InvalidPropertyName',...
                'PropertyName should be a valid string representing abstract property.');
            end
            if~ischar(PropertyDescription)
                error('ioplayback:svd:InvalidPropertyDescription',...
                'PropertyDescription should be a valid string describing PropertyName.');
            end
            if~ischar(PropertyValidateFcn)
                error('ioplayback:svd:InvalidPropertyValidateFcn',...
                'PropertyValidateFcn should be a valid function name for validating PropertyName.');
            end


            s.addcr('properties (Nontunable)');
            s.addcr(sprintf('%%%s %s',PropertyName,PropertyDescription));
            if~isempty(obj.HwConstructor)
                if isequal(PropertyDataType,'numeric')
                    s.addcr([PropertyName,' = ',num2str(PropertyValues(1)),';']);
                else
                    s.addcr([PropertyName,' = ''',PropertyValues{1},''';']);
                end
            else
                if isequal(PropertyDataType,'numeric')
                    s.addcr([PropertyName,' = 1;']);
                else
                    s.addcr([PropertyName,' = ''1'';']);
                end
            end
            s.addcr('end');

            if isequal(PropertyDataType,'string')&&~isempty(obj.HwConstructor)&&~isempty(PropertyValues)

                s.addcr('properties (Constant, Hidden)');
                s.addcr([PropertyName,'Set = matlab.system.StringSet(',obj.convertCell2String(PropertyValues),')']);
                s.addcr('end');
            end


            if~isempty(PropertyValidateFcn)
                s.addcr('methods');
                s.addcr(['function set.',PropertyName,'(obj,value)']);
                s.addcr('if ioplayback.base.target');
                s.addcr('if ~isempty(obj.Hw)');
                s.addcr(['if ~',PropertyValidateFcn,'(obj.Hw',ValidateFcnArgStr,',value)']);%#ok<*MCSUP>
                s.addcr(['error(',ErrorMessage,');']);
                s.addcr('end');
                s.addcr('end');
                s.addcr('end');

                if~isequal(PropertyDataType,'numeric')
                    s.addcr(['obj.',PropertyName,' = value;']);
                else
                    s.addcr(['obj.',PropertyName,' = uint32(value);']);
                end
                s.addcr('end');
                s.addcr('end');
            end


            s.addcr('');
        end












        function s=generateViewPinMapButton(obj,s,propName,addMethod,addMethodValue)

            if nargin>3
                if isequal(addMethod,'-inherit')
                    if~isnumeric(addMethodValue)
                        error(message('ioplayback:svd:GenViewPinMapButtonIdxError'));
                    end
                    CreateFunction=true;
                elseif isequal(addMethod,'-append')
                    if~ischar(addMethodValue)
                        error(message('ioplayback:svd:GenViewPinMapButtonNameError'));
                    end
                    CreateFunction=false;
                else
                    error(message('ioplayback:svd:GenViewPinMapButtonInvalidArg'));
                end
            else
                addMethod=[];
                addMethodValue=[];
                CreateFunction=true;
            end

            if obj.EnableViewPinMapButton&&~isempty(obj.ViewPinMapOpenFcn)


                if CreateFunction
                    s.addcr('methods (Static, Access=protected)');
                    s.addcr('function group = getPropertyGroupsImpl')
                end

                if isempty(addMethod)
                    s.addcr('group = matlab.system.display.Section(mfilename(''class''));');
                elseif isequal(addMethod,'-inherit')
                    s.addcr(['group = ioplayback.base.',obj.SVDDevice,'.getPropertyGroupsImpl;']);
                else

                end


                s.addcr(['viewPinMapAction = matlab.system.display.Action(@',obj.ViewPinMapOpenFcn,', ...']);
                s.addcr('''Alignment'', ''right'', ...');
                s.addcr(['''Placement'',''',propName,''',...']);
                s.addcr('''Label'', ''View pin map'');');
                if~isempty(obj.ViewPinMapCloseFcn)
                    s.addcr('matlab.system.display.internal.setCallbacks(viewPinMapAction, ...');

                    s.addcr(['''SystemDeletedFcn'', @',obj.ViewPinMapCloseFcn,');']);
                end

                if isempty(addMethod)
                    s.addcr('group.Actions = viewPinMapAction;');
                elseif isequal(addMethod,'-inherit')
                    s.addcr(['group(',num2str(addMethodValue),').Actions = viewPinMapAction;']);
                else
                    s.addcr([addMethodValue,'.Actions = viewPinMapAction;']);
                end


                if CreateFunction
                    s.addcr('end');
                    s.addcr('end');
                end
            end
        end

        function s=addIncludeFiles(obj,s)
            if isempty(obj.IncludeFiles)
                return;
            end
            s.addcr('if ~ioplayback.base.target');
            for k=1:numel(obj.IncludeFiles)
                s.addcr(['coder.cinclude(''',obj.IncludeFiles{k},''');']);
            end
            s.addcr('end');
        end
    end


    methods(Access=public,Static=true)
        function validateHwObject(hwConstructor,DeviceClass)

            if isempty(hwConstructor)
                return;
            end

            DeviceClass=convertStringsToChars(DeviceClass);
            validatestring(DeviceClass,ioplayback.base.DeviceDriverBlockGenerator.AvailableDeviceClasses);


            try
                hw=feval(hwConstructor);
            catch ME
                baseME=MException('ioplayback:svd:InvalidHwObjectConstructor',...
                'Error while construction a hardware object.');
                EX=addCause(baseME,ME);
                throw(EX);
            end


            switch(DeviceClass)
            case{'Digital Read',...
                'Digital Write',...
                }
                ioplayback.base.DeviceDriverBlockGenerator.validateDigitalIOHardwareDetails(hw);
            end


            switch(DeviceClass)
            case 'Analog Input'
                ioplayback.base.DeviceDriverBlockGenerator.validateAnalogInputHardwareDetails(hw);
            end


            switch(DeviceClass)
            case 'PWM Output'
                ioplayback.base.DeviceDriverBlockGenerator.validatePWMHardwareDetails(hw);
            end
        end

        function CellString=convertCell2String(CellArray)
            if~iscell(CellArray)
                error('Input should be a cell array of strings.');
            end

            CellString='{';
            for i=1:numel(CellArray)

                CellString=[CellString,'''',CellArray{i},'''',','];%#ok<AGROW>
            end
            CellString(end)='}';
        end
    end

    methods(Static=true,Hidden)
        function[Fpath,Name]=getStringPath(FilePath)

            FilePath=ioplayback.base.DeviceDriverBlockGenerator.resolveEnvironmentVariable(FilePath);


            [p,f,e]=fileparts(FilePath);
            if isempty(e)||~ismember(strtrim(e),ioplayback.base.DeviceDriverBlockGenerator.allowedFileExtension())
                p=FilePath;
                f='';
                e='';
            end


            ms=regexp(p,'^\s*matlab\s*:','once');
            if~isempty(ms)
                p=regexprep(p,'^\s*matlab\s*:','');
                if ispc
                    ind=find(p=='/'|p=='\',1,'first');
                else
                    ind=find(p=='/',1,'first');
                end
                if~isempty(ind)
                    p=sprintf('fullfile(%s,''%s'')',p(1:ind-1),p(ind+1:end));
                end
            else
                p=['''',p,''''];
            end

            Fpath=p;
            Name=[f,e];
        end

        function FileExts=allowedFileExtension()
            FileExts={'.c','.cpp','.h','.hpp','.o','.obj','.lib','.a','.s','.S','.cc','.C','.so','.elf','.out'};
        end

        function FilePath=resolveEnvironmentVariable(FilePath)

            FilePath=strtrim(FilePath);
            [Tokens,MatchTokens]=regexp(FilePath,'\$\((?<name>.*?)\)','names','match');
            if~isempty(Tokens)
                for i=1:numel(Tokens)
                    Env=getenv(Tokens(i).name);
                    if~isempty(Env)
                        FilePath=strrep(FilePath,MatchTokens{i},Env);
                    end
                end
            end
        end

        function validateCellArray(ArgValues,ArgName)

            if~isempty(ArgValues)
                if~iscell(ArgValues)
                    error('ioplayback:svd:InvalidTypeCell',...
                    [ArgName,' property of the hardware object must ',...
                    'be a cell array of strings.']);
                else

                    if~all(cellfun(@ischar,ArgValues))
                        error('ioplayback:svd:InvalidTypeForPin',...
                        [ArgName,' property of the hardware object must ',...
                        'be a cell array of strings. ',...
                        'Some of the elements in the returned cell array are not a string.'])
                    end


                    if all(cellfun(@(x)isempty(strtrim(x)),ArgValues))
                        error('ioplayback:svd:InvalidTypeForPin',...
                        [ArgName,' property of the hardware object must ',...
                        'be a cell array of strings. ',...
                        'Some of the elements in the cell array are empty.'])
                    end

                    ArgValues_spaces=regexp(ArgValues,'[^\w_]','once');
                    if~all(cellfun(@isempty,ArgValues_spaces))
                        error('ioplayback:svd:InvalidTypeForPin',...
                        [ArgValues,' property of the hardware object must ',...
                        'be a cell array of strings. ',...
                        'The names should contain only characters within [A-Za-z0-9_].'])%#ok<PFCEL>
                    end
                end
            end
        end

        function validateDigitalIOHardwareDetails(hw)

            pinNumbers=getDigitalPinNumber(hw);
            try
                validateattributes(pinNumbers,...
                {'numeric'},{'integer','vector'});
            catch ME
                baseME=MException('ioplayback:svd:InvalidTypeForPin',...
                ['getDigitalPinNumber method of the hardware object must ',...
                'return a numeric vector ',...
                'representing pin numbers available for digital I/O.']);
                EX=addCause(baseME,ME);
                throw(EX);
            end


            pinNames=getDigitalPinName(hw);
            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(pinNames,'AvailableDigitalPinsName');

            if~all(size(pinNames)==size(pinNumbers))
                error('ioplayback:svd:InvalidTypeForPin',...
                ['getDigitalPinName method of the hardware object must ',...
                'return a cell array with the same size as the numeric ',...
                'array returned by getDigitalPinNumber.'])
            end
            for k=1:numel(pinNumbers)
                tmpName=getDigitalPinName(hw,pinNumbers(k));
                if~ismember(tmpName,pinNames)
                    error('ioplayback:svd:InvalidPinName',...
                    ['The pin name, %s, returned for pin number %d ',...
                    ' is not in the cell array getDigitalPinName ',...
                    'method of the hardware object.'],tmpName,uint32(pinNumbers(k)));
                end
                tmpNumber=getDigitalPinNumber(hw,tmpName);
                if tmpNumber~=pinNumbers(k)
                    error('ioplayback:svd:InvalidPinNumber',...
                    ['The pin number, %d, returned for pin named %s ',...
                    ' is not in array getDigitalPinNumber ',...
                    'method of the hardware object.'],tmpNumber,tmpName);
                end
            end
        end

        function validateAnalogInputHardwareDetails(hw)

            pinNumbers=getAnalogPinNumber(hw);
            try
                validateattributes(pinNumbers,...
                {'numeric'},{'integer','vector'});
            catch ME
                baseME=MException('ioplayback:svd:InvalidTypeForPin',...
                ['getAnalogPinNumber method of the hardware object must ',...
                'return a numeric vector ',...
                'representing pin numbers available for analog output.']);
                EX=addCause(baseME,ME);
                throw(EX);
            end

            pinNames=getAnalogPinName(hw);
            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(pinNames,'AvailableAnalogPinsName');
            if~all(size(pinNames)==size(pinNumbers))
                error('ioplayback:svd:InvalidTypeForPin',...
                ['getAnalogPinName method of the hardware object must ',...
                'return a cell array with the same size as the numeric ',...
                'array returned by getAnalogPinNumber.'])
            end
            for k=1:numel(pinNumbers)
                tmpName=getAnalogPinName(hw,pinNumbers(k));
                if~ismember(tmpName,pinNames)
                    error('ioplayback:svd:InvalidPinName',...
                    ['The pin name, %s, returned for pin number %d ',...
                    ' is not in the cell array getAnalogPinName ',...
                    'method of the hardware object.'],tmpName,uint32(pinNumbers(k)));
                end
                tmpNumber=getAnalogPinNumber(hw,tmpName);
                if tmpNumber~=pinNumbers(k)
                    error('ioplayback:svd:InvalidPinNumber',...
                    ['The pin number, %d, returned for pin named %s ',...
                    ' is not in array getAnalogPinNumber ',...
                    'method of the hardware object.'],tmpNumber,tmpName);
                end
            end



            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(hw.AnalogExternalTriggerType,'AnalogExternalTriggerType');


            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(hw.AnalogEventsID,'AnalogEventsID');
        end

        function validatePWMHardwareDetails(hw)
            pinNumbers=getPWMPinNumber(hw);
            try
                validateattributes(pinNumbers,...
                {'numeric'},{'integer','vector'});
            catch ME
                baseME=MException('ioplayback:svd:InvalidTypeForPin',...
                ['getPWMPinNumber method of the hardware object must ',...
                'return a numeric vector ',...
                'representing pin numbers available for PWM.']);
                EX=addCause(baseME,ME);
                throw(EX);
            end

            pinNames=getPWMPinName(hw);
            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(pinNames,'AvailablePWMPinsName');
            if~all(size(pinNames)==size(pinNumbers))
                error('ioplayback:svd:InvalidTypeForPin',...
                ['getPWMPinName method of the hardware object must ',...
                'return a cell array with the same size as the numeric ',...
                'array returned by getPWMPinNumber.'])
            end
            for k=1:numel(pinNumbers)
                tmpName=getPWMPinName(hw,pinNumbers(k));
                if~ismember(tmpName,pinNames)
                    error('ioplayback:svd:InvalidPinName',...
                    ['The pin name, %s, returned for pin number %d ',...
                    ' is not in the cell array getPWMPinName ',...
                    'method of the hardware object.'],tmpName,uint32(pinNumbers(k)));
                end
                tmpNumber=getPWMPinNumber(hw,tmpName);
                if tmpNumber~=pinNumbers(k)
                    error('ioplayback:svd:InvalidPinNumber',...
                    ['The pin number, %d, returned for pin named %s ',...
                    ' is not in array getPWMPinNumber ',...
                    'method of the hardware object.'],tmpNumber,tmpName);
                end
            end


            MinimumFreq=getMinimumPWMFrequency(hw);
            validateattributes(MinimumFreq,{'numeric'},{'scalar','real','nonnegative','finite','nonnan'},'','Minimum PWM frequency');
            MaximumFreq=getMaximumPWMFrequency(hw);
            validateattributes(MaximumFreq,{'numeric'},{'scalar','real','nonnegative','finite','nonnan'},'','Maximum PWM frequency')
            if MaximumFreq<=MinimumFreq
                error('ioplayback:svd:InvalidPWMFreqRange','Maximum allowed PWM frequency is less than the minimum allowed PWM frequency.');
            end


            ioplayback.base.DeviceDriverBlockGenerator.validateCellArray(pinNames,'PWMSyncs');
        end
    end
end




