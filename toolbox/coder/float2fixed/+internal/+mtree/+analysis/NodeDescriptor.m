classdef NodeDescriptor<internal.mtree.analysis.Descriptor





    properties(Access=private)
        descriptors;
    end


    methods

        function obj=NodeDescriptor(varDescs)
            obj.descriptors=containers.Map('KeyType','double','ValueType','any');
            for ii=1:numel(varDescs)
                varDesc=varDescs{ii};
                assert(isa(varDesc,'internal.mtree.analysis.VariableDescriptor')||isa(varDesc,'internal.mtree.analysis.VariableDescriptorLoop'),...
                'Unexpected variable descriptor found in constructor');

                obj.setVarDesc(varDesc,ii);
            end
        end

        function this=setVarDesc(this,varDesc,idx)
            assert(isa(varDesc,'internal.mtree.analysis.VariableDescriptor')||isa(varDesc,'internal.mtree.analysis.VariableDescriptorLoop'),...
            'Unexpected variable descriptor found');
            this.descriptors(idx)=varDesc;
        end

        function varDesc=getVarDesc(this,idx)
            if isKey(this.descriptors,idx)
                varDesc=this.descriptors(idx);
            else
                varDesc=[];
            end
        end

        function val=getLength(this)
            val=numel(this.descriptors.keys);
        end

        function val=isConst(this)
            val=true;

            keys=this.descriptors.keys;
            for ii=1:numel(keys)
                if~this.descriptors(keys{ii}).isConst
                    val=false;
                    return
                end
            end
        end

        function val=isLoopDesc(this)
            val=this.descriptors(1).isLoopDesc;
        end

        function val=isConditionallyExecuted(this)
            val=this.descriptors(1).isConditionallyExecuted;
        end
    end
end


