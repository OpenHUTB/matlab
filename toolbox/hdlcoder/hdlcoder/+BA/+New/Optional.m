

classdef Optional
    properties(SetAccess=private)
m_isSome
value
    end

    methods(Access=public)
        function val=isSome(this)
            val=this.m_isSome;
        end

        function val=isNone(this)
            val=~this.m_isSome;
        end

        function value=unwrap(this)
            if this.m_isSome
                value=this.value;
            else
                assert(false);
            end
        end

        function value=unwrapOr(this,orVal)
            if this.m_isSome
                value=this.value;
            else
                value=orVal;
            end
        end
    end

    methods(Access=private)
        function this=Optional(isSome,value)
            this.m_isSome=isSome;
            this.value=value;
        end
    end

    methods(Static=true)
        function this=none()
            import BA.New.Optional;
            this=Optional(false,0);
        end

        function this=some(value)
            import BA.New.Optional;
            this=Optional(true,value);
        end
    end
end
