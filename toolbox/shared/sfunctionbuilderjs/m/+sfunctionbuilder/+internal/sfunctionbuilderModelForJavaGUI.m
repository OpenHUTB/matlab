classdef sfunctionbuilderModelForJavaGUI<handle
    properties(SetAccess=protected)
sfcnModel
USERDATA
    end

    methods

        function obj=sfunctionbuilderModelForJavaGUI()
            obj.sfcnModel=sfunctionbuilder.internal.sfunctionbuilderModel.getInstance();
        end

        function updateModel(obj,blockHandle,data)
            obj.sfcnModel.update(blockHandle,data);
        end
    end


    methods(Static)
        function sfunctionbuilderModelForJavaGUI=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=sfunctionbuilder.internal.sfunctionbuilderModelForJavaGUI();
            end
            sfunctionbuilderModelForJavaGUI=localObj;
        end
    end

end