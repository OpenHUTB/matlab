classdef SwAddrMethodsNode<autosar.internal.dictionaryApp.node.AbstractAUTOSARNode




    methods(Access=public)
        function nodeType=getNodeType(~)
            nodeType='SwAddrMethod';
        end


        function dlgStruct=getDialogSchema(this)
            dlgStruct=this.M3ITerminalNode.getDialogSchema(this);


            nameEdit.Tag='SwAddrMethodName';
            nameEdit.Type='edit';
            nameEdit.Name=[sl.interface.dictionaryApp.node.PackageString.NameColHeader,':'];
            nameEdit.Value=this.Name;
            nameEdit.RowSpan=[1,1];
            nameEdit.ColSpan=[1,25];
            nameEdit.Graphical=1;
            nameEdit.Mode=1;
            nameEdit.Enabled=1;
            nameEdit.ObjectProperty='Name';


            sectionTypeCombo.Tag='SectionTypeCombo';
            sectionTypeCombo.Type='combobox';
            sectionTypeCombo.Name='SectionType:';


            sectionTypeCombo.Entries=union(this.getPropValue('SectionType'),...
            this.M3ITerminalNode.getPropAllowedValues('SectionType'));
            sectionTypeCombo.RowSpan=[2,2];
            sectionTypeCombo.ColSpan=[1,25];
            sectionTypeCombo.Graphical=1;
            sectionTypeCombo.Mode=1;
            sectionTypeCombo.Enabled=1;
            sectionTypeCombo.Editable=0;
            sectionTypeCombo.ObjectProperty='SectionType';



            assert(strcmp(dlgStruct.Items{3}.Tag,'packageEditButton'),...
            'Unexpected Widget');
            dlgStruct.Items(3)=[];
            dlgStruct.Items{2}.ColSpan=[3,25];


            dlgStruct.Items=[{nameEdit,sectionTypeCombo},dlgStruct.Items];
            dlgStruct.Items{3}.RowSpan=[3,3];
            dlgStruct.Items{4}.RowSpan=[3,3];
            dlgStruct.EmbeddedButtonSet={''};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.DialogMode='Slim';
            dlgStruct.DialogTag=this.getDialogTag();
        end

        function objType=getObjectType(~)
            objType='SwAddrMethod';
        end

        function allowed=isDragAllowed(this)%#ok<MANU>

            allowed=false;
        end

        function allowed=isDropAllowed(this)%#ok<MANU>

            allowed=false;
        end

        function canPaste=canPaste(~,node)



            canPaste=...
            isa(node,'autosar.internal.dictionaryApp.node.SwAddrMethodsNode');
        end
    end

    methods(Access=protected)
        function initializeMimeData(~)
            assert(false,'Should not get here because SwAddrMethod does not support drag-n-drop')
        end
    end

    methods(Static,Access=public)
        function columnNames=getColumnNames()

            columnNames={sl.interface.dictionaryApp.node.PackageString.NameProp,...
            DAStudio.message('autosarstandard:sharedDictGUI:SwAddrMethodNodeSectionType'),...
            DAStudio.message('autosarstandard:sharedDictGUI:SwAddrMethodNodeXmlFile')};
        end
    end
end


