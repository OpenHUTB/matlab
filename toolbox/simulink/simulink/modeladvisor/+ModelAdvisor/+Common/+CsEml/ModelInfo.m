
classdef ModelInfo<handle

    methods

        function this=ModelInfo(modelName)
            this.m_Name=modelName;
        end

        function name=getName(this)
            name=this.m_Name;
        end

    end

    properties
        m_Name;
    end

end

