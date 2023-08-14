classdef ObjectAdapter<Simulink.typeeditor.app.Object





    properties(Constant,Access=public)
        GenericPropertyNames cell=...
        {sl.interface.dictionaryApp.node.PackageString.NameColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DescriptionColHeader};
    end

    properties(Access=private)
        Studio sl.interface.dictionaryApp.StudioApp;
        ItfEditorNode;
    end

    methods(Access=public)
        function this=ObjectAdapter(itfEditorNode,dataObj,studio)
            sourceStub=studio.getSource();
            this=this@Simulink.typeeditor.app.Object(itfEditorNode.Name(),dataObj,sourceStub);
            this.ItfEditorNode=itfEditorNode;
            this.Studio=studio;

            this.getChildren();
        end

        function editor=getEditor(this)


            editor=this.Studio;
        end

        function dialogTag=getDialogTag(this)
            dialogTag=this.DialogTag;
        end

        function dtVars=validateDataTypeList(this,dtVars)


            dtVars=this.ItfEditorNode.filterInterfacesFromTypes(dtVars);
        end
    end

    methods(Access=protected)
        function saveEnumEntry(this,dlg)

            studioApp=this.getEditor();
            studioApp.disableSLDDListener();
            this.EnumDDGSource.saveEntry(dlg,this);
            studioApp.refreshPIDialog();
            studioApp.refreshSourceObj();
        end

        function setEnumPropValue(this)

            studioApp=this.getEditor();
            studioApp.disableSLDDListener();
            this.EnumDDGSource.setPropValue(propName,propValue);
        end
    end

    methods(Access=private)
        function dlgSchema=removeCodeGenPanel(~,dlgSchema)
            assert(strcmp(dlgSchema.Items{1}.Items{2}.Tag,'grpCodeGen_tag'),...
            'Unexpected widget for codegen panel');
            dlgSchema.Items{1}.Items(2)=[];
        end
    end
end


