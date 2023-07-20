classdef AbstractTabAdapter<handle






    properties(Abstract,Constant,Access=protected)
        TabId;
    end

    properties(Abstract,Access=protected)
        DefaultEntryName;
    end

    methods(Abstract,Access=public)
        addEntry(this);
        deleteEntry(this,selectedNode);
        node=getNode(this,entryName);
        canPaste=canPaste(this,nodes);
        copy(this,nodesToCopy);
    end

    methods(Abstract,Access=public,Static)


        columns=getColumnNames();
    end

    methods(Abstract,Access=protected)
        entryNames=getEntryNames(this);
        addedEntry=addEntryForSourceObj(this,sourceObj);
    end

    methods(Access=public)

        function nodes=getNodes(this)
            entryNames=this.getEntryNames();
            nodes=cell(length(entryNames),1);
            for entryIdx=1:length(entryNames)
                nodes{entryIdx}=...
                this.getNode(entryNames{entryIdx});
            end
        end

        function tabId=getTabId(this)
            tabId=this.TabId;
        end
    end

    methods(Access=protected)

        function defaultName=getDefaultEntryName(this)

            protectedNames=this.getEntryNames();
            defaultName=sl.interface.dictionaryApp.tab.AbstractTabAdapter....
            calcUniqueName(this.DefaultEntryName,protectedNames);
        end
    end

    methods(Static,Access=protected)
        function entryName=calcUniqueName(entryName,protectedNames)
            startName=entryName;
            count=1;
            while ismember(entryName,protectedNames)
                entryName=strcat(startName,num2str(count));
                count=count+1;
            end
        end
    end
end
