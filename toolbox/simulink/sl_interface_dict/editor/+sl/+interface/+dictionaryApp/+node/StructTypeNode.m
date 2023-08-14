classdef StructTypeNode<sl.interface.dictionaryApp.node.DataTypeNode




    properties(Constant,Access=protected)


        GenericPropertyNames cell=...
        sl.interface.dictionaryApp.node.typeeditor.ObjectAdapter.GenericPropertyNames;
        TypePropName='';
    end

    methods(Access=public)

        function this=StructTypeNode(interfaceDictElement,dictObj,platformKind,studio)
            this=this@sl.interface.dictionaryApp.node.DataTypeNode(...
            interfaceDictElement,dictObj,platformKind,studio)
            this.generateChildNodes();
        end

        function nodeType=getNodeType(this)
            assert(isa(this.InterfaceDictElement,...
            'Simulink.interface.dictionary.DataType'),...
            'Unexpected interface node type for type chain');
            nodeType='Structure';
        end

        function allowed=isDragAllowed(this)%#ok<MANU>

            allowed=false;
        end

        function allowed=isDropAllowed(this)%#ok<MANU>

            allowed=true;
        end
    end

    methods(Access=protected)
        function dlgSchema=customizeDialogSchema(~,dlgSchema)

            assert(strcmp(dlgSchema.Items{1}.Items{2}.Tag,'grpCodeGen_tag'),...
            'Unexpected widget for codegen panel');
            dlgSchema.Items{1}.Items(2)=[];
        end
    end

    methods(Access=private)
        function generateChildNodes(this)
            childElements=this.InterfaceDictElement.Elements;
            this.Children=...
            sl.interface.dictionaryApp.node.StructElementNode.empty(...
            0,length(childElements));
            parent=this;
            for elemIdx=1:length(childElements)
                this.Children(elemIdx)=...
                sl.interface.dictionaryApp.node.StructElementNode(...
                childElements(elemIdx),parent,...
                this.DictObj,this.PlatformKind,this.Studio);
            end
        end
    end
end


