classdef(Abstract)PortPlacementSpecification<handle




    properties(Access=protected)
Block
    end

    properties(Abstract,Constant)
ConnectorPlacementType
    end

    methods(Abstract)
        revertToDefault(obj)
        loadFromSchema(obj,schema)
    end

    methods(Abstract,Access=protected)
        schemaModel=getSchemaModel(obj)
    end

    methods
        function applySpec(obj)
            schemaModel=getSchemaModel(obj);
            serializer=mf.zero.io.JSONSerializer;
            jsonSchemaModel=serializer.serializeToString(schemaModel);

            set_param(obj.Block,'PortSchema',jsonSchemaModel);
        end
    end



    methods(Access=protected)
        function obj=PortPlacementSpecification(block)
            obj.Block=block;
        end
    end
end

