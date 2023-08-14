classdef ElementAdapter<Simulink.typeeditor.app.Element





    properties(Constant,Access=public)
        GenericPropertyNames cell={...
        sl.interface.dictionaryApp.node.PackageString.NameColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DataTypeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DimensionsColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DimensionsModeColHeader,...
        sl.interface.dictionaryApp.node.PackageString.UnitColHeader,...
        sl.interface.dictionaryApp.node.PackageString.ComplexityColHeader,...
        sl.interface.dictionaryApp.node.PackageString.MinColHeader,...
        sl.interface.dictionaryApp.node.PackageString.MaxColHeader,...
        sl.interface.dictionaryApp.node.PackageString.DescriptionColHeader};
    end

    properties(Access=private)
        Studio sl.interface.dictionaryApp.StudioApp;
        ItfEditorNode;
    end

    methods(Access=public)
        function this=ElementAdapter(itfEditorNode,parent,studio)
            this=this@Simulink.typeeditor.app.Element(itfEditorNode.getDataObject(),...
            parent);
            this.NotifyListener=false;
            this.ItfEditorNode=itfEditorNode;
            this.Studio=studio;
        end

        function editor=getEditor(this)


            editor=this.Studio;
        end

        function children=getChildren(~,~)


            children=[];
        end

        function dtVars=validateDataTypeList(this,dtVars)


            dtVars=validateDataTypeList@Simulink.typeeditor.app.Element(this,dtVars);
            dtVars=this.ItfEditorNode.filterInterfacesFromTypes(dtVars);
        end

        function dialogTag=getDialogTag(this)
            dialogTag=this.DialogTag;
        end
    end
end
