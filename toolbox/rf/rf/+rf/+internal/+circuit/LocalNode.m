classdef LocalNode<handle

    properties
MyGlobalNode
    end

    methods
        function obj=LocalNode(glbnode)
            obj.MyGlobalNode=glbnode;
            glbnode.MyLocalNodes(end+1)=obj;
        end
    end

end