classdef(Sealed)Undefined
    properties(Hidden,Constant)
        VALUE=codergui.internal.util.Undefined()
    end

    methods
        function this=Undefined()
            this=codergui.internal.util.Undefined.empty();
        end

        function equals=eq(a,b)
            equals=isempty(a)&&isempty(b)&&...
            isa(a,'codergui.internal.util.Undefined')&&...
            isa(b,'codergui.internal.util.Undefined');
        end

        function notEquals=ne(a,b)
            notEquals=~isempty(a)||~isempty(b)||...
            ~isa(a,'codergui.internal.util.Undefined')||...
            ~isa(b,'codergui.internal.util.Undefined');
        end
    end

    methods(Static,Hidden)
        function mustBeDefined(value)
            if value==codergui.internal.util.Undefined
                error('Value must be defined');
            end
        end
    end
end

