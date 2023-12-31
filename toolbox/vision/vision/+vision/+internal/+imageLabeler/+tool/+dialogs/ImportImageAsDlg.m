classdef ImportImageAsDlg<images.internal.app.utilities.OkCancelDialog




    properties

        ImportAs(1,1)string="BlockedImage"
    end

    properties(Access=private)

BlockedImageRadioBtn
RegularImageRadioBtn

DropPixLabelsWarnLabel

    end

    methods

        function self=ImportImageAsDlg(dlgSize,dlgCenter,hasPixelLabels)

            dlgTitle=vision.getMessage('vision:imageLabeler:ImportDlgTitle');
            self=self@images.internal.app.utilities.OkCancelDialog(dlgCenter,dlgTitle);

            self.Size=dlgSize;

            create(self,hasPixelLabels);

        end

        function create(self,hasPixelLabels)

            create@images.internal.app.utilities.OkCancelDialog(self);

            addImages(self);
            addDescription(self);
            addRadioButtons(self);

            if hasPixelLabels


                self.addWarning();
            end

            addDocPageLink(self);
        end

    end

    methods(Access=protected)

        function addImages(self)

            imageRoot=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+imageLabeler','+tool','+images');
            blockedImagePlaceholder=imread(fullfile(imageRoot,'blockedImagePlaceholder.jpg'));
            regularImagePlaceholder=imread(fullfile(imageRoot,'regularImagePlaceholder.jpg'));

            imSize=size(blockedImagePlaceholder,[1,2]);

            blockedImageAxes=axes('Parent',self.FigureHandle,...
            'Units','pixels',...
            'Position',[70,240,imSize(2),imSize(1)],...
            'XTick',[],...
            'YTick',[],...
            'HandleVisibility','off',...
            'Tag','ImportDlgBlockedImageAxes');

            regularImageAxes=axes('Parent',self.FigureHandle,...
            'Units','pixels',...
            'Position',[250,240,imSize(2),imSize(1)],...
            'XTick',[],...
            'YTick',[],...
            'HandleVisibility','off',...
            'Tag','ImportDlgImageAxes');

            imshow(blockedImagePlaceholder,'Parent',blockedImageAxes);
            imshow(regularImagePlaceholder,'Parent',regularImageAxes);

            blockedImageAxes.Toolbar.Visible='off';
            regularImageAxes.Toolbar.Visible='off';

            disableDefaultInteractivity(blockedImageAxes);
            disableDefaultInteractivity(regularImageAxes);

        end

        function addDescription(self)

            uilabel('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:LargeDataImportDescription'),...
            'FontSize',11,...
            'FontWeight','normal',...
            'WordWrap',true,...
            'VerticalAlignment','center',...
            'HorizontalAlignment','left',...
            'Position',[20,190,443,50],...
            'HandleVisibility','off');

        end

        function addRadioButtons(self)

            figPos=self.FigureHandle.Position;

            btnGrp=uibuttongroup('Parent',self.FigureHandle,...
            'BorderType','none',...
            'Units','pixels',...
            'Position',[1,105,figPos(3),75],...
            'SelectionChangedFcn',@self.selectionChanged,...
            'HandleVisibility','off');

            self.BlockedImageRadioBtn=uiradiobutton('Parent',btnGrp,...
            'Text',vision.getMessage('vision:imageLabeler:ImportAsBlockedImage'),...
            'FontWeight','bold',...
            'FontSize',12,...
            'WordWrap','on',...
            'Value',1,...
            'Position',[20,45,210,30],...
            'HandleVisibility','off',...
            'Tag','ImportAxBlockedImageBtn');

            self.RegularImageRadioBtn=uiradiobutton('Parent',btnGrp,...
            'Text',vision.getMessage('vision:imageLabeler:ImportAsRegularImage'),...
            'FontWeight','bold',...
            'FontSize',12,...
            'WordWrap','on',...
            'Position',[253,45,210,30],...
            'HandleVisibility','off',...
            'Tag','ImportAsImageBtn');

            uilabel('Parent',btnGrp,...
            'Text',vision.getMessage('vision:imageLabeler:BlockedImageLabel'),...
            'FontSize',11,...
            'FontWeight','normal',...
            'WordWrap',true,...
            'VerticalAlignment','top',...
            'HorizontalAlignment','left',...
            'Position',[25,0,205,40],...
            'HandleVisibility','off');

            uilabel('Parent',btnGrp,...
            'Text',vision.getMessage('vision:imageLabeler:RegularImageLabel'),...
            'FontSize',11,...
            'FontWeight','normal',...
            'WordWrap',true,...
            'VerticalAlignment','top',...
            'HorizontalAlignment','left',...
            'Position',[258,0,205,40],...
            'HandleVisibility','off');
        end

        function addWarning(self)
            self.DropPixLabelsWarnLabel=uilabel('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:DetetePixelLabelsDefsImportAsWarning'),...
            'FontSize',11,...
            'FontColor','#D95319',...
            'WordWrap',true,...
            'VerticalAlignment','center',...
            'HorizontalAlignment','left',...
            'FontWeight','normal',...
            'Position',[25,65,160,50],...
            'HandleVisibility','off',...
            'Tag','DeletePixLabelsWarnLabel');
        end

        function addDocPageLink(self)

            uilabel('Parent',self.FigureHandle,...
            'Text',vision.getMessage('vision:imageLabeler:ImageLabelerForBlockedImagesDoc'),...
            'FontSize',11,...
            'FontWeight','normal',...
            'Position',[1,50,self.FigureHandle.Position(3),20],...
            'VerticalAlignment','center',...
            'HorizontalAlignment','center',...
            'Interpreter','html',...
            'HandleVisibility','off',...
            'Tag','ImportDlgDocPageLinkLabel');
        end

        function selectionChanged(self,~,evt)

            if isequal(evt.NewValue,self.RegularImageRadioBtn)
                self.ImportAs="RegularImage";
                showWarning=false;
            else
                self.ImportAs="BlockedImage";
                showWarning=true;
            end

            if isgraphics(self.DropPixLabelsWarnLabel)
                self.DropPixLabelsWarnLabel.Visible=showWarning;
            end

        end


    end
end