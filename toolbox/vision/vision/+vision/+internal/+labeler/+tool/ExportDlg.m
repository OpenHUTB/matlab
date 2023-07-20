



classdef ExportDlg<vision.internal.uitools.OkCancelDlg
    properties
        VarName;
        VarTitle;
    end

    properties(Access=private)
        Prompt;
        EditBox;

        PromptX=10;
        EditBoxX=160;
    end

    methods

        function this=ExportDlg(tool,paramsVarName)
            dlgTitle=vision.getMessage('vision:uitools:ExportTitle');
            this=this@vision.internal.uitools.OkCancelDlg(...
            tool,dlgTitle);

            this.VarName=paramsVarName;
            this.Prompt=getString(message('vision:uitools:ExportPrompt'));

            this.DlgSize=[300,150];
            createDialog(this);

            addParamsVarPrompt(this);
            addParamsVarEditBox(this);
        end
    end

    methods(Access=private)

        function addParamsVarPrompt(this)
            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Position',[this.PromptX,75,220,20],...
                'HorizontalAlignment','left',...
                'String',this.Prompt,...
                'ToolTipString',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            else
                uilabel('Parent',this.Dlg,...
                'Position',[this.PromptX,75,220,20],...
                'HorizontalAlignment','left',...
                'Text',this.Prompt,...
                'ToolTip',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            end

        end


        function addParamsVarEditBox(this)
            if useAppContainer
                this.EditBox=uieditfield(this.Dlg,'Editable','on',...
                'HorizontalAlignment','left',...
                'Position',[this.EditBoxX,75,120,25],...
                'BackgroundColor',[1,1,1],...
                'Value',this.VarName,...
                'Tag','varEditBox',...
                'ToolTip',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            else
                this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.VarName,...
                'Position',[this.EditBoxX,75,120,25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varEditBox',...
                'ToolTipString',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            end
        end
    end

    methods(Access=protected)

        function onOK(this,~,~)
            if useAppContainer
                this.VarName=get(this.EditBox,'Value');
            else
                this.VarName=get(this.EditBox,'String');
            end

            if~isvarname(this.VarName)
                msg=getString(message('vision:uitools:invalidExportVariable'));
                title=getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'error',msg,title);
            else
                this.IsCanceled=false;
                close(this);
            end
        end
    end
end
function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end