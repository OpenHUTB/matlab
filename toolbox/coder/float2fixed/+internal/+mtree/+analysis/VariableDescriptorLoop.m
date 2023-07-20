classdef VariableDescriptorLoop<internal.mtree.analysis.VariableDescriptor







    properties
        descriptors;
    end


    methods

        function obj=VariableDescriptorLoop(varDesc,idx)
            assert(isa(varDesc,'internal.mtree.analysis.VariableDescriptor'),...
            'Unexpected variable descriptor found in constructor');


            obj=obj@internal.mtree.analysis.VariableDescriptor(...
            varDesc.constType,varDesc.type,varDesc.constVal,varDesc.evaluateableString);


            obj.isConditionallyExecuted=varDesc.isConditionallyExecuted;
            obj.descriptors=containers.Map('KeyType','double','ValueType','any');
            obj=obj.setVarDesc(varDesc,idx);
        end

        function obj=setVarDesc(this,varDesc,idx)
            obj=setVarDesc@internal.mtree.analysis.VariableDescriptor(this,varDesc,idx);


            currentDescDim=obj.descriptors;
            for ii=1:numel(idx)
                idx_1dim=idx(ii);
                if ii~=numel(idx)
                    if~isKey(currentDescDim,idx_1dim)

                        currentDescDim(idx_1dim)=containers.Map('KeyType','double','ValueType','any');
                    end

                    currentDescDim=currentDescDim(idx_1dim);
                else

                    currentDescDim(idx_1dim)=internal.mtree.analysis.VariableDescriptor(...
                    obj.constType,obj.type,obj.constVal,obj.evaluateableString);
                end
            end
        end

        function varDesc=getVarDesc(this,idx)
            currentDescDim=this.descriptors;
            varDesc=[];
            for ii=1:numel(idx)
                idx_1dim=idx(ii);
                if~isKey(currentDescDim,idx_1dim)

                    varDesc=[];
                    break;
                elseif ii~=numel(idx)

                    currentDescDim=currentDescDim(idx_1dim);
                else

                    varDesc=currentDescDim(idx_1dim);
                end
            end
        end

        function constness=isConst(this,idx)
            if nargin<2
                constness=isConst@internal.mtree.analysis.VariableDescriptor(this);
            else
                constness=this.descriptors{idx}.isConst;
            end
        end

        function indeterminateness=isIndeterminate(this,idx)
            if nargin<2
                indeterminateness=isIndeterminate@internal.mtree.analysis.VariableDescriptor(this);
            else
                indeterminateness=this.descriptors{idx}.isIndeterminate;
            end
        end

        function nonconstness=isNonConst(this,idx)
            if nargin<2
                nonconstness=isNonConst@internal.mtree.analysis.VariableDescriptor(this);
            else
                nonconstness=this.descriptors{idx}.isNonConst;
            end
        end

        function this=setConstness(this,isConst,idx)
            if nargin<3
                setConstness@internal.mtree.analysis.VariableDescriptor(this,isConst);
            else
                if(isConst)
                    this.descriptors{idx}.constType=internal.mtree.analysis.ConstType.IS_A_CONST;
                else
                    this.descriptors{idx}.constType=internal.mtree.analysis.ConstType.NOT_A_CONST;
                end
            end
        end

        function res=isequal(this,other,idx)
            if nargin<3
                res=isequal@internal.mtree.analysis.VariableDescriptor(this,other);
            else
                res=this.descriptors{idx}.isequal(other.descriptors{idx});
            end
        end

        function res=isConstEqual(this,other,idx)


            if nargin<3
                res=isConstEqual@internal.mtree.analysis.VariableDescriptor(this,other);
            else
                res=this.descriptors{idx}.isConstEqual(other.descriptors{idx});
            end
        end
    end

    methods(Static)
        function descriptor=getDescriptorFromNode(node,fcnTypeInfo)
            attributes=fcnTypeInfo.treeAttributes;
            descriptor=attributes(node).VariableDescriptor;
        end
    end
end


