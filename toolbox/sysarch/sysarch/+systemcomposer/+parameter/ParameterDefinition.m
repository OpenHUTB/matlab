classdef ParameterDefinition<systemcomposer.parameter.internal.Element


    properties(Dependent=true)
Name
Type
Unit
Complexity
Dimensions
Value
Min
Max
Description
    end

    properties(SetAccess=private)
Owner
    end

    methods
        function name=get.Name(this)
            name=this.getImpl.getName;
        end

        function set.Name(this,name)

            oldName=this.Name;
            this.Owner.getImpl.checkParameterName(name);
            this.getImpl.setName(name);
            this.Owner.setParameterName(oldName,name);
        end

        function type=get.Type(this)
            type=this.getImpl.getBaseType;
        end

        function set.Type(this,newType)
            this.getImpl.setBaseType(newType);
        end

        function unit=get.Unit(this)
            unit=this.getImpl.defaultValue.units;
            if isempty(unit)
                unit=this.getImpl.getUnit;
            end
        end

        function set.Unit(this,unit)
            this.getImpl.setUnit(unit);
        end

        function cplx=get.Complexity(~)

            cplx='real';
        end

        function set.Complexity(~,~)

        end

        function dims=get.Dimensions(this)
            dimsVec=this.getImpl.getDimensions';
            if isscalar(dimsVec)
                dims=num2str(dimsVec);
            else
                dims=sprintf('[%s]',num2str(dimsVec));
            end
        end

        function set.Dimensions(this,dims)
            dimArray=str2num(dims);%#ok<ST2NM> 
            this.getImpl.setDimensions(uint64(dimArray));
        end

        function val=get.Value(this)
            val=this.getImpl.defaultValue.expression;
        end

        function set.Value(this,valExpr)
            this.getImpl.setDefaultParameterValue(valExpr);
        end

        function min=get.Min(this)
            min=num2str(this.getImpl.ownedType.min);
        end

        function set.Min(this,min)
            if isnumeric(min)
                this.getImpl.setMin(min);
            else
                this.getImpl.setMin(str2double(min));
            end
        end

        function max=get.Max(this)
            max=num2str(this.getImpl.ownedType.max);
        end

        function set.Max(this,max)
            if isnumeric(max)
                this.getImpl.setMax(max);
            else
                this.getImpl.setMax(str2double(max));
            end
        end

        function descr=get.Description(~)

            descr='';
        end

        function set.Description(~,~)

        end

        function destroy(this)
            this.Owner.removeParameter(this.Name);
        end
    end

    methods(Static,Access={?systemcomposer.arch.Architecture,?systemcomposer.arch.BaseComponent})
        function parameter=wrapper(impl,owningElem)



            assert(isa(impl,'systemcomposer.internal.parameter.ParameterDefinition'));
            if~isempty(impl.cachedWrapper)&&isvalid(impl.cachedWrapper)
                parameter=impl.cachedWrapper;
                if isempty(parameter.Owner)
                    parameter.Owner=owningElem;
                end
            else
                parameter=systemcomposer.parameter.ParameterDefinition(impl);
                parameter.Owner=owningElem;
            end
        end
    end

    methods(Access=private)
        function this=ParameterDefinition(impl)



            assert(isa(impl,'systemcomposer.internal.parameter.ParameterDefinition'));
            this@systemcomposer.parameter.internal.Element(impl);
        end
    end

end
