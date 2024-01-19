classdef InterfaceElementNode<handle

    properties
        ElementId;
        InterfaceElements;
        ParentNode;
        ChildNodes;
        CheckState;
    end


    properties
        CHECKED='checked';
        UNCHECKED='unchecked';
    end


    methods
        function this=InterfaceElementNode(id,elements,parentNode,checked)

            this.ElementId=id;
            this.InterfaceElements=elements;
            this.ParentNode=parentNode;
            this.ChildNodes={};

            if checked
                this.CheckState=this.CHECKED;
            else
                this.CheckState=this.UNCHECKED;
            end
        end


        function setChildren(this,children)
            this.ChildNodes=children;
        end


        function checked=isChecked(this)
            checked=strcmpi(this.CheckState,this.CHECKED);
        end


        function setChecked(this,dlg,tag)
            this.setCheckState(dlg,tag,this.CHECKED);
        end


        function setCheckState(this,dlg,tag,checkState)
            assert(strcmpi(checkState,this.CHECKED)||strcmpi(checkState,this.UNCHECKED));
            this.setCheckedInternal(dlg,tag,checkState);
            this.setChildrenChecked(dlg,tag,checkState);
            this.setParentCheckState(dlg,tag);
        end


        function label=getDisplayLabel(this)
            label=this.InterfaceElements(end).getName();
        end


        function id=nextSiblingID(this)
            if isempty(this.ChildNodes)
                id=this.ElementId+1;
            else
                id=this.ChildNodes{end}.nextSiblingID();
            end
        end


        function id=getID(this)
            id=this.ElementId;
        end


        function num=getNumChildren(this)
            num=numel(this.ChildNodes);
        end


        function has=hasChildren(this)
            has=this.getNumChildren()>0;
        end


        function children=getHierarchicalChildren(this)
            children=this.ChildNodes;
        end


        function tf=isCheckable(~)
            tf=true;
        end


        function state=getCheckState(this)
            state=this.CheckState;
        end


        function addInterfaceIfSelected(this,portEvent)
            if this.isChecked
                portEvent.addNestedInterfaceElements(this.InterfaceElements);
            else
                for idx=1:numel(this.ChildNodes)
                    this.ChildNodes{idx}.addInterfaceIfSelected(portEvent);
                end
            end
        end
    end


    methods(Access=private)
        function setCheckedInternal(this,dlg,tag,checked)
            this.CheckState=checked;
            dlg.setItemCheckState(tag,this.ElementId,checked);
        end


        function setChildrenChecked(this,dlg,tag,checked)
            for idx=1:numel(this.ChildNodes)
                this.ChildNodes{idx}.setChildrenChecked(dlg,tag,checked);
                this.ChildNodes{idx}.setCheckedInternal(dlg,tag,checked);
            end
        end


        function setParentCheckState(this,dlg,tag)
            if isempty(this.ParentNode)
                return;
            end

            if all(cellfun(@isChecked,this.ParentNode.ChildNodes))
                checkState=this.CHECKED;
            else
                checkState=this.UNCHECKED;
            end
            this.ParentNode.setCheckedInternal(dlg,tag,checkState);
            this.ParentNode.setParentCheckState(dlg,tag);
        end
    end
end


