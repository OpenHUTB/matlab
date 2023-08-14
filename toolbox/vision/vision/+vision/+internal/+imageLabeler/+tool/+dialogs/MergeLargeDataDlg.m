classdef MergeLargeDataDlg<images.internal.app.utilities.OkCancelDialog




    properties
        DonotShowDlg(1,1)logical=false;
    end

    properties(Access=private)
        Border=25;
        IconSize=48;
    end

    methods

        function self=MergeLargeDataDlg(pos)


            dlgLoc=pos(1:2);
            dlgSize=pos(3:4);

            dlgTitle=vision.getMessage('vision:imageLabeler:MergeLargeDataDlgTitle');
            self=self@images.internal.app.utilities.OkCancelDialog(dlgLoc,dlgTitle);

            self.Size=dlgSize;

            create(self);
        end

        function create(self)

            create@images.internal.app.utilities.OkCancelDialog(self);
            self.Ok.Text=getString(message('MATLAB:uistring:popupdialogs:Yes'));
            self.Cancel.Text=getString(message('MATLAB:uistring:popupdialogs:No'));

            addWarningIcon(self);
            addWarningMsg(self);
            addDocPageLink(self);
            addDonotShow(self)

        end

    end

    methods(Access=private)

        function addWarningIcon(self)

            warnIconFile=fullfile(toolboxdir('vision'),'vision','+vision',...
            '+internal','+imageLabeler','+tool','+images','stopWarning_24.png');
            [iconData,~,alphaData]=imread(warnIconFile);

            ax=axes('Parent',self.FigureHandle,...
            'HandleVisibility','off',...
            'HitTest','off',...
            'Units','pixels',...
            'Position',[self.Border+10,145,self.IconSize,self.IconSize],...
            'Visible','off',...
            'PickableParts','none');

            image('Parent',ax,...
            'CData',flipud(iconData),...
            'AlphaData',flipud(alphaData),...
            'Interpolation','bilinear',...
            'HandleVisibility','off');

        end

        function addWarningMsg(self)

            pos=[self.Border+self.IconSize+self.Border,...
            120,...
            self.FigureHandle.Position(3)-(2*self.Border)-48-self.Border,...
            120];
            uilabel('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:MergeLargeDataMessage'),...
            'FontSize',12,...
            'FontWeight','normal',...
            'Position',pos,...
            'VerticalAlignment','bottom',...
            'WordWrap',true,...
            'HandleVisibility','off');

        end

        function addDocPageLink(self)

            uilabel('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:ImageLabelerForBlockedImagesDoc'),...
            'FontSize',11,...
            'FontWeight','normal',...
            'Position',[self.Border,70,self.FigureHandle.Position(3)-(2*self.Border),20],...
            'HorizontalAlignment','center',...
            'Interpreter','html',...
            'HandleVisibility','off',...
            'Tag','MergeDataDlgDocPageLink');

        end

        function addDonotShow(self)

            uicheckbox('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:DonotShowAgainInSession'),...
            'Value',self.DonotShowDlg,...
            'FontSize',11,...
            'FontWeight','normal',...
            'Position',[self.Border,40,self.FigureHandle.Position(3)-(2*self.Border),20],...
            'HandleVisibility','off',...
            'ValueChangedFcn',@self.donotShowValueChanged,...
            'Tag','MergeDataDonotShowCheckbox');
        end

    end


    methods(Access=private)

        function donotShowValueChanged(self,~,evt)
            self.DonotShowDlg=evt.Value;
        end

    end

end