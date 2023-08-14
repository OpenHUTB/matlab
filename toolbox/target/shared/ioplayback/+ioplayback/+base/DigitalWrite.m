classdef DigitalWrite<ioplayback.SinkSystem





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
        DataTypeWarningasError=0
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
                ret=coder.const(['DIGITALWRITE_',str2double(obj.Pin)]);
            else
                ret=coder.const(['DIGITALWRITE_',obj.Pin]);
            end
        end
    end

    methods
        function obj=DigitalWrite(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end

        function open(obj)
            if ioplayback.base.target
                obj.MW_DIGITALIO_HANDLE=coder.nullcopy(0);

                if isempty(obj.Pin)
                    error('ioplayback:svd:EmptyPin',...
                    ['The property Pin is not defined. You must set Pin ',...
                    'to a valid value.'])
                end
            else

                coder.cinclude('mw_digitalio.h');
                obj.MW_DIGITALIO_HANDLE=coder.opaque('MW_VoidPtr_T','HeaderFile','mw_driver_basetypes.h');
                if isnumeric(obj.Pin)
                    obj.MW_DIGITALIO_HANDLE=coder.ceval('MW_DigitalIO_Open',obj.Pin,SVDTypes.MW_Output);
                else
                    pinname=coder.opaque('uint32_T',obj.Pin);
                    obj.MW_DIGITALIO_HANDLE=coder.ceval('MW_DigitalIO_Open',pinname,SVDTypes.MW_Output);
                end
            end
        end

        function varargout=writeDigitalPin(obj,PinStatus)
            pinStatus=logical(PinStatus);

            if ioplayback.base.target
                SimOut=coder.nullcopy(false);

                if isequal(obj.SendSimulationInputTo,'Output port')
                    SimOut=pinStatus;

                elseif isequal(obj.SendSimulationInputTo,'Terminator')

                elseif isequal(obj.SendSimulationInputTo,'Data file')

                else

                end

                if nargout>0
                    varargout{1}=SimOut;
                end
            else

                coder.ceval('MW_DigitalIO_Write',obj.MW_DIGITALIO_HANDLE,pinStatus);
            end
        end

        function close(obj)
            if ioplayback.base.target

            else

                coder.ceval('MW_DigitalIO_Close',obj.MW_DIGITALIO_HANDLE);
            end
        end
    end


    methods(Hidden)



        function event=getNextEvent(obj,EventID,~)
            if isequal(obj.SendSimulationInputTo,'From input port')||isequal(obj.SendSimulationInputTo,'Zeros')

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


    methods(Access=protected)
        function setupImpl(obj)
            if ioplayback.base.target

                if~isequal(obj.SendSimulationInputTo,'Output port')
                    obj.DataFileFormat='TimeStamp';
                    obj.SignalInfo.Name='Digital_Write';
                    obj.SignalInfo.Dimensions=[obj.DataSize(1),obj.DataSize(2)];
                    obj.SignalInfo.DataType='uint8';
                    obj.SignalInfo.IsComplex=false;
                    setupImpl@ioplayback.SinkSystem(obj);
                end







            else
                open(obj);
            end
        end

        function varargout=stepImpl(obj,varargin)
            SimOut=false;
            if ioplayback.base.target
                if~isequal(obj.SendSimulationInputTo,'Output port')
                    stepImpl@ioplayback.SinkSystem(obj,uint8(logical(varargin{1})));
                else
                    SimOut=writeDigitalPin(obj,varargin{1});
                end
            else
                writeDigitalPin(obj,varargin{1});
            end

            if nargout>0
                varargout{1}=SimOut;
            end
        end

        function releaseImpl(obj)
            if ioplayback.base.target
                if~isequal(obj.SendSimulationInputTo,'Output port')
                    releaseImpl@ioplayback.SinkSystem(obj);
                end
            else
                close(obj);
            end
        end
    end


    methods(Access=protected)
        function num=getNumInputsImpl(~)
            num=1;
        end

        function num=getNumOutputsImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                num=1;
            else
                num=0;
            end
        end
    end


    methods(Access=protected)
        function flag=isInputSizeMutableImpl(~,~)
            flag=false;
        end

        function flag=isInputComplexityMutableImpl(~,~)
            flag=false;
        end

        function validateInputsImpl(~,varargin)

        end
    end


    methods(Access=protected)
        function varargout=isOutputFixedSizeImpl(~,~)
            varargout{1}=true;
        end

        function varargout=isOutputComplexImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                if ioplayback.base.target
                    varargout{1}=false;
                end
            end
        end

        function varargout=getOutputSizeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=obj.DataSize;
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            if isequal(obj.SendSimulationInputTo,'Output port')
                varargout{1}=obj.DataType;
            end
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
            'Title','Digital Write',...
            'Text',[['Set the logical state of a digital output pin.',newline,newline]...
            ,'Do not assign the same Pin number to multiple blocks within a model.']);
        end

        function[groups,PropertyList]=getPropertyGroupsImpl

            PinProp=matlab.system.display.internal.Property('Pin','Description','Pin');

            PropertyListOut={PinProp};


            GroupSimulation=ioplayback.SinkSystem.getPropertyGroupsList;


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
