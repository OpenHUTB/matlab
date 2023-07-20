


classdef DeterministicFunctionsSS<handle
    properties(SetAccess=private,GetAccess=public)
        dlgSrc;
    end

    properties(Access=private)
        children;
        currentSelections;
    end

    methods
        function this=DeterministicFunctionsSS(dlgSrc,allFcnsForUI)
            import SLCC.configset.deterministicFunctions.DeterministicFunctionsSSRow;

            this.dlgSrc=dlgSrc;

            this.children=DeterministicFunctionsSSRow.empty;
            if isempty(strtrim(allFcnsForUI))
                return
            end
            allFcns=strsplit(allFcnsForUI,',');
            numEntries=numel(allFcns);
            for k=1:numEntries
                this.children(k)=DeterministicFunctionsSSRow(this,allFcns{k});
            end
        end

        function aChildren=getChildren(this)
            aChildren=this.children;
        end
    end

    methods
        function ret=handleSelectionChanged(this,tag,selections,~)%#ok<INUSL>
            this.currentSelections=selections;
            ret=true;
        end

        function newChildren=addNewChildren(this,aFcnName)
            import SLCC.configset.deterministicFunctions.DeterministicFunctionsSSRow;
            newChildren=DeterministicFunctionsSSRow(this,aFcnName);
            this.children=[newChildren,this.children];
            this.dlgSrc.thisDlg.enableApplyButton(true,false);
        end

        function removalStatus=removeSelectedChildren(this)
            removalStatus=false;

            if numel(this.currentSelections)<1||numel(this.children)<1
                return;
            end


            toDelete=false(size(this.children));
            for j=1:numel(this.currentSelections)
                for k=1:numel(this.children)
                    if this.currentSelections{j}==this.children(k)
                        toDelete(k)=true;
                    end
                end
            end

            if~any(toDelete)
                return;
            end


            childrenToDelete=this.children(toDelete);
            newChildren=this.children(~toDelete);
            this.children=newChildren;
            delete(childrenToDelete);
            removalStatus=true;

        end

        function allFcnEntries=getAllFunctionEntries(this)
            allFcnEntries='';
            numEntries=numel(this.children);
            if numEntries<1
                return;
            end
            for k=1:numEntries
                allFcnEntries=[allFcnEntries,',',this.children(k).getDeterministicFunctionsEntry()];%#ok<AGROW>
            end
            allFcnEntries(1)=[];
        end
    end
end

