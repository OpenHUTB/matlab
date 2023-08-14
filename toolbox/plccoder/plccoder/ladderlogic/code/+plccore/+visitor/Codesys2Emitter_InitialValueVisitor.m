classdef Codesys2Emitter_InitialValueVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=Codesys2Emitter_InitialValueVisitor
            obj.Kind='Codesys2Emitter_InitialValueVisitor';
        end
    end

    methods
        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret='';
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret=sprintf(' := TRUE');
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSL,INUSD>
            ret=sprintf(' := %s',host.value);
        end

        function ret=visitTimeValue(obj,host,input)%#ok<INUSL,INUSD>
            ret=sprintf(' := t#%s%s',host.value,host.unit);
        end
    end
end

