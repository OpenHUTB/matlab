classdef PortConnection<Simulink.CMI.cpp.PortConnection
    properties
sess
    end
    methods
        function obj=PortConnection(session,pc)
            obj@Simulink.CMI.cpp.PortConnection(pc);
            obj.sess=session;
        end
        function rpci=element(obj,i)
            rpct=element@Simulink.CMI.cpp.PortConnection(obj,i);
            rpci=Simulink.CMI.RemotePortConnectionInfo(obj.sess,rpct);
        end
        function po=getOwner(obj)
            poo=getOwner@Simulink.CMI.cpp.PortConnection(obj);
            po=Simulink.CMI.util.createPort(obj.sess,poo.Handle);
        end
    end
end
