classdef InterfaceElementNode<sl.interface.dictionaryApp.node.ElementNode





    properties(Constant,Access=protected)


        GenericPropertyNames cell=sl.interface.dictionaryApp.node....
        typeeditor.ElementAdapter.GenericPropertyNames;
        TypePropName=sl.interface.dictionaryApp.node.PackageString.DataTypeProp;
    end

    methods(Static,Access=public)
        function propertyNames=getGenericPropertyNames()
            propertyNames=...
            sl.interface.dictionaryApp.node.InterfaceElementNode....
            GenericPropertyNames;
        end
    end

    methods(Access=public)
        function nodeType=getNodeType(this)
            assert(isa(this.InterfaceDictElement,...
            'Simulink.interface.dictionary.DataElement'),...
            'Unexpected interface node type for type chain');
            nodeType='InterfaceElement';
        end
    end
end


