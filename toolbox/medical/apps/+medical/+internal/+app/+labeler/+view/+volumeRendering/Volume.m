classdef Volume<handle&matlab.mixin.SetGet




    properties
VolumeBounds
    end

    properties(Dependent)

Visible

BackgroundGradient
BackgroundColor
GradientColor

DisplayScaleBar
DisplayOrientationAxes

VolumeRenderingStyle
VolumeColor
VolumeAlpha

LabelColor
LabelAlpha

IsLabelDirty
ShowMessage

OrientationAxesLabels

    end

    properties(Access=protected)

Grid

Viewer

VolumeObj

MessageText
MessageIcon
Update

    end

    properties(SetAccess=protected,Hidden)

        BackgroundColorDefault(1,3)double=[0.1,0.1,0.1];
        GradientColorDefault(1,3)double=[0.3,0.3,0.3];

    end

    events
RefreshLabels3D
WarningThrown
    end

    methods

        function self=Volume(hFig)

            self.create(hFig);

            addlistener(self.Viewer,'WarningThrown',@(src,evt)self.notify('WarningThrown',evt));

        end


        function delete(self)

            delete(self.Viewer);

            delete(self);

        end


        function clear(self)

            set(self.VolumeObj,...
            'Data',[],...
            'OverlayData',[]);

            self.VolumeBounds=[];

        end


        function updateVolume(self,data,tform)

            set(self.VolumeObj,...
            'Data',data,...
            'Transformation',tform);

        end


        function updateLabels(self,labels)
            set(self.VolumeObj,'OverlayData',labels);
        end


        function updateVolumeRendering(self,renderingStyle,color,alpha)



            self.VolumeRenderingStyle=renderingStyle;

            set(self.VolumeObj,...
            'Colormap',color,...
            'Alphamap',alpha);

        end


        function restoreVolumeBackground(self)

            s=settings;
            backgroundGradient=s.medical.apps.volume.BackgroundGradient.FactoryValue;

            self.BackgroundGradient=backgroundGradient;
            self.BackgroundColor=self.BackgroundColorDefault;
            self.GradientColor=self.GradientColorDefault;

        end

    end

    methods(Access=protected)


        function create(self,hFig)


            s=settings;

            backgroundGradient=s.medical.apps.volume.BackgroundGradient.ActiveValue;
            displayOrientationAxes=s.medical.apps.volume.ShowOrientationAxes.ActiveValue;
            displayScalebar=s.medical.apps.labeler.ShowScaleBars.ActiveValue;


            color=s.medical.apps.volume.BackgroundColor.ActiveValue;
            if isnumeric(color)
                backgroundColor=color;
            else
                backgroundColor=self.BackgroundColorDefault;
                s.medical.apps.volume.BackgroundColor.PersonalValue=backgroundColor;
            end


            color=s.medical.apps.volume.GradientColor.ActiveValue;
            if isnumeric(color)
                gradientColor=color;
            else
                gradientColor=self.GradientColorDefault;
                s.medical.apps.volume.GradientColor.PersonalValue=gradientColor;
            end


            self.Grid=uigridlayout('Parent',hFig,...
            'RowHeight',{0,0,'1x'},...
            'ColumnWidth',{'1x'},...
            'RowSpacing',0,...
            'Padding',0,...
            'BackgroundColor',backgroundColor);


            refreshGridColor=[0.8,0.8,0.8];
            refreshGrid=uigridlayout('Parent',self.Grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{20,'fit',50,'1x'},...
            'Padding',[5,2,0,2],...
            'BackgroundColor',refreshGridColor);
            refreshGrid.Layout.Row=1;
            refreshGrid.Layout.Column=1;

            icon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Warning_24.png');
            im=uiimage('Parent',refreshGrid,...
            'BackgroundColor',refreshGridColor,...
            'ImageSource',icon);
            im.Layout.Row=1;
            im.Layout.Column=1;

            l=uilabel('Parent',refreshGrid,...
            'BackgroundColor',refreshGridColor,...
            'HorizontalAlignment','left',...
            'VerticalAlignment','center',...
            'Text',getString(message('medical:medicalLabeler:refreshLabelsText')));
            l.Layout.Row=1;
            l.Layout.Column=2;

            self.Update=uibutton('push',...
            'Parent',refreshGrid,...
            'Text',getString(message('medical:medicalLabeler:update')),...
            'Tooltip',getString(message('medical:medicalLabeler:refreshLabelsText')),...
            'ButtonPushedFcn',@(~,~)self.notify('RefreshLabels3D'));
            self.Update.Layout.Row=1;
            self.Update.Layout.Column=3;


            messageGrid=uigridlayout('Parent',self.Grid,...
            'RowHeight',{'1x'},...
            'ColumnWidth',{20,'1x'},...
            'Padding',[5,2,0,2],...
            'BackgroundColor',refreshGridColor);
            messageGrid.Layout.Row=2;
            messageGrid.Layout.Column=1;

            icon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Warning_24.png');
            self.MessageIcon=uiimage('Parent',messageGrid,...
            'BackgroundColor',refreshGridColor,...
            'ImageSource',icon);
            self.MessageText.Layout.Row=1;
            self.MessageText.Layout.Column=1;

            self.MessageText=uilabel('Parent',messageGrid,...
            'BackgroundColor',refreshGridColor,...
            'HorizontalAlignment','left',...
            'VerticalAlignment','center',...
            'Text','');
            self.MessageText.Layout.Row=1;
            self.MessageText.Layout.Column=2;


            self.Viewer=images.ui.graphics3d.Viewer3D(self.Grid,...
            'BackgroundGradient',backgroundGradient,...
            'BackgroundColor',backgroundColor,...
            'GradientColor',gradientColor,...
            'Lighting','off',...
            'OrientationAxes',displayOrientationAxes,...
            'ScaleBar',displayScalebar,...
            'Box',false,...
            'Interactions',["zoom","rotate","axes","pan"],...
            'ScalebarUnits','mm',...
            'KeepDataReference',false,...
            'ShowWarnings',false,...
            'Visible',false);
            self.Viewer.Layout.Row=3;
            self.Viewer.Layout.Column=1;

            self.VolumeObj=images.ui.graphics3d.Volume(self.Viewer,...
            'RenderingStyle','VolumeRendering',...
            'RescaleOverlayData',false,...
            'Visible','on');


        end

    end


    methods


        function set.Visible(self,TF)
            self.Viewer.Visible=TF;
            self.Grid.Visible=TF;
        end

        function TF=get.Visible(self)
            TF=self.Viewer.Visible;
        end


        function set.VolumeRenderingStyle(self,renderer)

            self.VolumeObj.RenderingStyle=string(renderer);

            switch renderer
            case{medical.internal.app.labeler.enums.RenderingTechniques.MaximumIntensityProjection,...
                medical.internal.app.labeler.enums.RenderingTechniques.MinimumIntensityProjection}

                warnIcon=fullfile(matlabroot,'toolbox','shared','controllib','general','resources','Warning_24.png');
                self.MessageIcon=warnIcon;
                self.MessageText.Text=getString(message('medical:medicalLabeler:mipLabelsNotVisible'));
                self.ShowMessage=true;

            otherwise
                self.ShowMessage=false;

            end

        end

        function renderer=get.VolumeRenderingStyle(self)
            renderer=self.VolumeObj.RenderingStyle;
        end


        function set.BackgroundGradient(self,TF)
            self.Viewer.BackgroundGradient=TF;
        end

        function TF=get.BackgroundGradient(self)
            TF=self.Viewer.BackgroundGradient;
        end


        function set.BackgroundColor(self,color)
            self.Viewer.BackgroundColor=color;
            self.Grid.BackgroundColor=color;
        end

        function color=get.BackgroundColor(self)
            color=self.Viewer.BackgroundColor;
        end


        function set.GradientColor(self,color)
            self.Viewer.GradientColor=color;
        end

        function color=get.GradientColor(self)
            color=self.Viewer.GradientColor;
        end


        function set.DisplayScaleBar(self,TF)
            self.Viewer.ScaleBar=TF;
        end

        function displayScalebar=get.DisplayScaleBar(self)
            displayScalebar=self.Viewer.ScaleBar;
        end


        function set.DisplayOrientationAxes(self,TF)
            self.Viewer.OrientationAxes=TF;
        end

        function displayOrientationAxes=get.DisplayOrientationAxes(self)
            displayOrientationAxes=self.Viewer.OrientationAxes;
        end


        function set.VolumeColor(self,color)
            self.VolumeObj.Colormap=color;
        end

        function color=get.VolumeColor(self)
            color=self.VolumeObj.Colormap;
        end


        function set.VolumeAlpha(self,alpha)
            self.VolumeObj.Alphamap=alpha;
        end

        function alpha=get.VolumeAlpha(self)
            alpha=self.VolumeObj.Alphamap;
        end


        function set.LabelColor(self,color)
            self.VolumeObj.OverlayColormap=color;
        end

        function color=get.LabelColor(self)
            color=self.VolumeObj.OverlayColormap;
        end


        function set.LabelAlpha(self,alpha)
            self.VolumeObj.OverlayAlphamap=alpha;
        end

        function alpha=get.LabelAlpha(self)
            alpha=self.VolumeObj.OverlayAlphamap;
        end


        function set.IsLabelDirty(self,TF)

            rowHeight=self.Grid.RowHeight;

            if TF
                rowHeight{1}=26;
            else
                rowHeight{1}=0;
            end

            self.Grid.RowHeight=rowHeight;

        end

        function TF=get.IsLabelDirty(self)
            TF=self.Grid.RowHeight{1}~=0;
        end


        function set.ShowMessage(self,TF)

            rowHeight=self.Grid.RowHeight;

            if TF
                rowHeight{2}=26;
            else
                rowHeight{2}=0;
            end

            self.Grid.RowHeight=rowHeight;

        end

        function TF=get.ShowMessage(self)
            TF=self.Grid.RowHeight{2}~=0;
        end


        function set.OrientationAxesLabels(self,axesLabels)
            self.Viewer.OrientationAxesLabels=axesLabels;
        end

    end

end
