



classdef ExportDlg<vision.internal.uitools.OkCancelDlg
    properties
        VarName;
        VarFormat;
    end

    properties(Access=private)
        Prompt;
        EditBox;
        FormatPrompt;
        FormatComboBox;
        FormatLabel;

        PromptX=10;
        EditBoxX=207;
    end

    methods

        function this=ExportDlg(tool,paramsVarName,enableFormat)
            dlgTitle=vision.getMessage('vision:uitools:ExportTitle');
            this=this@vision.internal.uitools.OkCancelDlg(...
            tool,dlgTitle);

            this.VarName=paramsVarName;
            this.Prompt=getString(message('vision:uitools:ExportPrompt'));

            this.FormatPrompt=getString(message(...
            'vision:trainingtool:ExportFormatPrompt'));
            this.DlgSize=[400,150];
            createDialog(this);

            addParamsVarPrompt(this);
            addParamsVarEditBox(this);
            addFormatPrompt(this);
            addFormatComboBox(this,enableFormat);
        end


        function disableFormat(this)
            this.FormatLabel.Enable='off';
            this.FormatComboBox.Enable='off';
        end
    end

    methods(Access=private)

        function addParamsVarPrompt(this)
            uicontrol('Parent',this.Dlg,'Style','text',...
            'Position',[this.PromptX,78,200,20],...
            'HorizontalAlignment','left',...
            'String',this.Prompt,...
            'ToolTipString',...
            vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
        end


        function addParamsVarEditBox(this)
            if~isWebFigure(this)
                this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String',this.VarName,...
                'Position',[this.EditBoxX,77,180,25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','varEditBox',...
                'ToolTipString',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            else
                this.EditBox=uieditfield(this.Dlg,'Editable','on',...
                'HorizontalAlignment','left',...
                'Position',[this.EditBoxX,77,180,25],...
                'BackgroundColor',[1,1,1],...
                'Value',this.VarName,...
                'Tag','varEditBox',...
                'ToolTip',...
                vision.getMessage('vision:caltool:ExportParametersNameToolTip'));
            end
        end


        function addFormatPrompt(this)
            this.FormatLabel=uicontrol('Parent',this.Dlg,'Style','text',...
            'Position',[this.PromptX,48,200,20],...
            'HorizontalAlignment','left',...
            'String',this.FormatPrompt,...
            'ToolTipString',...
            getString(message('vision:imageLabeler:ExportFormatToolTip')));
        end


        function addFormatComboBox(this,enableFormat)
            formats={getString(message('vision:imageLabeler:GroundTruthFormat')),...
            getString(message('vision:imageLabeler:TableFormat'))};

            if~isWebFigure(this)
                this.FormatComboBox=uicontrol('Parent',this.Dlg,'Style','popupmenu',...
                'String',formats,...
                'Position',[this.EditBoxX,47,180,25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','formatComboBox',...
                'ToolTipString',...
                getString(message('vision:imageLabeler:ExportFormatToolTip')));
            else
                this.FormatComboBox=uidropdown('Parent',this.Dlg,...
                'Items',formats,...
                'Position',[this.EditBoxX,47,180,25],...
                'BackgroundColor',[1,1,1],...
                'Tag','formatComboBox',...
                'ItemsData',[1,2],...
                'Value',1,...
                'ToolTip',...
                getString(message('vision:imageLabeler:ExportFormatToolTip')));
            end

            if~enableFormat
                this.disableFormat();
            end
        end
    end


    methods(Access=protected)

        function onOK(this,~,~)
            if~isWebFigure(this)
                this.VarName=get(this.EditBox,'String');
                this.VarFormat=this.FormatComboBox.String{this.FormatComboBox.Value};
            else
                this.VarName=get(this.EditBox,'Value');
                this.VarFormat=this.FormatComboBox.Items{this.FormatComboBox.Value};
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

function tf=isWebFigure(this)
    tf=isa(getCanvas(this.Dlg),'matlab.graphics.primitive.canvas.HTMLCanvas');
end