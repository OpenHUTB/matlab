classdef Autofill<handle




















    properties(SetObservable)

        Path{matlab.internal.validation.mustBeASCIICharRowVector(Path,'Path')}='';
        SelectedTreeItem{matlab.internal.validation.mustBeASCIICharRowVector(SelectedTreeItem,'SelectedTreeItem')}='';

        TreeItems=[];

        Parent=[];

        ParentDialog=[];

        EnableBrowser(1,1)int16{mustBeReal}=0;

        AllowBrowseButton(1,1)int16{mustBeReal}=0;
    end

    methods
        function set.Path(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Path=value;
        end
        function set.SelectedTreeItem(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','SelectedTreeItem')
            obj.SelectedTreeItem=value;
        end

        function set.Parent(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','Parent')
            obj.Parent=value;
        end

        function set.ParentDialog(obj,value)

            validateattributes(value,{'handle'},{'scalar'},'','ParentDialog')
            obj.ParentDialog=value;
        end

        function set.EnableBrowser(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','EnableBrowser')
            value=round(value);
            obj.EnableBrowser=value;
        end

        function set.AllowBrowseButton(obj,value)

            validateattributes(value,{'numeric'},{'scalar'},'','AllowBrowseButton')
            value=round(value);
            obj.AllowBrowseButton=value;
        end
    end

    methods
        onBrowse(this,dialog)
        onClickNode(this,~)
    end

    methods(Hidden)

        dlgstruct=getDialogSchema(h,~)
        onCancel(~,dialog)
        onFill(this,dialog)
        onHelp(~)
    end
end

