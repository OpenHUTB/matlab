


classdef OutPort<Simulink.CMI.cpp.OutPort&Simulink.CMI.PortDisplay
    properties
sess
    end
    methods
        function obj=OutPort(session,varargin)
            obj=obj@Simulink.CMI.cpp.OutPort(varargin{1});
            obj.sess=session;
        end
        function bc=getGraphicalDst(obj)
            bci=getGraphicalDst@Simulink.CMI.cpp.OutPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];%#ok<AGROW>
            end
        end
        function bc=getTGDst(obj)
            bci=getTGDst@Simulink.CMI.cpp.OutPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];%#ok<AGROW>
            end
        end
        function bc=getActualDst(obj)
            bci=getActualDst@Simulink.CMI.cpp.OutPort(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];%#ok<AGROW>
            end
        end
        function bc=getICAttribsComputeInFirstInit(obj)
            bc=getICAttribsComputeInFirstInit@Simulink.CMI.cpp.OutPort(obj,obj.sess);
        end
        function bc=getICAttribsComputeInStart(obj)
            bc=getICAttribsComputeInStart@Simulink.CMI.cpp.OutPort(obj,obj.sess);
        end
        function bc=getOutput(obj)
            bc=getOutput@Simulink.CMI.cpp.OutPort(obj,obj.sess);
        end
        function blk=ParentBlock(obj)
            blkt=ParentBlock@Simulink.CMI.cpp.CompiledPort(obj);
            blk=Simulink.CMI.CompiledBlock(obj.sess,blkt.Handle);
        end
        function idx=PortIndex(obj)
            idx=obj.Index+1;
        end
        function ports=getInputPortsToOverwrite(obj)
            portHandles=getInputPortsToOverwrite@Simulink.CMI.cpp.OutPort(obj,obj.sess);
            ports=Simulink.CMI.InPort.empty;
            for portHandle=portHandles
                ports=[ports,Simulink.CMI.InPort(obj.sess,portHandle)];%#ok<AGROW>
            end
        end
    end
end
