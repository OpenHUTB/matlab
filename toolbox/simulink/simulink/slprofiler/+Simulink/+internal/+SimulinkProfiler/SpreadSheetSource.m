classdef SpreadSheetSource<handle
    properties
        mData=[];
    end

    methods
        function this=SpreadSheetSource(treeData)
            this.mData=treeData;
        end

        function children=getChildren(obj,~)
            children=obj.mData;
        end

        function resolved=resolveSourceSelection(this,selections,~,~)
            resolved=selections;
            try
                if numel(selections)==1
                    if iscell(selections)
                        selections=selections{1};
                    end
                    name=selections.getFullName;
                else
                    name=selections{end}.getFullName;
                end

                name=strrep(name,newline,' ');
                resolved=Simulink.internal.SimulinkProfiler.SpreadSheetSource.searchTreeForName(this.getChildren(),name);
                if isempty(resolved)
                    resolved=selections;
                end
            catch err %#ok<NASGU> % Need to do this or MATLAB may crash
            end
        end
    end

    methods(Static)

        function match=searchTreeForName(tree,name)
            match={};
            if strcmp(tree.objectPath{end},name)
                match{end+1}=tree;
            else
                children=tree.getChildren();
                for n=1:numel(children)
                    m=Simulink.internal.SimulinkProfiler.SpreadSheetSource.searchTreeForName(children(n),name);
                    if~isempty(m)


                        match=[match,m];%#ok<AGROW>
                    end
                end
            end
        end

    end
end
