classdef ConstantsTabAdapter<sl.interface.dictionaryApp.tab.AbstractArchTabAdapter




    properties(Constant,Access=protected)
        TabId='ConstantsTab';
    end

    properties(Access=protected)
        DefaultEntryName='Constant';
    end

    methods(Static,Access=public)
        function cols=getColumnNames()

            cols={'Name','Value','DataType','Description'};
        end
    end

    methods(Access=public)
        function addEntry(this,~)
            this.DictObj.addConstant(this.getDefaultEntryName());
        end

        function deleteEntry(this,selectedNode)
            constantName=selectedNode.getPropValue('Name');
            this.DictObj.removeConstant(constantName);
        end

        function canPaste=canPaste(~,~)
            canPaste=false;
        end
    end

    methods(Access=protected)
        function addedEntry=addEntryForSourceObj(~,~,~)

            addedEntry=[];
        end
    end

    methods(Access=protected)
        function entryNames=getEntryNames(this)
            entryNames=this.DictObj.getConstantNames();
        end

        function entry=getEntry(this,name)
            entry=this.DictObj.getConstant(name);
        end
    end
end


