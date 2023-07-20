classdef VariableDescriptorList<internal.mtree.analysis.VariableDescriptor






    properties



        descriptors;
    end


    methods

        function obj=VariableDescriptorList(variableConstness,type,varDescs)

            obj=obj@internal.mtree.analysis.VariableDescriptor(...
            variableConstness,type);

            obj.descriptors=cell(type.Dimensions);


            assert(obj.isPartiallyConst||obj.isNonConst,...
            'VariableDescriptorList should only be used to represent partially constant or fully non-constant values');

            hasNonConstVal=false;

            for ii=1:numel(varDescs)
                varDesc=varDescs{ii};
                obj=obj.setVarDesc(varDesc,ii);
                hasNonConstVal=hasNonConstVal||~varDesc.isConst;
            end



            assert(hasNonConstVal,'VariableDescriptorLists must have at least one non-constant element');
        end

        function this=setVarDesc(this,varDesc,idx)
            assert(isa(varDesc,'internal.mtree.analysis.VariableDescriptor'),...
            'Unexpected variable descriptor found');
            this.descriptors{idx}=varDesc;
        end

        function varDesc=getVarDesc(this,idx)
            if idx>=1&&idx<=this.getLength
                varDesc=this.descriptors{idx};
            else
                varDesc=[];
            end
        end

        function val=getLength(this)
            val=numel(this.descriptors);
        end

        function dims=getDimensions(this)
            dims=size(this.descriptors);
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

        function partialconstness=isPartiallyConst(this,idx)
            if nargin<2
                partialconstness=isPartiallyConst@internal.mtree.analysis.VariableDescriptor(this);
            else
                partialconstness=this.descriptors{idx}.isPartiallyConst;
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

end



