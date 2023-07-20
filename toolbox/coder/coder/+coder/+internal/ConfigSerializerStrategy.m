classdef(Abstract=true)ConfigSerializerStrategy<handle
    properties(Access=protected)
        Cfg;
    end

    methods(Abstract,Access=public)
        val=getParamAsString(obj,param);
        val=getParamAsBoolean(obj,param);

        setParamAsBoolean(obj,param,val);
        setParamAsFile(obj,param,val);
        setParamAsFileList(obj,param,val);
        setParamAsInt(obj,param,val);
        setParamAsString(obj,param,val);
        setParamAsStringList(obj,param,val);
    end

    methods(Static)
        function serializer=create(cfg)
            if coderapp.internal.globalconfig('JavaFreePrjParser')
                serializer=coder.internal.JavaFreeConfigSerializer(cfg);
            else
                javachk('jvm');
                serializer=coder.internal.JavaConfigSerializer(cfg);
            end
        end
    end

    methods
        function obj=ConfigSerializerStrategy(cfg)
            obj.Cfg=cfg;
        end

        function cfg=getConfiguration(obj)
            cfg=obj.Cfg;
        end
    end
end