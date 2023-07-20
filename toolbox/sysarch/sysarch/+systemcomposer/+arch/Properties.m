classdef(Hidden=true)Properties<dynamicprops




    properties(Hidden)
PrototypeName
    end

    methods(Hidden)
        function this=Properties(protoName)
            narginchk(1,1);
            this.PrototypeName=protoName;
        end
    end

    methods(Hidden)
        function addDynamicProperties(this,customProperties)
            for props=customProperties
                this.addProperty(props);
            end
        end

        function addProperty(this,propObj)
            mdProp=this.addprop(propObj.getName);
            mdProp.Hidden=true;
            mdProp.SetAccess='private';
            mdProp.GetMethod=@(this)getCustomPropertyValue(this,propObj);
        end

        function removeProperty(this,propName)
            mdProp=this.findprop(propName);
            delete(mdProp);
        end

        function value=getCustomPropertyValue(~,propObj)
            value=propObj.derivedInitialValue.expression;
        end

        function setCustomPropertyValue(~,propObj,value)
            mfModel=mf.zero.getModel(propObj);
            t=mfModel.beginTransaction;
            propObj.setInitialPropertyValue(value);
            t.commit;
        end

    end

end
