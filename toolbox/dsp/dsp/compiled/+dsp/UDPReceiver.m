classdef UDPReceiver<matlab.system.SFunSystem&...
    matlab.system.mixin.FiniteSource

























































%#function mdspFromNetwork

    properties



        LocalIPPort=25000;
    end

    properties(Nontunable)




        RemoteIPAddress='0.0.0.0';



        ReceiveBufferSize=8192;




        MaximumMessageLength=255;




        MessageDataType='uint8';
    end

    properties





        IsMessageComplex(1,1)logical=false;
    end

    properties(Constant,Hidden,Nontunable)
        MessageDataTypeSet=matlab.system.StringSet({...
        'double','single',...
        'int8','uint8',...
        'int16','uint16',...
        'int32','uint32',...
        'logical'});
    end

    properties(Hidden,Nontunable)
        BlockingTime=0;
        LengthOutputPort=false;
    end

    methods

        function obj=UDPReceiver(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspFromNetwork');
            setProperties(obj,nargin,varargin{:});
            coder.extrinsic('license');
            builtin('license','checkout','Signal_Blocks');
        end

        function set.RemoteIPAddress(obj,value)
            value=convertStringsToChars(value);
            validateattributes(value,{'char'},{},'','RemoteIPAddress');
            obj.RemoteIPAddress=value;
        end
    end


    methods(Access=protected)

        function out=saveObjectImpl(obj)
            out=saveObjectImpl@matlab.system.SFunSystem(obj);
            out.SaveLockedData=false;
        end

    end

    methods(Hidden)
        function setParameters(obj)

            localIPAddress='0.0.0.0';
            remoteIPPort=-1;
            sampletime=1;
            datatypeIdx=getIndex(obj.MessageDataTypeSet,obj.MessageDataType);

            obj.compSetParameters({...
            localIPAddress,...
            obj.LocalIPPort,...
            obj.RemoteIPAddress,...
            remoteIPPort,...
            obj.ReceiveBufferSize,...
            datatypeIdx,...
            obj.MaximumMessageLength,...
            sampletime,...
            double(~obj.LengthOutputPort),...
            obj.BlockingTime,...
            double(obj.IsMessageComplex)
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsrcs4/UDP Receive';
        end

        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.LocalIPPort=1;
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'LocalIPPort',...
            'RemoteIPAddress',...
            'ReceiveBufferSize',...
            'MaximumMessageLength',...
            'MessageDataType',...
'IsMessageComplex'
            };
        end

    end
end


