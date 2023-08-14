classdef EnumTypeNode<sl.interface.dictionaryApp.node.DataTypeNode




    properties(Constant,Access=protected)


        GenericPropertyNames cell={...
        sl.interface.dictionaryApp.node.PackageString.NameColHeader,...
        sl.interface.dictionaryApp.node.PackageString.TypeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DescriptionColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DefaultValueHeader};
        TypePropName=sl.interface.dictionaryApp.node.PackageString.StorageTypeProp;
    end

    methods(Access=public)
        function nodeType=getNodeType(~)
            nodeType='Enumeration';
        end

        function userData=getUserData(this)
            typeEditorObj=this.getTypeEditorObject();
            userData=typeEditorObj.getUserData();
        end

        function setUserData(this,userData)
            typeEditorObj=this.getTypeEditorObject();
            typeEditorObj.setUserData(userData);
        end
    end

    methods(Access=protected)
        function dlgSchema=customizeDialogSchema(this,dlgSchema)
            dlgSchema=this.removeSourcePanel(dlgSchema);
            dlgSchema=this.removeCodeGenTab(dlgSchema);
            dlgSchema=this.removeCallbacks(dlgSchema);


            dlgSchema.DisableDialog=false;
        end
    end

    methods(Access=private)
        function dlgSchema=removeSourcePanel(~,dlgSchema)

            assert(length(dlgSchema.Items{1}.Items{2}.Items{1}.Items)==4,...
            'Unexpected source panel widget');
            dlgSchema.Items{1}.Items{2}.Items(1)=[];
        end

        function dlgSchema=removeCodeGenTab(~,dlgSchema)
            assert(strcmp(dlgSchema.Items{1}.Items{1}.Items{2}.Tag,'TabCodeGen'),...
            'Unexpected widget for codegen tab');
            dlgSchema.Items{1}.Items{1}.Items(2)=[];
        end

        function dlgSchema=removeCallbacks(~,dlgSchema)


            dlgSchema=rmfield(dlgSchema,{'PreApplyMethod','PreApplyArgs',...
            'PreApplyArgsDT','PostApplyMethod','PostApplyArgs',...
            'PostApplyArgsDT','CloseMethod','CloseMethodArgs',...
            'CloseMethodArgsDT','PostRevertMethod','PostRevertArgs',...
            'PostRevertArgsDT'});
        end
    end
end
