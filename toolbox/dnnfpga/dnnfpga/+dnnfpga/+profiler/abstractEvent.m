classdef abstractEvent<matlab.mixin.Heterogeneous



    properties(Access=protected)
        m_bitRange;
        m_name;
    end

    methods(Access=public,Hidden=true)
        function obj=abstractEvent(range,name)
            obj.m_bitRange=range;
            obj.m_name=name;
        end
    end

    methods(Access=public)
        function br=getBitRange(this)
            br=this.m_bitRange;
        end

        function br=getName(this)
            br=this.m_name;
        end

        function setName(this,name)
            this.m_name=name;
        end
    end

    methods(Access=public,Abstract=true,Static=true)
        type=getType()
    end

    methods(Access=public,Abstract=true)
        triggered=isTriggered(this,rawLog)
        val=parse(this,rawLog)
    end
end

