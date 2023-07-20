classdef ViewPortWrapper<systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper





    properties
        mdl;
        occurenceElement;
        isAdapterComp=false;
    end

    methods
        function obj=ViewPortWrapper(varargin)




            obj=obj@systemcomposer.internal.propertyInspector.wrappers.PortElementWrapper(varargin{:});


            obj.schemaType='View Port';

        end
        function obj=setPropElement(obj)


            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getModel();
            obj.occurenceElement=obj.mdl.findElement(obj.uuid);
            obj.element=obj.occurenceElement.getArchitecturePort;

        end
        function elem=getElementForInterface(obj)
            elem=obj.element.getDelegateOccurrencePort.getDesignComponentPort;
        end
        function name=getName(obj)

            name=obj.element.getName;
        end
        function status=isInterfaceEnabled(~)
            status=false;
        end
        function name=getNameTooltip(obj)

            name=obj.element.getName;
        end

        function status=isNameEditable(~)

            status=false;
        end

        function type=getObjectType(~)
            type='ViewPort';
        end



    end
end


