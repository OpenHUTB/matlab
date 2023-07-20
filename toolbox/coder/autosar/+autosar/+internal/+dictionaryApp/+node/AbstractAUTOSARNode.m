classdef(Abstract)AbstractAUTOSARNode<sl.interface.dictionaryApp.node.AbstractNode





    properties(Access=protected)

        M3ITerminalNode(1,1);
    end

    properties(Access=private)
        Studio sl.interface.dictionaryApp.StudioApp;
    end

    methods(Access=public)
        function this=AbstractAUTOSARNode(m3iObj)
            this.M3ITerminalNode=autosar.ui.metamodel.M3ITerminalNode(...
            m3iObj,m3iObj.MetaClass.name);
        end

        function columnProperties=getPIPropertyNames(this)
            columnProperties=this.M3ITerminalNode.getChildProperties();
        end

        function isHier=isHierarchical(this)
            isHier=this.M3ITerminalNode.isHierarchical();
        end

        function displayLabel=getDisplayLabel(this)
            displayLabel=this.M3ITerminalNode.getDisplayLabel();
        end

        function icon=getDisplayIcon(this)
            icon=this.M3ITerminalNode.getDisplayIcon();
        end

        function dialogTag=getDialogTag(this)
            dialogTag=[this.getNodeType(),'Dialog'];
        end

        function children=getHierarchicalChildren(this)
            children=this.M3ITerminalNode.getHierarchicalChildren();
        end

        function isValid=isValidProperty(this,columnName)
            isValid=this.M3ITerminalNode.isValidProperty(columnName);
        end

        function isReadonly=isReadonlyProperty(this,columnName)
            isReadonly=this.M3ITerminalNode.isReadonlyProperty(columnName);
        end

        function dataType=getPropDataType(this,columnName)
            dataType=this.M3ITerminalNode.getPropDataType(columnName);
            if strcmp(dataType,'edit')
                dataType='string';
            end
        end

        function values=getPropAllowedValues(this,columnName)
            values=this.M3ITerminalNode.getPropAllowedValues(columnName);
        end

        function propVal=getPropValue(this,columnName)
            propVal=this.M3ITerminalNode.getPropValue(columnName);
        end

        function setPropValue(this,columnName,propVal)
            this.M3ITerminalNode.setPropValue(columnName,propVal);
        end

        function isValid=isValid(this)
            m3iObj=this.getM3IObject();
            isValid=m3iObj.isvalid();
        end

        function m3iObj=getM3IObject(this)
            m3iObj=this.M3ITerminalNode.getM3iObject();
        end

        function name=getCachedName(this)
            name=this.M3ITerminalNode.Name;
        end

        function contextMenu=getContextMenuItems(this)




            studio=this.getStudio();
            typeChain=studio.getStudioWindow.getContextObject.TypeChain;
            commandStrProvider=studio.getCommandStrProvider();

            template=struct('label','','checkable',false,'checked',false,'command','','accel','','enabled',true,'icon','','visible',true);

            sepItem=template;
            sepItem.label='separator';

            rowIdx=1;

            if any(strcmp('cutActionEnable',typeChain))
                cutItem=template;
                cutItem.label=DAStudio.message('Simulink:busEditor:Cut');
                cutItem.command=commandStrProvider.getCommandStr('cut');
                cutItem.accel='Ctrl+X';
                cutItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('cut_action_16.png');
                contextMenu(rowIdx)=cutItem;
                rowIdx=rowIdx+1;
            end

            if any(strcmp('copyActionEnable',typeChain))
                copyItem=template;
                copyItem.label=DAStudio.message('Simulink:busEditor:Copy');
                copyItem.command=commandStrProvider.getCommandStr('copy');
                copyItem.accel='Ctrl+C';
                copyItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('copy_action_16.png');
                contextMenu(rowIdx)=copyItem;
                rowIdx=rowIdx+1;
            end

            if any(strcmp('pasteActionEnable',typeChain))
                pasteItem=template;
                pasteItem.label=DAStudio.message('Simulink:busEditor:Paste');
                pasteItem.command=commandStrProvider.getCommandStr('paste');
                pasteItem.accel='Ctrl+V';
                pasteItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('paste_action_16.png');
                contextMenu(rowIdx)=pasteItem;
                rowIdx=rowIdx+1;
            end

            contextMenu(rowIdx)=sepItem;
            rowIdx=rowIdx+1;

            if any(strcmp('deleteActionEnable',typeChain))
                deleteItem=template;
                deleteItem.label=DAStudio.message('Simulink:busEditor:Delete');
                deleteItem.command=commandStrProvider.getCommandStr('deleteEntry');
                deleteItem.accel='DEL';
                deleteItem.icon=Simulink.typeeditor.utils.getBusEditorResourceFile('delete_action_16.png');
                contextMenu(rowIdx)=deleteItem;
            end
        end
    end

    methods(Access=protected)
        function studio=getStudio(this)
            if isempty(this.Studio)

                m3iModel=this.M3ITerminalNode.M3iObject.modelM3I;
                itfDictFilePath=...
                Simulink.AutosarDictionary.ModelRegistry.getDDFileSpecForM3IModel(m3iModel);
                this.Studio=...
                sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(...
                itfDictFilePath);
            end
            studio=this.Studio;
        end
    end
end


