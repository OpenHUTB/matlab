



classdef SaveLayoutDlg<vision.internal.uitools.OkCancelDlg

    properties
FileName
Tool
    end

    properties(Access=protected)
EditBox
    end

    methods
        function this=SaveLayoutDlg(tool)
            dlgTitle=vision.getMessage('vision:labeler:SaveLayout');

            this=this@vision.internal.uitools.OkCancelDlg(tool,dlgTitle);
            this.DlgSize=[300,150];
            this.Tool=tool;
            createDialog(this);

            if~useAppContainer
                uicontrol('Parent',this.Dlg,'Style','text',...
                'Units','normalized',...
                'Position',[0.1,0.55,0.75,0.35],...
                'HorizontalAlignment','left',...
                'String',vision.getMessage('vision:labeler:SaveLayoutDlgText'));

                this.EditBox=uicontrol('Parent',this.Dlg,'Style','edit',...
                'String','',...
                'Units','normalized',...
                'Position',[0.1,0.40,0.7,0.25],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','saveLayoutEditBox',...
                'FontAngle','normal',...
                'ForegroundColor',[0,0,0],...
                'Enable','on');

                this.EditBox.KeyPressFcn=@this.onKeyPress;
            else
                uilabel('Parent',this.Dlg,...
                'Position',[0.1,0.55,0.75,0.35].*[this.DlgSize,this.DlgSize],...
                'HorizontalAlignment','left',...
                'Text',vision.getMessage('vision:labeler:SaveLayoutDlgText'));

                this.EditBox=uieditfield('Parent',this.Dlg,...
                'Value','',...
                'Position',[0.1,0.40,0.7,0.25].*[this.DlgSize,this.DlgSize],...
                'HorizontalAlignment','left',...
                'BackgroundColor',[1,1,1],...
                'Tag','saveLayoutEditBox',...
                'FontAngle','normal',...
                'Enable','on',...
                'ValueChangedFcn',@(src,evt)this.updateEditBoxValue(src,evt),...
                'ValueChangingFcn',@(src,evt)this.updatingEditBoxValue(src,evt));

            end

        end
    end

    methods(Access=protected)
        function onOK(this,~,~)
            fileName=get(this.EditBox,'String');
            if isvarname(fileName)
                this.FileName=fileName;
                this.IsCanceled=false;
                close(this);
            else
                errorMessage=vision.getMessage('vision:labeler:InvalidLayoutName',fileName);
                dialogName=getString(message('vision:labeler:InvalidLayoutNameTitle'));
                vision.internal.labeler.handleAlert(this.Dlg,'errorWithWaitDlg',errorMessage,dialogName,this.Tool);
            end
        end

        function onKeyPress(this,~,evd)


            if useAppContainer

                if~validateKeyPressSupport(this,evd)
                    return;
                end
            end
            drawnow;
            switch(evd.Key)
            case{'return'}
                onOK(this);
            case{'escape'}
                onCancel(this);
            end

        end

        function updateEditBoxValue(this,~,evt)
            this.EditBox.Value=evt.Value;
        end

        function updatingEditBoxValue(this,~,evt)
            this.EditBox.Value=evt.Value;
        end
    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end