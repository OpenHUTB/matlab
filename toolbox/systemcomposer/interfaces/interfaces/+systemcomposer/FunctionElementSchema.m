classdef FunctionElementSchema<systemcomposer.InterfaceElementSchema




    methods
        function this=FunctionElementSchema(fe,si,mf0Model)
            this@systemcomposer.InterfaceElementSchema(fe,si,mf0Model);
        end

        function subprops=subProperties(this,prop)
            subprops={};
            if isempty(prop)
                subprops{end+1}='Sysarch:Port:Interface:Element';
            end
            if(strcmp(prop,'Sysarch:Port:Interface:Element'))
                assert(isa(this.pie,'systemcomposer.architecture.model.swarch.FunctionElement'));
                subprops{end+1}='Sysarch:Port:Interface:Prototype';
            end
        end

        function propval=propertyValue(this,prop)
            switch(prop)
            case 'Sysarch:Port:Interface:Element'
                propval='';
            case 'Sysarch:Port:Interface:Prototype'
                propval=this.pie.getFunctionPrototype();
            end
        end

        function setPropertyValueHelper(this,prop,propval)
            txn=this.mf0Model.beginTransaction();
            elem=systemcomposer.internal.getWrapperForImpl(this.pie);
            switch(prop)
            case 'Sysarch:Port:Interface:Prototype'
                elem.setFunctionPrototype(propval);
            end
            txn.commit();
        end

        function result=propertyDisplayLabel(~,prop)
            switch(prop)
            case 'Sysarch:Port:Interface:Element'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Properties');
            case 'Sysarch:Port:Interface:Prototype'
                result=DAStudio.message('SystemArchitecture:PropertyInspector:Prototype');
            end
        end

    end
end


