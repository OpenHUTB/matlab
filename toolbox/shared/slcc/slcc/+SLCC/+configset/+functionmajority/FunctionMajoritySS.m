


classdef FunctionMajoritySS<handle
    properties(SetAccess=private,GetAccess=public)
        dlgSrc;
    end

    properties(Access=private)
        children;
        currentSelections;
    end

    methods
        function this=FunctionMajoritySS(dlgSrc,allFcnMajorityEntries)
            import SLCC.configset.functionmajority.FunctionMajoritySSRow;
            import SLCC.configset.functionmajority.MajorityUIOpts;

            this.dlgSrc=dlgSrc;

            this.children=FunctionMajoritySSRow.empty;
            numEntries=numel(allFcnMajorityEntries);
            for k=1:numEntries
                this.children(k)=FunctionMajoritySSRow(this,allFcnMajorityEntries(k));
            end
        end

        function aChildren=getChildren(this)
            aChildren=this.children;
        end
    end

    methods
        function ret=handleSelectionChanged(this,ssTag,selections,~)%#ok<INUSL>
            this.currentSelections=selections;
            ret=true;
        end

        function newChildren=addNewChildren(this,aFcnMajorityEntry)
            import SLCC.configset.functionmajority.FunctionMajoritySSRow;
            newChildren=FunctionMajoritySSRow(this,aFcnMajorityEntry);
            this.children=[newChildren,this.children];
            this.dlgSrc.thisDlg.enableApplyButton(true,false);
        end

        function removalStatus=removeSelectedChildren(this)
            import SLCC.configset.functionmajority.FunctionMajoritySSRow;
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

        function allFcnMajorityEntries=getAllFuncionMajorityEntries(this)
            allFcnMajorityEntries=[];
            numEntries=numel(this.children);
            if numEntries<1
                return;
            end
            allFcnMajorityEntries=struct('FunctionName',{},'ArrayLayout',{});

            for k=1:numEntries
                allFcnMajorityEntries(k)=this.children(k).getFuncionMajorityEntry();
            end
        end
    end
end

