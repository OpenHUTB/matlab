classdef RenderingEditor<handle




    properties(Dependent)

Visible

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

Panel

AlphamapPanel

ColormapPanel

TechniqueDropdown

    end

    properties(SetAccess=private,GetAccess=?uitest.factory.Tester)

AlphamapEditor

ColormapEditor

    end

    properties(Access=private,Constant)

        ButtonHeight=25

        AlphamapPanelHeight=300;

        ColormapPanelHeight=120;

    end

    events

VolumeRenderingStyleChanged

AlphaControlPtsUpdated

ColorControlPtsUpdated

BringAppToFront

    end

    methods

        function self=RenderingEditor(renderingEditorFig)

            self.Panel=uipanel('Parent',renderingEditorFig,...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'HandleVisibility','off',...
            'Visible','off');

            self.create();

            self.wireupAlphamapEditor();
            self.wireupColormapEditor();

        end

        function delete(self)
            delete(self.ColormapEditor);
            delete(self.AlphamapEditor);
        end

        function clear(self)
            self.ColormapEditor.clear();
            self.AlphamapEditor.clear();
        end

        function updateRendering(self,technique,alphaCP,colorCP)

            self.TechniqueDropdown.Value=technique;
            self.AlphamapEditor.ControlPointsPos=alphaCP;
            self.ColormapEditor.ControlPointsValue=colorCP;

        end

        function[renderer,colorCP,alphaCP]=getRendering(self)

            renderer=self.TechniqueDropdown.Value;
            colorCP=self.ColormapEditor.ControlPointsValue;
            alphaCP=self.AlphamapEditor.ControlPointsPos;

        end

        function updateBackgroundColormap(self,cmap)





            self.AlphamapEditor.BackgroundColormap=cmap;
            self.ColormapEditor.BackgroundColormap=cmap;

        end

        function setVolumeBounds(self,volumeBounds)
            self.AlphamapEditor.VolumeBounds=volumeBounds;
        end

    end


    methods

        function set.Visible(self,TF)

            self.Panel.Visible=TF;

        end

    end

    methods(Access=private)

        function create(self)

            grid=uigridlayout('Parent',self.Panel,...
            'RowHeight',{self.ButtonHeight,self.AlphamapPanelHeight,self.ColormapPanelHeight,'1x'},...
            'ColumnWidth',{'fit','1x'},...
            'RowSpacing',5,...
            'ColumnSpacing',5,...
            'Scrollable','on');

            techniqueLabel=uilabel('Parent',grid,...
            'Text',getString(message('medical:medicalLabeler:technique')),...
            'Tag','TechniqueLabel',...
            'HandleVisibility','off');
            techniqueLabel.Layout.Row=1;
            techniqueLabel.Layout.Column=1;

            techniques={
            getString(message('medical:medicalLabeler:volumeRendering')),...
            getString(message('medical:medicalLabeler:maximumIntensityProjection')),...
            getString(message('medical:medicalLabeler:gradientOpacity'))...
            };
            itemsData={medical.internal.app.labeler.enums.RenderingTechniques.VolumeRendering,...
            medical.internal.app.labeler.enums.RenderingTechniques.MaximumIntensityProjection,...
            medical.internal.app.labeler.enums.RenderingTechniques.GradientOpacity};
            self.TechniqueDropdown=uidropdown('Parent',grid,...
            'Items',techniques,...
            'ItemsData',itemsData,...
            'Tag','Technique',...
            'ValueChangedFcn',@(src,evt)self.reactToRenderingTechniqueChange(evt.Value),...
            'HandleVisibility','off');
            self.TechniqueDropdown.Layout.Row=1;
            self.TechniqueDropdown.Layout.Column=2;

            self.AlphamapPanel=uipanel('Parent',grid,...
            'Units','pixels',...
            'Title',getString(message('medical:medicalLabeler:alphamap')),...
            'BorderType','none',...
            'FontWeight','bold',...
            'HandleVisibility','off');
            self.AlphamapPanel.Layout.Row=2;
            self.AlphamapPanel.Layout.Column=[1,2];

            self.ColormapPanel=uipanel('Parent',grid,...
            'Units','pixels',...
            'Title',getString(message('medical:medicalLabeler:colormap')),...
            'BorderType','none',...
            'FontWeight','bold',...
            'HandleVisibility','off');
            self.ColormapPanel.Layout.Row=3;
            self.ColormapPanel.Layout.Column=[1,2];

        end

        function wireupAlphamapEditor(self)

            self.AlphamapEditor=medical.internal.app.labeler.view.volumeRendering.AlphamapEditor(self.AlphamapPanel);

            addlistener(self.AlphamapEditor,'AlphaControlPtsUpdated',@(src,evt)self.notify('AlphaControlPtsUpdated',evt));

        end

        function wireupColormapEditor(self)

            self.ColormapEditor=medical.internal.app.labeler.view.volumeRendering.ColormapEditor(self.ColormapPanel);

            addlistener(self.ColormapEditor,'ColorControlPtsUpdated',@(src,evt)self.notify('ColorControlPtsUpdated',evt));
            addlistener(self.ColormapEditor,'BringAppToFront',@(src,evt)self.notify('BringAppToFront'));

        end

    end


    methods(Access=private)

        function reactToRenderingTechniqueChange(self,val)

            evt=medical.internal.app.labeler.events.ValueEventData(val);
            self.notify('VolumeRenderingStyleChanged',evt)

        end

    end


end
