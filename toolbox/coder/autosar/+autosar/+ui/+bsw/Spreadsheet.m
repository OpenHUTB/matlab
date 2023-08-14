classdef Spreadsheet<autosar.ui.bsw.SpreadsheetBase




    properties(Access=private)
ChildrenUserDataName
    end

    properties(Dependent)
UIChildren
    end

    methods(Abstract,Access=protected)
        aChildren=loadChildrenImpl(this,blkH)
        clearUnusedValues(this,blkH)
    end

    methods
        function this=Spreadsheet(dlgSource,userDataName)
            this=this@autosar.ui.bsw.SpreadsheetBase(dlgSource);
            this.ChildrenUserDataName=userDataName;
        end

        function aChildren=getChildren(this)
            if isfield(this.DlgSource.UserData,this.ChildrenUserDataName)


                aChildren=this.DlgSource.UserData.(this.ChildrenUserDataName);
                return;
            end

            this.DlgSource.UserData.(this.ChildrenUserDataName)=[];

            aChildren=this.loadChildren();
        end

        function aChildren=loadChildren(this)
            blkH=this.DlgSource.getBlock().Handle;

            this.clearUnusedValues(blkH);

            aChildren=this.loadChildrenImpl(blkH);

            this.DlgSource.UserData.(this.ChildrenUserDataName)=aChildren;
        end

        function aResolved=resolveSourceSelection(~,aSelections,~,~)
            aResolved=aSelections;
        end

        function uiChildren=get.UIChildren(this)
            uiChildren=this.DlgSource.UserData.(this.ChildrenUserDataName);
        end
    end

end
