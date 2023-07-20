classdef VariableDescriptor<internal.mtree.analysis.Descriptor





    properties


        constType(1,1)internal.mtree.analysis.ConstType


        type(1,1)internal.mtree.Type=internal.mtree.type.UnknownType


        constVal;


        evaluateableString char


        isConditionallyExecuted(1,1)logical=false;

    end


    methods

        function obj=VariableDescriptor(variableConstness,type,constVal,evalString)

            if(nargin<4)
                evalString='';
            end

            if(nargin<3)
                constVal=[];
            end

            if ischar(variableConstness)
                variableConstness=internal.mtree.analysis.ConstType(variableConstness);
            end

            if isequal(variableConstness,internal.mtree.analysis.ConstType.IS_A_CONST)
                assert(nargin>3,'Variable descriptor needs constant information');
            end

            if type.isSizeDynamic&&...
                isequal(variableConstness,internal.mtree.analysis.ConstType.IS_A_CONST)




                type=type.copy;
                if isvector(constVal)

                    dims=type.Dimensions;
                    dims(type.Dimensions==-1)=length(constVal);
                    type.setDimensions(dims);
                else
                    type.setDimensions(size(constVal));
                end
            end

            obj.constType=variableConstness;
            obj.constVal=constVal;
            obj.type=type;
            obj.evaluateableString=evalString;
        end

        function this=setVarDesc(this,varDesc,~)



            this.constType=varDesc.constType;
            this.type=copy(varDesc.type);
            this.constVal=varDesc.constVal;
            this.evaluateableString=varDesc.evaluateableString;
            this.isConditionallyExecuted=varDesc.isConditionallyExecuted;
        end

        function constness=isConst(this)
            constness=isequal(this.constType,internal.mtree.analysis.ConstType.IS_A_CONST);
        end

        function indeterminateness=isIndeterminate(this)
            indeterminateness=isequal(this.constType,...
            internal.mtree.analysis.ConstType.INDETERMINABLE_IF_CONST);
        end

        function nonconstness=isNonConst(this)
            nonconstness=isequal(this.constType,internal.mtree.analysis.ConstType.NOT_A_CONST);
        end

        function nonconstness=isTunableConst(this)
            nonconstness=isequal(this.constType,internal.mtree.analysis.ConstType.TUNABLE_CONST);
        end

        function partialconstness=isPartiallyConst(this)
            partialconstness=isequal(this.constType,internal.mtree.analysis.ConstType.PARTIALLY_CONST);
        end

        function this=setConstness(this,isConst)
            if(isConst)
                this.constType=internal.mtree.analysis.ConstType.IS_A_CONST;
            else
                this.constType=internal.mtree.analysis.ConstType.NOT_A_CONST;
            end
        end

        function res=isequal(this,other)
            if isscalar(this)&&isscalar(other)
                if this.isConst&&other.isConst


                    res=isConstEqual(this,other);
                else

                    res=isequal(this.constType,other.constType)&&...
                    this.type==other.type;
                end
            elseif isequal(size(this),size(other))
                res=true;

                for ii=1:numel(this)
                    res=isequal(this(ii),other(ii));
                    if~res
                        return
                    end
                end
            else
                res=false;
            end
        end

        function res=isConstEqual(this,other)


            if this.isConst&&other.isConst


                if this.type.isUnknown&&other.type.isUnknown
                    typesEqual=true;
                else
                    typesEqual=this.type==other.type;
                end

                res=typesEqual&&isequal(this.constVal,other.constVal);
            else
                res=false;
            end
        end

        function this=set.evaluateableString(this,stringIn)
            if isempty(stringIn)||isrow(stringIn)
                this.evaluateableString=stringIn;
            else
                error('Property ''evaluateableString'' must be the empty string or a char row vector');
            end
        end

        function this=set.isConditionallyExecuted(this,boolIn)
            this.isConditionallyExecuted=boolIn;
        end

    end

    methods(Static)
        function descriptor=getDescriptorFromNode(node,fcnTypeInfo)
            attributes=fcnTypeInfo.treeAttributes;
            descriptor=attributes(node).VariableDescriptor;
        end
    end
end


