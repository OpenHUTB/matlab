classdef RockwellEmitter_InitialValueVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=RockwellEmitter_InitialValueVisitor
            obj.Kind='RockwellEmitter_InitialValueVisitor';
        end
    end

    methods
        function ret=visitConstFalse(obj,host,input)%#ok<INUSD>
            ret='0';
        end

        function ret=visitConstTrue(obj,host,input)%#ok<INUSD>
            ret='1';
        end

        function ret=visitConstValue(obj,host,input)%#ok<INUSL,INUSD>
            ret=host.value;
        end

        function ret=visitTimeValue(obj,host,input)%#ok<INUSL,INUSD>
            ret=sprintf(' := t#%s%s',host.value,host.unit);
        end
    end
end

