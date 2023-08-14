classdef(Sealed)Property<systemcomposer.profile.internal.Element&dynamicprops
































































    properties(Transient,Dependent)



        Name;


        Index;








        Type;




        Dimensions;





        Units;


        Min;


        Max;


















        DefaultValue;
    end

    properties(Transient,Dependent,SetAccess=private)

        Stereotype;



        FullyQualifiedName;
    end

    properties(Hidden)
        Derived logical=false;
    end





    methods
        function setMinAndMax(this,min,max)

            txn=this.Model.beginTransaction;
            this.Impl.setMinAndMax(min,max);
            txn.commit;
        end

        function convertedValue=getValueInUnits(this,value,curUnits,desiredUnits)

            if(~isnumeric(value))
                error('Can only convert numeric values');
            end
            unitClient=systemcomposer.property.UnitQueryClientWrapper.get(mf.zero.getModel(this.Impl));
            unitConversionInfo=unitClient.getConversionInfo(curUnits,desiredUnits);
            if~unitConversionInfo.isInverted
                convertedValue=value*unitConversionInfo.scaling+unitConversionInfo.offset;
            else
                convertedValue=unitConversionInfo.scaling/value;
            end
        end

        function destroy(this)


            this.Impl.destroy();
        end





        function set.Name(this,value)
            txn=this.Model.beginTransaction;
            this.Impl.setName(value);
            txn.commit;
        end

        function value=get.Name(this)
            value=this.Impl.getName();
        end

        function set.Index(this,value)
            txn=this.Model.beginTransaction;
            propSet=this.Stereotype.Impl.propertySet;
            if~isnumeric(value)||~isscalar(value)||double(uint32(value))~=value
                error(message('SystemArchitecture:Profile:InvalidPropIndexValue'));
            end
            if double(value)>double(propSet.properties.Size)
                error(message('SystemArchitecture:Profile:PropIndexExceedsNumProps',...
                double(value),double(propSet.properties.Size)));
            end


            propSet.moveProperty(uint32(this.Index-1),uint32(value-1));
            txn.commit;
        end

        function value=get.Index(this)


            value=double(this.Impl.p_Index)+1;
        end

        function set.Type(this,typeName)
            txn=this.Model.beginTransaction;
            if~isempty(enumeration(typeName))


                this.recreatePropertyImplForEnum(typeName);
                this.IsEnumeration=true;
            else

                this.Impl.setBaseType(typeName);
                this.IsEnumeration=false;
            end
            txn.commit;
        end

        function value=get.Type(this)
            if this.IsEnumeration
                value=this.Impl.type.MATLABEnumName;
            else
                value=this.Impl.getBaseType();
            end
        end

        function set.Dimensions(this,value)
            if~isnumeric(value)||~all(floor(value)==value)||~all(value>0)
                error(message('SystemArchitecture:Profile:InvalidPropDimensions'));
            end
            txn=this.Model.beginTransaction;
            this.Impl.setDimensions(uint64(value));
            txn.commit;
        end

        function value=get.Dimensions(this)
            value=double(this.Impl.getDimensions());
        end

        function set.Units(this,value)
            txn=this.Model.beginTransaction;
            this.Impl.setUnit(value);
            txn.commit;
        end

        function value=get.Units(this)
            value=this.Impl.getUnit();
        end

        function set.Min(this,value)
            txn=this.Model.beginTransaction;
            this.Impl.setMin(value);
            txn.commit;
        end

        function value=get.Min(this)
            value=this.Impl.getMin();
        end

        function set.Max(this,value)
            txn=this.Model.beginTransaction;
            this.Impl.setMax(value);
            txn.commit;
        end

        function value=get.Max(this)
            value=this.Impl.getMax();
        end

        function set.DefaultValue(this,value)
            if ischar(value)||(isstring(value)&&isscalar(value))
                value=char(value);
                txn=this.Model.beginTransaction;
                this.Impl.setDefaultPropertyValue(value);
                txn.commit;
            else
                error(message('SystemArchitecture:Profile:InvalidPropDefaultValue'));
            end
        end

        function value=get.DefaultValue(this)
            valueAndUnit=this.Impl.getDefaultPropertyValue();
            value=valueAndUnit{1};
        end

        function stereotype=get.Stereotype(this)

            sImpl=this.Impl.propertySet.prototype;
            stereotype=systemcomposer.profile.Stereotype.wrapper(sImpl);
        end

        function fqn=get.FullyQualifiedName(this)
            fqn=this.Impl.fullyQualifiedName;
        end

        function tf=get.Derived(this)
            tf=this.Impl.isDerived;
        end

        function set.Derived(this,val)
            this.Impl.isDerived=val;
        end
    end





    properties(Transient,Constant,Access=private)
        ImplClassName='systemcomposer.property.PropertyDefinition';
    end

    properties(Transient,Access=private)
        IsEnumeration;
    end

    methods(Static,Access=?systemcomposer.profile.Stereotype)
        function property=wrapper(impl)



            assert(isa(impl,systemcomposer.profile.Property.ImplClassName));
            if~isempty(impl.cachedWrapper)&&isvalid(impl.cachedWrapper)
                property=impl.cachedWrapper;
            else
                property=systemcomposer.profile.Property(impl);
            end
        end
    end

    methods(Access=private)
        function this=Property(impl)



            assert(isa(impl,systemcomposer.profile.Property.ImplClassName));
            this@systemcomposer.profile.internal.Element(impl);
        end

        function recreatePropertyImplForEnum(this,MATLABEnumName)



            name=this.Name;
            index=this.Index-1;
            stereotype=this.Stereotype.Impl;


            this.Impl.releaseCachedWrapper();
            this.Impl.destroy();
            this.Impl=[];


            newImpl=stereotype.propertySet.addEnumProperty(name,MATLABEnumName);
            stereotype.propertySet.moveProperty(newImpl.p_Index,index);


            this.setImpl(newImpl);
        end
    end
end
