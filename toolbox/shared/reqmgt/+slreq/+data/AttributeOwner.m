classdef AttributeOwner<slreq.data.DataModelObj





    methods
        function value=getProperty(this,field)
            value=this.modelObject.getProperty(field);
        end

        function setProperty(this,field,value)
            this.modelObject.setProperty(field,value);
        end

        function tf=hasProperty(this,field)
            attr=this.modelObject.attributes{field};
            tf=~isempty(attr);
        end

        function props=getAllProperty(this)
            attr=this.modelObject.attributes.toArray;
            if isempty(attr)
                props={};
            else
                props={attr.name};
            end
        end


        function executeCB(this,callbackType,varargin)
            text=this.(callbackType);
            slreq.internal.callback.Utils.executeCallback(this,callbackType,text,varargin{:});
        end
    end

end

