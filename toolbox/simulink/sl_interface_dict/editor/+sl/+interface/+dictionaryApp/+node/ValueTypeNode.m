classdef ValueTypeNode<sl.interface.dictionaryApp.node.DataTypeNode




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

    properties(Dependent,Access=public)

        DataType;
    end

    methods
        function name=get.DataType(this)
            name=this.getPropValue('DataType');
        end

        function set.DataType(~,~)
            assert(false,'Cannot set datatype of node');
        end
    end

    methods(Access=public)
        function nodeType=getNodeType(~)
            nodeType='ValueType';
        end

        function setPropValue(this,propName,propValue)
            propName=this.getRealPropName(propName);
            if strcmp(propName,DAStudio.message('Simulink:busEditor:PropDataType'))&&...
                strcmp(propValue,DAStudio.message('Simulink:DataType:RefreshDataTypeInWorkspace'))


                typeEditorObj=this.getTypeEditorObject();
                typeEditorObj.setPropValue(propName,propValue);
            else
                setPropValue@sl.interface.dictionaryApp.node.DataTypeNode(this,propName,propValue);
            end
        end
    end

    methods(Access=protected)
        function dlgSchema=customizeDialogSchema(this,dlgSchema)
            dlgSchema=this.setDataTypeObjectProperty(dlgSchema);
        end
    end

    methods(Access=private)
        function dlgSchema=setDataTypeObjectProperty(~,dlgSchema)
            assert(strcmp(dlgSchema.Items{1}.Items{1}.Items{1}.Items{2}.Tag,...
            'DataType'),'Unexpected widget for DataType');
            dlgSchema.Items{1}.Items{1}.Items{1}.Items{2}.ObjectProperty='Type';
        end
    end
end


