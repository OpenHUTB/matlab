classdef CompileModel<handle




    properties(SetAccess=private,GetAccess=private)
        savedEngineInterface=[];
        modelNeedsTerm=false;
        bdObject=[];
    end

    methods
        function delete(obj)
            if obj.modelNeedsTerm
                obj.bdObject.term();
            end
            if~isempty(obj.savedEngineInterface)
                obj.savedEngineInterface=[];
            end
        end
    end
end
