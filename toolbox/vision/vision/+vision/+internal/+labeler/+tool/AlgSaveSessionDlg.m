



classdef AlgSaveSessionDlg<vision.internal.uitools.AbstractDlg

    properties
        AcceptSave;
        CancelSave;
        NoButton;
        CancelButton;

        IsAcceptSave=true;
        IsNo=false;
        IsCancel=false;
    end

    properties(Access=private)
        InitialDialogSize=[300,100];
        ButtonSize=[90,30];
        ButtonSpace=10;

        IconWidth=32;
        IconHeight=32;
        IconXOffset=10;
        IconYOffset=30;

        Icon;
        QuestionText;

        MsgTxtWidth;
        MsgTxtHeight;
    end

    properties(Constant)
        IconYBufferSize=15;
        MsgTextXBuffer=10;
        ButtonYPosition=10;
        TopSpacing=10;
    end

    methods

        function this=AlgSaveSessionDlg(tool)

            question=vision.getMessage('vision:labeler:AlgSaveQuestion');
            dlgTitle=vision.getMessage('vision:uitools:SaveSessionTitle');

            this=this@vision.internal.uitools.AbstractDlg(...
            tool,dlgTitle);
            this.DlgSize=this.InitialDialogSize;
            createDialog(this,question);
        end


        function createDialog(this,question)

            createDialog@vision.internal.uitools.AbstractDlg(this);
            addAcceptSave(this);
            addNo(this);
            addCancel(this);
            addIcon(this);
            addQuestion(this,question);

            reposition(this);
        end
    end

    methods(Access=protected)

        function onAcceptSave(this,~,~)
            this.IsAcceptSave=true;
            this.IsNo=false;
            this.IsCancel=false;
            close(this);
        end


        function onNo(this,~,~)
            this.IsAcceptSave=false;
            this.IsNo=true;
            this.IsCancel=false;
            close(this);
        end


        function onCancel(this,~,~)
            this.IsAcceptSave=false;
            this.IsNo=false;
            this.IsCancel=true;
            close(this);
        end


        function onKeyPress(this,~,evd)
            switch(evd.Key)
            case{'return','space'}
                onAcceptSave(this);
            case{'escape'}
                onCancel(this);
            end
        end
    end

    methods(Access=protected)


        function addAcceptSave(this)
            x=this.ButtonSpace;

            if~useAppContainer
                this.AcceptSave=uicontrol('Parent',this.Dlg,...
                'Style','pushbutton','Callback',@this.onAcceptSave,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'String',...
                getString(message('vision:labeler:AcceptAndSave')),...
                'FontUnits','pixels','FontSize',this.ButtonSize(2)/3);
            else
                this.AcceptSave=uibutton('Parent',this.Dlg,...
                'ButtonPushedFcn',@this.onAcceptSave,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'Text',...
                getString(message('vision:labeler:AcceptAndSave')),...
                'FontSize',this.ButtonSize(2)/3);
            end
        end


        function addNo(this)
            x=(this.DlgSize(1)/2)-(this.ButtonSize(1)/2);
            if~useAppContainer
                this.NoButton=uicontrol('Parent',this.Dlg,...
                'Style','pushbutton','Callback',@this.onNo,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'String',...
                getString(message('MATLAB:uistring:popupdialogs:No')),...
                'FontUnits','pixels','FontSize',this.ButtonSize(2)/3);
            else
                this.NoButton=uibutton('Parent',this.Dlg,...
                'ButtonPushedFcn',@this.onNo,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'Text',...
                getString(message('MATLAB:uistring:popupdialogs:No')),...
                'FontSize',this.ButtonSize(2)/3);
            end
        end


        function addCancel(this)
            x=this.DlgSize(1)-this.ButtonSize(1)-this.ButtonSpace;
            if~useAppContainer
                this.CancelButton=uicontrol('Parent',this.Dlg,...
                'Style','pushbutton','Callback',@this.onCancel,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'String',...
                getString(message('MATLAB:uistring:popupdialogs:Cancel')),...
                'FontUnits','pixels','FontSize',this.ButtonSize(2)/3);
            else
                this.CancelButton=uibutton('Parent',this.Dlg,...
                'ButtonPushedFcn',@this.onCancel,...
                'Position',[x,this.ButtonYPosition,this.ButtonSize],...
                'Text',...
                getString(message('MATLAB:uistring:popupdialogs:Cancel')),...
                'FontSize',this.ButtonSize(2)/3);
            end
        end


        function addIcon(this)
            buttonYPosition=this.AcceptSave.Position(2);
            buttonHeight=this.ButtonSize(2);

            this.IconYOffset=buttonYPosition+buttonHeight+this.IconYBufferSize;

            this.Icon=axes(...
            'Parent',this.Dlg,...
            'Units','Pixels',...
            'Position',[this.IconXOffset,this.IconYOffset,this.IconWidth,this.IconHeight],...
            'NextPlot','replace',...
            'Tag','IconAxes'...
            );

            set(this.Dlg,'NextPlot','add');

            [iconData,alphaData]=matlab.ui.internal.dialog.DialogUtils.imreadDefaultIcon('quest');
            Img=image('CData',iconData,'AlphaData',alphaData,'Parent',this.Icon);
            set(this.Icon,...
            'Visible','off',...
            'YDir','reverse',...
            'XLim',get(Img,'XData')+[-0.5,0.5],...
            'YLim',get(Img,'YData')+[-0.5,0.5]...
            );
        end


        function addQuestion(this,question)

            msgTxtXOffset=this.IconXOffset+this.IconWidth+this.MsgTextXBuffer;
            msgTxtYOffset=this.IconYOffset;

            this.MsgTxtWidth=this.DlgSize(1)-msgTxtXOffset;
            this.MsgTxtHeight=this.DlgSize(2)-msgTxtYOffset;

            if~useAppContainer
                MsgHandle=uicontrol(this.Dlg,...
                'Style','text',...
                'Position',[msgTxtXOffset,msgTxtYOffset,this.MsgTxtWidth,this.MsgTxtHeight],...
                'String',{' '},...
                'Tag','Question',...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'BackgroundColor',[0,0,0]...
                );
            else
                MsgHandle=uilabel(this.Dlg,...
                'Position',[msgTxtXOffset,msgTxtYOffset,this.MsgTxtWidth,this.MsgTxtHeight],...
                'Text',{' '},...
                'Tag','Question',...
                'HorizontalAlignment','left',...
                'FontWeight','bold',...
                'BackgroundColor',[0,0,0],...
                'WordWrap','on');
            end

            question={question};
            if~useAppContainer
                [WrapString,NewMsgTxtPos]=textwrap(MsgHandle,question,75);
            else
                WrapString=question;
                NewMsgTxtPos=MsgHandle.Position;
            end

            AxesHandle=axes('Parent',this.Dlg,'Position',[0,0,1,1],'Visible','off');

            this.QuestionText=text(...
            'Parent',AxesHandle,...
            'Units','pixels',...
            'HorizontalAlignment','left',...
            'VerticalAlignment','bottom',...
            'String',WrapString,...
            'Interpreter','none',...
            'Tag','Question'...
            );

            textExtent=get(this.QuestionText,'Extent');

            this.MsgTxtWidth=max([textExtent(3),NewMsgTxtPos(3)]);
            this.MsgTxtHeight=max([textExtent(4),NewMsgTxtPos(4)]);

            dlgSizeX=max([this.DlgSize(1),msgTxtXOffset+this.MsgTxtWidth]);
            dlgSizeY=max([this.DlgSize(2),msgTxtYOffset+this.MsgTxtHeight]);

            this.DlgSize=[dlgSizeX,dlgSizeY];
            this.Dlg.Position(3)=dlgSizeX;
            this.Dlg.Position(4)=dlgSizeY;

            delete(MsgHandle);

            set(this.QuestionText,'Position',[msgTxtXOffset,msgTxtYOffset]);
        end
    end

    methods(Access=private)
        function reposition(this)
            if this.MsgTxtHeight>this.IconHeight
                spacing=(this.MsgTxtHeight-this.IconHeight)/2;
                currentPosition=this.QuestionText.Position(2);
                newPosition=currentPosition+spacing;
                this.Icon.Position(2)=newPosition;
                this.Dlg.Position(4)=this.Dlg.Position(4)+this.TopSpacing;
            else
                currentPosition=this.QuestionText.Position(2);
                newPosition=currentPosition+this.TopSpacing;
                this.QuestionText.Position(2)=newPosition;
            end

            dialogPosition=this.Dlg.Position;

            buttonHandles={this.AcceptSave,this.NoButton,this.CancelButton};
            for i=1:numel(buttonHandles)
                buttonHandles{i}.Position(1)=buttonHandles{i}.Position(1)+(dialogPosition(3)/2)-(this.InitialDialogSize(1)/2);
            end

        end
    end

end

function tf=useAppContainer
    tf=vision.internal.labeler.jtfeature('UseAppContainer');

end
