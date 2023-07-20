classdef(Sealed=true)JavaConfigSerializer<coder.internal.ConfigSerializerStrategy
    methods(Access=public)
        function val=getParamAsString(obj,param)
            val=obj.Cfg.getParamAsString(param);
        end

        function val=getParamAsBoolean(obj,param)
            val=obj.Cfg.getParamAsBoolean(param);
        end

        function setParamAsBoolean(obj,param,val)
            obj.Cfg.setParamAsBoolean(param,val);
        end

        function setParamAsFile(obj,param,val)
            obj.Cfg.setParamAsFile(param,val);
        end

        function setParamAsFileList(obj,param,val)
            obj.Cfg.setParamAsFileList(param,val);
        end

        function setParamAsInt(obj,param,val)
            obj.Cfg.setParamAsInt(param,val);
        end

        function setParamAsString(obj,param,val)
            obj.Cfg.setParamAsString(param,val);
        end

        function setParamAsStringList(obj,param,val)
            obj.Cfg.setParamAsStringList(param,val);
        end
    end
end