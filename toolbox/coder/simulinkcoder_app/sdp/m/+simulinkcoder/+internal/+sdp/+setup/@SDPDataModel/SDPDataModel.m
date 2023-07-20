classdef SDPDataModel<handle



    properties
topModel
nodeMap
    end

    methods
        function obj=SDPDataModel(topModel)
            obj.topModel=topModel;
            obj.init();
        end

        init(obj)
        node=getNode(obj,id)
        setNodeProp(obj,id,prop,value)

        [out,node]=getRole(obj,id)
        out=getCoderDictionary(obj,id)
        out=getPlatform(obj,id)
        out=getDeploymentType(obj,id)
        bool=isConfigSetRef(obj,id)
    end
end

