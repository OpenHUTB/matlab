classdef CompiledBlock<Simulink.CMI.cpp.CompiledBlock&matlab.mixin.CustomDisplay
    properties
sess
    end

    properties(SetAccess=immutable)
Name
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrp=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                propList=struct('Name',obj.Name);
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end

    methods
        function s=blockType(obj)
            s=get_param(obj.Handle,'BlockType');
        end
        function s=getFullpathName(obj)
            s=[get_param(obj.Handle,'Parent'),'/',get_param(obj.Handle,'Name')];
        end
        function obj=CompiledBlock(session,id)
            if~isa(session,'Simulink.CMI.cpp.CompiledSession')
                throw(MException('MATLAB:class:InvalidSuperclass',...
                '''%s'' is not a subclass of Simulink.CMI.cpp.CompiledSession',...
                class(session)));
            end
            obj@Simulink.CMI.cpp.CompiledBlock(id);
            obj.sess=session;
            if~isSynthesized(obj)
                obj.Name=getHyperlink(obj);
            else
                obj.Name=getFullpathName(obj);
            end
        end
        function bc=getCondSrc(obj)
            bc=getCondSrc@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getActualSrc(obj)
            bci=getActualSrc@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];%#ok<AGROW>
            end
        end
        function bc=getBoundedSrc(obj)
            bci=getBoundedSrc@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];
            end
        end
        function bc=getActualDst(obj)
            bci=getActualDst@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];
            end
        end
        function bc=getBoundedDst(obj)
            bci=getBoundedDst@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];
            end
        end
        function bc=srcExecutesConditionally(obj)
            bc=srcExecutesConditionally@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getGraphicalSrc(obj)
            bci=getGraphicalSrc@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];
            end
        end
        function bc=getGraphicalDst(obj)
            bci=getGraphicalDst@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.PortConnection.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.PortConnection(obj.sess,bci(i))];
            end
        end
        function bc=getOriginalBlock(obj)
            blkt=getOriginalBlock@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
            bc=Simulink.CMI.CompiledBlock(obj.sess,blkt.Handle);
        end
        function bc=getSyntReason(obj)
            bc=getSyntReason@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=Ports(obj)
            bci=Ports@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.cpp.CompiledPort.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.util.createPort(obj.sess,bci(i).Handle)];%#ok<AGROW>
            end
        end
        function bc=InPorts(obj)
            bci=InPorts@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.InPort.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.util.createPort(obj.sess,bci(i).Handle)];%#ok<AGROW>
            end
        end
        function bc=OutPorts(obj)
            bci=OutPorts@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.OutPort.empty;
            for i=1:length(bci)
                bc=[bc,Simulink.CMI.util.createPort(obj.sess,bci(i).Handle)];%#ok<AGROW>
            end
        end
        function bc=TriggerPort(obj)
            tp=TriggerPort@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.TriggerPort(obj.sess,tp.Handle);
        end
        function bc=EnablePort(obj)
            tp=EnablePort@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.EnablePort(obj.sess,tp.Handle);
        end
        function bc=IfActionPort(obj)
            tp=IfActionPort@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.IfActionPort(obj.sess,tp.Handle);
        end
        function bc=StatePort(obj)
            tp=StatePort@Simulink.CMI.cpp.CompiledBlock(obj);
            bc=Simulink.CMI.StatePort(obj.sess,tp.Handle);
        end
        function bc=getSfcnTypeCGIRSupportLevel(obj)
            bc=getSfcnTypeCGIRSupportLevel@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getTrueOriginalBlock(obj)
            bc=getTrueOriginalBlock@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=isPostCompileVirtual(obj)
            bc=isPostCompileVirtual@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=isSampleTimeInherited(obj)
            bc=isSampleTimeInherited@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=isSynthesized(obj)
            bc=isSynthesized@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=isVirtual(obj)
            bc=isVirtual@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getBlockDiagram(obj)
            bc=getBlockDiagram@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getCompiledParent(obj)
            bc=getCompiledParent@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getOutput(obj)
            bc=getOutput@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getRTWName(obj)
            bc=getRTWName@Simulink.CMI.cpp.CompiledBlock(obj,obj.sess);
        end
        function bc=getCoderName(obj)
            bc=getRTWName(obj);
        end
        function s=getHyperlink(obj)
            if~isSynthesized(obj)
                s=['<a href="matlab:coder.internal.code2model(''',obj.SID,''')">'...
                ,getFullpathName(obj),'</a>'];
            else
                s=getFullpathName(obj);
            end
        end
    end
end
