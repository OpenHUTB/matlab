classdef(Abstract)AbstractInfoManager<handle





    properties(GetAccess=protected,SetAccess=protected)


AllInfos
    end

    properties(Access=protected)

FiType
    end

    properties(Dependent)

Infos
    end

    methods
        function infos=get.Infos(obj)
            infos=obj.getValidInfos;
        end
    end

    methods(Abstract)

        ai=create(obj)
    end

    methods(Access=public)

        function obj=AbstractInfoManager(fiType)
            obj.FiType=fiType;
            obj.AllInfos=obj.createEmptyTypeVector;
        end


        clear(obj)
    end

    methods



        remove(obj,ai)

        insert(obj,ai)
    end

    methods(Access=protected)
        vec=createEmptyTypeVector(obj)
        infos=getValidInfos(obj)
    end

end


