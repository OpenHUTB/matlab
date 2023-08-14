classdef Descriptor





    methods(Access=public)
        function res=isVarDesc(this)
            res=isa(this,'internal.mtree.analysis.VariableDescriptor');
        end

        function res=isNodeDesc(this)
            res=isa(this,'internal.mtree.analysis.NodeDescriptor');
        end

        function res=isListDesc(this)
            res=isa(this,'internal.mtree.analysis.VariableDescriptorList');
        end

        function res=isLoopDesc(this)
            res=isa(this,'internal.mtree.analysis.VariableDescriptorLoop');
        end

    end
end


