
classdef RemotePortConnectionInfo<Simulink.CMI.cpp.RemotePortConnectionInfo&...
    matlab.mixin.CustomDisplay
    properties
sess
    end
    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                po=getPort(obj);
                propList=struct(...
                'Type',Simulink.CMI.util.portType(po),...
                'Identifier',getIdentifierString(po));
                try
                    propList.busSelElIdx=obj.busSelElIdx;
                    propList.regionLen=obj.regionLen;
                    propList.startEl=obj.startEl;
                    propList.srcStartEl=obj.srcStartEl;
                catch ME
                end
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end
    methods
        function obj=RemotePortConnectionInfo(session,rpci)
            obj@Simulink.CMI.cpp.RemotePortConnectionInfo(rpci);
            obj.sess=session;
        end
        function po=getPort(obj)
            poo=getPort@Simulink.CMI.cpp.RemotePortConnectionInfo(obj);
            po=Simulink.CMI.util.createPort(obj.sess,poo.Handle);
        end
    end
end
