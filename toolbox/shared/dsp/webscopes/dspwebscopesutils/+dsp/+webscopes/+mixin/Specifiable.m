classdef Specifiable<handle





    properties(Hidden)

        Specification;
    end



    methods

        function this=Specifiable()
            this.Specification=getScopeSpecification(this);
        end
    end



    methods(Access=protected)

        function setPropertyValue(this,prop,newValue)
            setPropertyValue(this.Specification,prop,newValue);
        end

        function value=getPropertyValue(this,prop)
            value=getPropertyValue(this.Specification,prop);
        end

        function setPropertyValueAndNotify(this,prop,newValue)
            setPropertyValue(this,prop,newValue);




            this.notifyOutputChanged();
        end
    end



    methods(Abstract,Hidden)

        spec=getScopeSpecification(this)
    end
end