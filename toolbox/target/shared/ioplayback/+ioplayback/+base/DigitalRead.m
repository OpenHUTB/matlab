classdef DigitalRead<ioplayback.base.BlockSampleTime&...
    ioplayback.system.mixin.Event





%#codegen
    properties(Hidden,Nontunable)
        Logo='Generic'
    end

    properties(Hidden)
Hw
    end

    properties(Abstract,Nontunable)

Pin
    end

    properties(Access=protected)
        MW_DIGITALIO_HANDLE;
    end

    properties(Hidden,Nontunable)
        DataType='logical'
        DataSize=[1,1]

    end

    properties(Dependent,Hidden,Nontunable)
EventID
    end

    properties(Access=private)
        EventTick=0;
    end


    methods
        function ret=get.EventID(obj)
            if isnumeric(obj.Pin)
                ret=coder.const(['DIGITALREAD_',str2double(obj.Pin)]);
            else
                ret=coder.const(['DIGITALREAD_',obj.Pin]);
            end
        end
    end

    methods
        function obj=DigitalRead(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
            obj.DataTypeWarningasError=0;
        end

        function open(obj)
            if coder.target('Rtw')

                coder.cinclude('mw_digitalio.h');
                obj.MW_DIGITALIO_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if isnumeric(obj.Pin)
                    obj.MW_DIGITALIO_HANDLE=coder.ceval('MW_DigitalIO_Open',obj.Pin,SVDTypes.MW_Input);
                else
                    pinname=coder.opaque('uint32_T',obj.Pin);
                    obj.MW_DIGITALIO_HANDLE=coder.ceval('MW_DigitalIO_Open',pinname,SVDTypes.MW_Input);
                end
            else
                obj.MW_DIGITALIO_HANDLE=coder.nullcopy(0);

                if isempty(obj.Pin)
                    error('ioplayback:svd:EmptyPin',...
                    ['The property Pin is not defined. You must set Pin ',...
                    'to a valid value.'])
                end
            end
        end

        function y=readDigitalPin(obj,varargin)
            y=coder.nullcopy(false);
            if ioplayback.base.target

                if isequal(obj.SimulationOutput,'From input port')
                    y=logical(varargin{1});

                elseif isequal(obj.SimulationOutput,'Zeros')
                    y=false;
                elseif isequal(obj.SimulationOutput,'From recorded file')

                else

                end
            elseif coder.target('Rtw')

                y=coder.ceval('MW_DigitalIO_Read',obj.MW_DIGITALIO_HANDLE);
            end
        end

        function close(obj)
            if coder.target('Rtw')

                coder.ceval('MW_DigitalIO_Close',obj.MW_DIGITALIO_HANDLE);
            else

            end
        end
    end


    methods
        function configSource(obj,hwObjHandle)
            configurePin(hwObjHandle,obj.Pin,'DigitalInput');
        end

        function configStreaming(obj,hwObjHandle)
            readDigitalPin(hwObjHandle,obj.Pin);
            setRate(hwObjHandle,obj.SampleTime);
        end
    end


    methods(Hidden)



        function event=getNextEvent(obj,EventID,~)
            if isequal(obj.SimulationOutput,'From input port')||isequal(obj.SimulationOutput,'Zeros')

                event=[];
                return;
            else

                event.ID=EventID;
                if obj.SampleTime>0

                    event.Time=obj.SampleTime*obj.EventTick;
                else



                    event.Time=obj.RecordedSampleTime*(obj.EventTick+1);
                end
                obj.EventTick=obj.EventTick+1;
            end
        end
    end


    methods

        function checkDataFile(obj,dataFile)%#ok<INUSD>
            if isempty(coder.target)





            end
        end
    end


    methods(Access=protected)
        function setupImpl(obj)
            if ioplayback.base.target

                if~isequal(obj.SimulationOutput,'From input port')

                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='Digital_Read';
                    obj.SignalInfo.Dimensions=[obj.DataSize(1),obj.DataSize(2)];
                    obj.SignalInfo.DataType='uint8';
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SourceSystem(obj);
                    if isequal(obj.SimulationOutput,'From recorded file')
                        setup(obj.Reader,1);
                    end
                end
                try %#ok<EMTC>
                    events=struct('EventID',obj.EventID,...
                    'CommType','pull','TaskFcnPollCmd','');
                    soc.registerBlock(obj,events);
                catch ME
                    disp(ME.message)
                end
            else
                open(obj);
            end
        end

        function varargout=stepImpl(obj,varargin)
            if ioplayback.base.target
                if~isequal(obj.SimulationOutput,'From input port')
                    varargout{1}=logical(stepImpl@ioplayback.SourceSystem(obj));
                else
                    varargout{1}=readDigitalPin(obj,varargin{1});
                end
            else
                varargout{1}=readDigitalPin(obj);
            end
        end

        function releaseImpl(obj)
            if ioplayback.base.target
                if~isequal(obj.SimulationOutput,'From input port')
                    releaseImpl@ioplayback.SourceSystem(obj);
                end
            else
                close(obj);
            end
        end

        function sts=getSampleTimeImpl(obj)
            sts=getSampleTimeImpl@ioplayback.base.BlockSampleTime(obj);
        end
    end


    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            if~isequal(obj.SimulationOutput,'From input port')
                num=0;
            else
                num=1;
            end
        end

        function num=getNumOutputsImpl(~)
            num=1;
        end
    end


    methods(Access=protected)
        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function validateInputsImpl(obj,varargin)
            if ioplayback.base.target

                if isequal(obj.SimulationOutput,'From input port')
                    validateattributes(varargin{1},{'logical','numeric'},...
                    {'scalar','binary'},'','input');
                end
            end
        end
    end


    methods(Access=protected)
        function varargout=isOutputFixedSizeImpl(~,~)
            varargout{1}=true;
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=obj.DataSize;
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout{1}=obj.DataType;
        end
    end


    methods(Access=protected)
        function maskDisplayCmds=getMaskDisplayImpl(obj)
            x=1:22;
            y=double(abs(0:1/10:1)>=0.5);
            y=[y,flip(y)];
            x=[x(1:5),5.999,x(6:17),17.001,x(18:end)]+28;
            y=[y(1:5),0,y(6:17),0,y(18:end)]*45+30;
            x=[x,x+21];
            y=[y,y];
            maskDisplayCmds=[...
            ['color(''white'');',newline]...
            ,['plot([100,100,100,100],[100,100,100,100]);',newline]...
            ,['plot([0,0,0,0],[0,0,0,0]);',newline]...
            ,['color(''blue'');',newline]...
            ,['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');',newline]...
            ,['color(''black'');',newline]...
            ,['plot([',num2str(x),'],[',num2str(y),']);',newline],...
            ['text(50, 15, ''Pin: ',num2str(obj.Pin),''' ,''horizontalAlignment'', ''center'');',newline],...
            ];
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl()
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','Digital Read',...
            'Text',[['Read the logical state of a digital input pin.',newline,newline]...
            ,'Do not assign the same Pin number to multiple blocks within a model.']);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            PinProp=matlab.system.display.internal.Property('Pin','Description','Pin');

            SampleTimeProp=matlab.system.display.internal.Property('SampleTime','Description','Sample time');

            PropertyListOut={PinProp,SampleTimeProp};


            GroupSimulation=ioplayback.SourceSystem.getPropertyGroupsList;


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
        function simMode=getSimulateUsingImpl(~)
            simMode='Interpreted execution';
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end
end

