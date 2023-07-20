classdef LabelsView<rf.internal.apps.budget.ElementView






    properties(Constant)
Icon
    end

    properties
LabelLayout
StageLabel
GainLabel
NFLabel
OIP3Label
    end

    properties(Constant)
        LabelHeight=20;
    end

    properties(Dependent)
LabelRowHeight
    end

    methods
        function self=LabelsView(varargin)



            self=self@rf.internal.apps.budget.ElementView(varargin{:});
            self.Visible='on';
            if self.Canvas.View.UseAppContainer
                self.Picture.Layout.Visible='off';
                self.Layout.BackgroundColor=[.94,.94,.94];
                self.StageText.Layout.BackgroundColor=[.94,.94,.94];
                createLabels(self);
                layoutLabels(self);
            else
                self.Picture.Panel.Visible='off';
                self.Panel.BackgroundColor=[.94,.94,.94];
                self.StageText.Panel.BackgroundColor=[.94,.94,.94];
                self.setTextString(self.StageText.ID,'Stage')
                self.setTextString(self.StageText.Gain,'GainT (dB)')
                self.setTextString(self.StageText.NF,'NF (dB)')
                self.setTextString(self.StageText.OIP3,'OIP3 (dBm)')
            end
            self.LineIn.Visible='off';
            self.LineOut.Visible='off';
            adjustLayout(self)
        end

        function rtn=get.LabelRowHeight(self)
            rtn=self.Canvas.CascadeRowHeight;
        end

        function createLabels(self)





            self.LabelLayout=uigridlayout(...
            'Parent',self.Canvas.Layout,...
            'Tag','canvasLabelLayout',...
            'Scrollable','on',...
            'BackgroundColor',[0.94,0.94,0.94],...
            'RowHeight',self.LabelRowHeight,...
            'ColumnWidth',{'1x'},...
            'RowSpacing',3);

            self.StageLabel=uilabel(...
            'Parent',self.LabelLayout,...
            'Tag','stageLabel',...
            'Text','Stage');

            self.GainLabel=uilabel(...
            'Parent',self.LabelLayout,...
            'Tag','gainLabel',...
            'Text','GainT (dB)');

            self.NFLabel=uilabel(...
            'Parent',self.LabelLayout,...
            'Tag','nfLabel',...
            'Text','NF (dB)');

            self.OIP3Label=uilabel(...
            'Parent',self.LabelLayout,...
            'Tag','oip3Label',...
            'Text','OIP3 (dBm)');
        end

        function layoutLabels(self)



            self.LabelLayout.Layout.Row=1;
            self.LabelLayout.Layout.Column=1;

            self.StageLabel.Layout.Row=6;
            self.StageLabel.Layout.Column=1;

            self.GainLabel.Layout.Row=7;
            self.GainLabel.Layout.Column=1;

            self.NFLabel.Layout.Row=8;
            self.NFLabel.Layout.Column=1;

            self.OIP3Label.Layout.Row=9;
            self.OIP3Label.Layout.Column=1;
        end

        function adjustLayout(self)


            if self.Canvas.View.UseAppContainer
                self.StageText.Layout.ColumnWidth=...
                rf.internal.apps.budget.ElementView.TextHeight-3;
            else
                for i=2:4
                    setConstraints(...
                    self.StageText.Layout,i,1,...
                    'TopInset',3,...
                    'MinimumHeight',rf.internal.apps.budget.ElementView.TextHeight-3)
                end
            end
        end

        function setTextString(self,u,str)

            if self.Canvas.View.UseAppContainer
                u=uilabel('Parent',u.Parent);
                u.Text=str;
            else
                u.Style='text';
                u.String=str;
            end
            u.HorizontalAlignment='right';
            u.BackgroundColor=[.94,.94,.94];
        end
    end
end


