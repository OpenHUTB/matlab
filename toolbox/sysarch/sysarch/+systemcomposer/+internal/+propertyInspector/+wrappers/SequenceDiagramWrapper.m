classdef SequenceDiagramWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper





    properties
        mdl;
        occurenceElement;
        bdH;
        schemaType;
    end

    methods
        function obj=SequenceDiagramWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            obj.schemaType='SequenceDiagram';
        end

        function type=getObjectType(~)
            type='SequenceDiagram';
        end

        function setPropElement(obj)
            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getViewBrowserModel();
            obj.element=obj.mdl.findElement(obj.uuid);
        end

        function name=getName(obj)

            name=obj.element.p_Label;
        end

        function error=setName(obj,changeSet,~)

            error='';
            newName=changeSet.newValue;
            try
                sequencediagram.internal.renameSequenceDiagram(obj.archName,obj.element.p_Label,newName);
            catch
                error='Failed to set Name';
            end
        end

        function name=getNameTooltip(obj)

            name=obj.element.p_Label;
        end

        function status=isNameEditable(~)

            status=true;
        end
    end
end

