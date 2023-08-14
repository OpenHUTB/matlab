classdef AutomationHelpDialog<images.internal.app.utilities.CloseDialog




    properties(GetAccess=public,SetAccess=protected)
Image
HelpText
    end

    methods

        function self=AutomationHelpDialog(loc,dataFormat)

            dlgTitle=getString(message('medical:medicalLabeler:howToAutomate'));
            self=self@images.internal.app.utilities.CloseDialog(loc,dlgTitle);

            self.Size=[575,320];

            self.create();
            self.layoutDialog();

            switch dataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume
                self.HelpText.Text=getString(message('medical:medicalLabeler:automateHelpVolume'));
                self.Image.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','AutomateTutorialVolume.gif');

            case medical.internal.app.labeler.enums.DataFormat.Image
                self.HelpText.Text=getString(message('medical:medicalLabeler:automateHelpImage'));
                self.Image.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','AutomateTutorialImage.gif');

            end

        end


        function create(self)

            create@images.internal.app.utilities.CloseDialog(self);
            self.FigureHandle.WindowStyle="normal";

        end

    end

    methods(Access=protected)


        function layoutDialog(self)

            border=5;
            topBorder=10;

            bottomStart=self.Close.Position(2)+self.Close.Position(4)+border;

            pos=[border,...
            bottomStart,...
            self.FigureHandle.Position(3)-2*border,...
            self.FigureHandle.Position(4)-bottomStart-topBorder];
            panel=uipanel('Parent',self.FigureHandle,...
            'Position',pos,...
            'BorderType','none',...
            'HandleVisibility','off');

            grid=uigridlayout('Parent',panel,...
            'RowHeight',{120,'1x'},...
            'ColumnWidth',{'1x'},...
            'Padding',10,...
            'RowSpacing',0);

            self.Image=uiimage('Parent',grid,...
            'BackgroundColor','none',...
            'Enable','on',...
            'HorizontalAlignment','center',...
            'ScaleMethod','fit',...
            'ImageSource',[],...
            'Tag','AutomationHelpGIF',...
            'HandleVisibility','off');

            self.HelpText=uilabel('Parent',grid,...
            'BackgroundColor','none',...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'Text','',...
            'Tag','AutomationHelpText',...
            'HandleVisibility','off');
            self.HelpText.FontSize=self.HelpText.FontSize+1;


        end

    end

end