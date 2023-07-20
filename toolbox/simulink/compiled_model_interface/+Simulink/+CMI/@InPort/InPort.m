


classdef InPort<Simulink.CMI.cpp.InPort&Simulink.CMI.PortDisplay
    properties
sess
    end
    methods
        function obj=InPort(session,varargin)
            obj=obj@Simulink.CMI.cpp.InPort(varargin{:});
            obj.sess=session;
        end
        function bc=getCondSrc(obj)
            bci=getCondSrc@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection(obj.sess,bci);
        end
        function bc=getActualSrc(obj)
            bci=getActualSrc@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection(obj.sess,bci);
        end
        function bc=getBoundedSrc(obj)
            bci=getBoundedSrc@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection(obj.sess,bci);
        end
        function bc=getGraphicalSrc(obj)
            bci=getGraphicalSrc@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection(obj.sess,bci);
        end
        function bc=getTGSrc(obj)
            bci=getTGSrc@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.OutPort(obj.sess,bci.Handle);
        end
        function bc=getActualSrcForVirtualBus(obj)
            bci=getActualSrcForVirtualBus@Simulink.CMI.cpp.InPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection(obj.sess,bci);
        end
        function bc=getCompiledAttributes(obj,varargin)
            bc=getCompiledAttributes@Simulink.CMI.cpp.InPort(obj,obj.sess,varargin{:});
        end
        function blk=ParentBlock(obj)
            blkt=ParentBlock@Simulink.CMI.cpp.CompiledPort(obj);
            blk=Simulink.CMI.CompiledBlock(obj.sess,blkt.Handle);
        end
        function idx=PortIndex(obj)
            idx=obj.Index+1;
        end
        function port=getBufferDstPort(obj)
            portHandle=getBufferDstPort@Simulink.CMI.cpp.InPort(obj,obj.sess);

            if(portHandle==0.0)
                port=Simulink.CMI.OutPort.empty;
            else
                port=Simulink.CMI.OutPort(obj.sess,portHandle);
            end

        end
    end
end
