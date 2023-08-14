classdef(Abstract,Hidden)AbstractInstanceElement<dynamicprops&matlab.mixin.SetGet


    properties(Access=protected,Hidden)
InstElementImpl
DynamicProperties
    end

    methods
        function b=isequal(this,other)
            b=isequal(this.getImpl.UUID,other.getImpl.UUID);
        end

        function delete(this)
            this.InstElementImpl=mf.zero.ModelElement.empty;
        end
    end

    methods(Hidden)
        function this=AbstractInstanceElement(instElemImpl)
            this.InstElementImpl=instElemImpl;


        end


        function model=getModel(this)
            model=mf.zero.getModel(this.InstElementImpl);
        end


        function model=getUUID(this)
            model=this.InstElementImpl.UUID;
        end
    end

    methods(Access=public)

        function[value,unit]=getValue(this,name)
            prop=this.getValuePropertySetByName(name);
            value=prop.getAsMxArray;
            unit=prop.units;
        end

        function res=hasValue(this,name)
            try
                this.getValuePropertySetByName(name);
                res=true;
            catch
                res=false;
            end
        end

        function setValue(this,name,value)
            prop=this.getValuePropertySetByName(name);
            t=this.getModel.beginTransaction;
            prop.setAsMxArray(value);
            t.commit;
        end
    end

    methods(Access=public,Hidden)
        function impl=getImpl(this)
            impl=this.InstElementImpl;
        end

        function prop=getValuePropertySetByName(this,name)
            inst=this.getInstance;
            obj=inst.propertyValues.toArray;
            parts=string(name).split('.');
            set=[];
            if length(parts)==3


                valSetKey=strcat(parts(1),'.',parts(2));
                set=obj.values.getByKey(valSetKey);
                propName=parts(3);
            else


                if length(parts)==2
                    propName=parts(2);
                end
                keys=obj.values.keys;
                valSetKey=parts(1);
                if~isempty(keys)
                    idx=(contains(keys,parts(1)));
                    if any(idx)
                        valSetKey=keys{idx};
                        set=obj.values.getByKey(valSetKey);
                    end
                end
            end
            if isempty(set)
                error('SystemArchitecture:Analysis:SetNotFound',DAStudio.message('SystemArchitecture:Analysis:SetNotFound',valSetKey));
            end
            prop=set.values.getByKey(propName);
            if isempty(prop)
                error('SystemArchitecture:Analysis:ValueNotFound',DAStudio.message('SystemArchitecture:Analysis:ValueNotFound',propName,valSetKey));
            end
        end
    end

    methods(Access=protected)
        function addDynamicProperties(this,elementImpl)


            propValues=elementImpl.propertyValues.toArray;
            if~isempty(propValues)
                propUsages=propValues.values.toArray;
                for propUsage=propUsages
                    customProperties=propUsage.values.toArray;
                    prototypeName=propUsage.getName;
                    this.addprop(prototypeName);
                    this.DynamicProperties=systemcomposer.analysis.InstanceProperties(prototypeName);
                    this.(prototypeName)=this.DynamicProperties;
                    this.DynamicProperties.addDynamicProperties(customProperties);
                end
            end
        end
    end
    methods(Static,Access=public,Hidden)
        function wrapperObj=getWrapperForImpl(instImpl,wrapperClassName)



            wrapperObj=instImpl.cachedWrapper;
            if isempty(wrapperObj)||~isvalid(wrapperObj)
                if nargin<2
                    if isa(instImpl,'systemcomposer.internal.analysis.NodeInstance')
                        wrapperClassName='systemcomposer.analysis.ComponentInstance';
                    elseif isa(instImpl,'systemcomposer.internal.analysis.PortInstance')
                        wrapperClassName='systemcomposer.analysis.PortInstance';
                    elseif isa(instImpl,'systemcomposer.internal.analysis.ArchitectureInstance')
                        wrapperClassName='systemcomposer.analysis.ArchitectureInstance';
                    else
                        wrapperClassName='systemcomposer.analysis.ConnectorInstance';
                    end
                end
                wrapperObj=feval(wrapperClassName,instImpl);
            end
        end
    end
end

