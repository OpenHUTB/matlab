classdef HdlBrowser<handle

















    properties(SetObservable,GetObservable)

        SelectedTreeItem{matlab.internal.validation.mustBeASCIICharRowVector(SelectedTreeItem,'SelectedTreeItem')}='';

        TreeItems=[];

        TableItems=[];

        ParentDialog=[];

        ShowPorts=false;

        UserData=[];
        Path{matlab.internal.validation.mustBeASCIICharRowVector(Path,'Path')}='';
    end


    methods
        function this=HdlBrowser(UserData,ParentDlg,ShowPorts)



            this.UserData=UserData;
            this.ParentDialog=ParentDlg;
            this.TreeItems=this.UserData.HdlHierarchy;
            this.TableItems=cell(0,2);
            this.ShowPorts=ShowPorts;
        end



    end























    methods(Hidden)
        dlgstruct=getDialogSchema(this,~)
        onCancel(~,dialog)
        onClickNode(this,dlg)
        onFill(this,dlg)
        onHelp(~)
    end

    methods
        function set.Path(obj,value)
            obj.Path=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.SelectedTreeItem(obj,value)
            obj.SelectedTreeItem=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end

