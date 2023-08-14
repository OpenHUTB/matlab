classdef InterfaceElementWrapper





    properties
        elemUUID;
        mf0Model;
        interfaceCatalog;
        element;
        interface;
        type;
    end

    methods
        function obj=InterfaceElementWrapper(elemUUID,mf0Model)


            obj.elemUUID=elemUUID;
            obj.mf0Model=mf0Model;
            obj.element=mf0Model.findElement(elemUUID);
            obj.interfaceCatalog=systemcomposer.architecture.model.interface.InterfaceCatalog.getInterfaceCatalog(mf0Model);
            obj.interface=obj.element.getInterface;
            obj.type='InterfaceElement';
        end

        function element=getPropElement(obj)


            element=obj.element;
        end

        function[value,entries]=getElemType(obj)
            [value,entries]=systemcomposer.internal.getTypeAndAvailableTypes(obj.element);
        end
        function dimensions=getElemDimensions(obj)
            dimensions=obj.element.getDimensions();
        end
        function units=getElemUnits(obj)
            units=obj.element.getUnits();
        end
        function[complexity,entries]=getElemComplexity(obj)
            complexity=obj.element.getComplexity();
            entries={'real','complex'};
        end
        function maximum=getElemMaximum(obj)
            maximum=obj.element.getMaximum();
        end
        function minimum=getElemMinimum(obj)
            minimum=obj.element.getMinimum();
        end
        function description=getElemDescription(obj)
            description=obj.element.getDescription();
        end
        function name=setElemType(obj)
            name=['Interface : ',obj.element.interface.getName(),' | Element : ',obj.element.element.getName()];
        end
    end
end

