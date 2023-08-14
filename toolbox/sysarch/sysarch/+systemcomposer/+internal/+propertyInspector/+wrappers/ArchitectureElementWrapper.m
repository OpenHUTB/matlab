classdef ArchitectureElementWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper


    properties
        isAUTOSARCompositionSubDomain;
        isSysarchCompositionSubDomain;
        bdH;
        schemaType;
    end

    methods
        function obj=ArchitectureElementWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            obj.schemaType='Architecture';
        end
        function type=getObjectType(~)
            type='Architecture';
        end

        function setPropElement(obj)
            if isempty(obj.sourceHandle)

                obj.element=obj.getZCElement();
                if~isa(obj.element,'systemcomposer.architecture.model.design.Architecture')
                    obj.sourceHandle=systemcomposer.utils.getSimulinkPeer(obj.element);
                end
            else
                obj.archName=bdroot(getfullname(obj.sourceHandle));
                obj.element=systemcomposer.utils.getArchitecturePeer(obj.sourceHandle);
            end
            obj.isAUTOSARCompositionSubDomain=Simulink.internal.isArchitectureModel(obj.archName,'AUTOSARArchitecture');
            obj.isSysarchCompositionSubDomain=Simulink.internal.isArchitectureModel(obj.archName,'Architecture');
            obj.bdH=get_param(obj.archName,'Handle');
        end

        function name=getName(obj)

            name=obj.element.getName;
        end

        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try

                set_param(obj.h.Handle,'Name',newValue);
                obj.archName=newValue;
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
    end
end
