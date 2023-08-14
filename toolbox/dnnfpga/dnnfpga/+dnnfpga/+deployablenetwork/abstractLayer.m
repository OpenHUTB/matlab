classdef abstractLayer<handle



    properties(Access=private)
m_name
    end

    methods(Access=public,Hidden=true)
        function obj=abstractLayer(name)
            obj.m_name=name;
        end
    end

    methods(Access=public)
        function init(this,verbose)
        end

        function name=getName(this)
            name=this.m_name;
        end
    end

    methods(Access=public,Abstract=true)
        output=forward(this,input)
    end

    methods(Access=protected,Abstract=true)
    end
end

