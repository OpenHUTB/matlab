classdef AbstractLinearizationGraph<linearize.advisor.graph.GenericLinearizationGraph


    properties(Access=protected)
Model
MdlHierInfo
    end
    methods
    end
    methods(Access=protected)
        function this=AbstractLinearizationGraph(mdl,mdlHierInfo)
            this.Model=mdl;
            this.MdlHierInfo=mdlHierInfo;
        end
        function bool=isNodeMemberOfMultiInstancedMdl(this,node)
            multiInstMdls=this.MdlHierInfo.CompiledMdls(this.MdlHierInfo.IsMultiInstanced);
            if isempty(multiInstMdls)
                bool=false;
            else
                bool=ismember(node.ParentMdl,multiInstMdls);
            end
        end
        function val=hasModelRefs(this)
            val=numel(this.MdlHierInfo.CompiledMdls)>1;
        end
    end
end