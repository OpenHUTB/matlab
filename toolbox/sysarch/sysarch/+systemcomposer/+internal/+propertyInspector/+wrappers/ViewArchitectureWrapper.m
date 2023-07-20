classdef ViewArchitectureWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper



    properties
        mdl;
        occurenceElement;
        bdH;
        schemaType;
    end

    methods
        function obj=ViewArchitectureWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            obj.schemaType='View';
        end
        function type=getObjectType(~)
            type='ViewArchitecture';
        end

        function setPropElement(obj)
            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getModel();
            obj.element=obj.mdl.findElement(obj.uuid).p_View;
        end

        function name=getName(obj)

            name=obj.element.getName;
        end

        function error=setName(obj,changeSet,~)

            error='';
            newName=changeSet.newValue;
            try
                obj.element.setName(newName);
            catch
                error='Failed to set Name';
            end
        end
        function name=getNameTooltip(obj)

            name=obj.element.getName;
        end

        function status=isNameEditable(~)

            status=true;
        end

        function desc=getDescription(obj)
            desc=obj.element.p_Description;
        end

        function error=setDescription(obj,changeSet,~)
            error='';
            try
                obj.element.p_Description=changeSet.newValue;
            catch
                error='Failed to set Name';
            end
        end

        function color=getColor(obj)
            color=obj.element.p_Color;
        end

        function error=setColor(obj,changeSet,~)
            error='';
            try
                obj.element.p_Color=changeSet.newValue;
            catch
                error='Failed to set Name';
            end
        end

        function tf=getIncludeReferenceModels(obj)
            if(obj.element.p_Scope.hasIncludeReferenceModels)
                tf='true';
            else
                tf='false';
            end
        end

        function error=setIncludeReferenceModels(obj,changeSet,~)
            error='';

            obj.element.p_Scope.setIncludeReferenceModels(changeSet.newValue);
        end
    end
end

