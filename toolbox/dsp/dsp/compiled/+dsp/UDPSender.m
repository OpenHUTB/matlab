classdef UDPSender<matlab.system.SFunSystem























































%#function mdspToNetwork

%#ok<*EMCLS>
%#ok<*EMCA>

    properties



        RemoteIPPort=25000;
    end

    properties(Nontunable)




        RemoteIPAddress='127.0.0.1';






        LocalIPPortSource='Auto';




        LocalIPPort=25000;



        SendBufferSize=8192;
    end

    properties(Constant,Hidden)
        LocalIPPortSourceSet=matlab.system.StringSet({...
        'Auto',...
        'Property'});
    end

    properties(Hidden,Nontunable)
        SendAtExit=[];
        LengthInputPort=false;
    end

    methods

        function obj=UDPSender(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspToNetwork');
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

            localIPPortSourceIdx=getIndex(...
            obj.LocalIPPortSourceSet,obj.LocalIPPortSource);

            localIPAddress='0.0.0.0';

            obj.compSetParameters({...
            localIPAddress,...
            localIPPortSourceIdx,...
            obj.LocalIPPort,...
            obj.RemoteIPAddress,...
            obj.RemoteIPPort,...
            obj.SendBufferSize,...
            double(obj.LengthInputPort),...
            obj.SendAtExit...
            });
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
        function y=callTerminateAfterCodegen(~)





            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'LocalIPPort')&&~strcmp(obj.LocalIPPortSource,'Property')
                flag=true;
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsnks4/UDP Send';
        end

        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.RemoteIPPort=4;
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'RemoteIPAddress',...
            'RemoteIPPort',...
            'LocalIPPortSource',...
            'LocalIPPort',...
'SendBufferSize'...
            };
        end

    end
end



