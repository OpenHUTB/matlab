classdef AliasTypeNode<sl.interface.dictionaryApp.node.DataTypeNode



    properties(Constant,Access=protected)


        GenericPropertyNames cell={...
        sl.interface.dictionaryApp.node.PackageString.NameColHeader,...
        sl.interface.dictionaryApp.node.PackageString.TypeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DescriptionColHeader};
        TypePropName=sl.interface.dictionaryApp.node.PackageString.BaseTypeProp;
    end

    properties(Dependent,Access=public)

        BaseType;
    end

    methods
        function name=get.BaseType(this)
            name=this.getPropValue('BaseType');
        end

        function set.BaseType(~,~)
            assert(false,'Cannot set datatype of node');
        end
    end

    methods(Access=public)
        function this=AliasTypeNode(interfaceDictObj,dictObj,platformKind,studio)
            this=this@sl.interface.dictionaryApp.node.DataTypeNode(...
            interfaceDictObj,dictObj,platformKind,studio);

            this.UDTAssistOpen=struct('tags',{{'BaseType'}},'status',{{false}});
            this.UDTIPOpen=struct('tags',{{'BaseType'}},'status',{{false}});
        end

        function nodeType=getNodeType(~)
            nodeType='AliasType';
        end

        function availableDataTypes=getAvailableDataTypes(this)


            availableDataTypes=getAvailableDataTypes@sl.interface.dictionaryApp.node.DesignNode(this);
            availableDataTypes=setdiff(availableDataTypes,this.Name,'stable');
        end
    end

    methods(Access=protected)
        function dlgSchema=customizeDialogSchema(this,dlgSchema)
            dlgSchema=this.setDataTypeObjectProperty(dlgSchema);
            dlgSchema=this.removeCodeGenTab(dlgSchema);
        end
    end

    methods(Access=private)

        function dlgSchema=setDataTypeObjectProperty(~,dlgSchema)
            assert(strcmp(dlgSchema.Items{1}.Items{1}.Items{1}.Items{2}.Tag,...
            'BaseType'),'Unexpected widget for BaseType');
            dlgSchema.Items{1}.Items{1}.Items{1}.Items{2}.ObjectProperty='Type';
        end

        function dlgSchema=removeCodeGenTab(~,dlgSchema)
            assert(strcmp(dlgSchema.Items{1}.Items{2}.Tag,'TabCodeGen'),...
            'Unexpected widget for codegen tab');
            dlgSchema.Items{1}.Items(2)=[];
        end
    end
end
