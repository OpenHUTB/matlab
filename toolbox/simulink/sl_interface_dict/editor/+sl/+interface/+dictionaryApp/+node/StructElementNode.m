classdef StructElementNode<sl.interface.dictionaryApp.node.ElementNode





    properties(Constant,Access=protected)


        GenericPropertyNames cell={...
        sl.interface.dictionaryApp.node.PackageString.NameColHeader,...
        sl.interface.dictionaryApp.node.PackageString.TypeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DimensionsColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DimensionsModeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.UnitColHeader,...
        sl.interface.dictionaryApp.node.PackageString.ComplexityColHeader,...
        sl.interface.dictionaryApp.node.PackageString.MinColHeader,...
        sl.interface.dictionaryApp.node.PackageString.MaxColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DescriptionColHeader};
        TypePropName=sl.interface.dictionaryApp.node.PackageString.DataTypeProp;
    end

    methods(Static,Access=public)
        function propertyNames=getGenericPropertyNames()
            propertyNames=...
            sl.interface.dictionaryApp.node.StructElementNode....
            GenericPropertyNames;
        end
    end

    methods(Access=public)

        function nodeType=getNodeType(this)
            assert(isa(this.InterfaceDictElement,...
            'Simulink.interface.dictionary.StructElement'),...
            'Unexpected struct element node type for type chain');
            nodeType='StructureElement';
        end
    end

    methods(Access=protected)
        function propertyNames=getPlatformProperties(~)

            propertyNames=containers.Map();
        end
    end
end


