classdef Slice<images.internal.app.segmenter.volume.display.Slice




    properties(Access=protected)

MarkerHorizontal1
MarkerHorizontal2

MarkerVertical1
MarkerVertical2

    end

    properties(Access=private,Constant)

        MarkerColor=[1,1,0];

    end

    methods

        function self=Slice(hParent,pos)

            self@images.internal.app.segmenter.volume.display.Slice(hParent,pos);
            self.Image.YBorder=[21,21];

            self.createOrientationMarkers();

            self.SliceIndicator.HorizontalAlignment='right';
            self.ColorIndicator.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','TransparentPatch_20.png');

        end


        function setSlicePanelTag(self,tag)
            self.Panel.Tag=tag;
        end


        function showOrientationMarkers(self,TF)

            self.MarkerHorizontal1.Visible=TF;
            self.MarkerHorizontal2.Visible=TF;
            self.MarkerVertical1.Visible=TF;
            self.MarkerVertical2.Visible=TF;

        end


        function setOrientationMarkers(self,markerH1,markerH2,markerV1,markerV2)

            self.MarkerHorizontal1.Text=markerH1;
            self.MarkerHorizontal2.Text=markerH2;
            self.MarkerVertical1.Text=markerV1;
            self.MarkerVertical2.Text=markerV2;

        end


        function showScaleBar(self,TF)



        end


        function setAxesXDir(self,direction)
            set(self.Image.AxesHandle,'XDir',direction)
        end


        function imageHandle=getImageHandle(self)
            imageHandle=self.ImageHandle;
        end


        function img=getScreenshot(self)
            data=getframe(self.Image.AxesHandle);
            img=data.cdata;
        end


        function displayMode(self,mode)

            switch mode

            case 'Freehand'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Freehand_20.png');
            case 'AssistedFreehand'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_AssistedFreehand_20.png');
            case 'Polygon'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Polygon_20.png');
            case 'PaintBrush'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Brush_20.png');
            case 'Eraser'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Eraser_20.png');
            case{'FillRegion','FloodFill'}
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_FillRegion_20.png');
            case 'Select'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_SelectRegion_20.png');
            case 'WindowLevel'
                self.ModeIndicator.ImageSource=fullfile(ipticondir,'cursor_contrast.png');
            case 'LevelTracing'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','Slice_TraceBoundary_20.png');
            case 'None'
                self.ModeIndicator.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','TransparentPatch_20.png');
            end

        end


        function displayLabelColor(self,color)

            if isempty(color)
                self.ColorIndicator.ImageSource=fullfile(matlabroot,'toolbox','medical','apps','+medical','+internal','+app','+labeler','+icons','TransparentPatch_20.png');
            else

                I(1:20,1:20,1)=color(1);
                I(1:20,1:20,2)=color(2);
                I(1:20,1:20,3)=color(3);

                self.ColorIndicator.ImageSource=I;

            end

        end

    end

    methods(Access=protected)


        function setAxesPosition(self)

            parentPos=self.Panel.Position;
            if any(parentPos<1)
                return;
            end

            pos=parentPos;
            pos(1)=5;
            pos(2)=5;
            pos(3)=pos(3)-10;
            pos(4)=pos(4)-25;

            if any(pos<1)
                return;
            end

            axesInfo=GetLayoutInformation(self.ImageHandle.Parent);


            pos(1)=axesInfo.PlotBox(1)+axesInfo.PlotBox(3)/2-10;

            if pos(1)<=1
                pos(1)=10;
            end

            pos(2)=axesInfo.PlotBox(2)+axesInfo.PlotBox(4);

            if pos(2)>pos(4)+7
                pos(2)=pos(4)-5;
            end

            pos(4)=20;
            pos(3)=20;

            self.MarkerVertical1.Position=pos;


            pos(2)=axesInfo.PlotBox(2)-20;
            if pos(2)<=1
                pos(2)=10;
            end
            self.MarkerVertical2.Position=pos;


            pos(1)=axesInfo.PlotBox(1)-20;
            if pos(1)<=1
                pos(1)=10;
            end

            pos(2)=axesInfo.PlotBox(2)+axesInfo.PlotBox(4)/2-10;
            self.MarkerHorizontal1.Position=pos;







            pos(1)=axesInfo.PlotBox(1)+axesInfo.PlotBox(3)+5;
            if pos(1)+pos(3)>self.Panel.Position(1)+self.Panel.Position(3)
                pos(1)=self.Panel.Position(1)+self.Panel.Position(3)-20;
            end
            self.MarkerHorizontal2.Position=pos;







            rightBorder=10;
            width=100;
            sliceNumPos=[parentPos(3)-width-rightBorder,1,width,20];
            self.SliceIndicator.Position=sliceNumPos;

            pos=parentPos;
            pos(1)=5;
            pos(2)=5;
            pos(3)=pos(3)-10;
            pos(4)=pos(4)-25;

            if any(pos<1)
                return;
            end

            pos(1)=axesInfo.PlotBox(1);

            if pos(1)<=1
                pos(1)=10;
            end

            pos(2)=axesInfo.PlotBox(2)+axesInfo.PlotBox(4);

            if pos(2)>pos(4)+7
                pos(2)=pos(4)-5;
            end

            pos(4)=20;
            pos(3)=20;


            set(self.ModeIndicator,'Position',pos);


            pos(1)=pos(1)+22;
            set(self.ColorIndicator,'Position',pos);

            if strcmp(self.Datatip.Visible,'on')
                set(self.Datatip,'Position',[self.Image.AxesHandle.CurrentPoint(1,1:2),0]);
            end

        end


        function reactToEmptyPropChange(self)

            if self.Empty
                set(self.MarkerHorizontal1,'FontColor',[0.94,0.94,0.94]);
                set(self.MarkerHorizontal2,'FontColor',[0.94,0.94,0.94]);
                set(self.MarkerVertical1,'FontColor',[0.94,0.94,0.94]);
                set(self.MarkerVertical2,'FontColor',[0.94,0.94,0.94]);
            else
                set(self.MarkerHorizontal1,'FontColor',self.MarkerColor);
                set(self.MarkerHorizontal2,'FontColor',self.MarkerColor);
                set(self.MarkerVertical1,'FontColor',self.MarkerColor);
                set(self.MarkerVertical2,'FontColor',self.MarkerColor);
            end




            set(self.MarkerHorizontal1,'BackgroundColor','none');
            set(self.MarkerHorizontal2,'BackgroundColor','none');
            set(self.MarkerVertical1,'BackgroundColor','none');
            set(self.MarkerVertical2,'BackgroundColor','none');

        end


        function createOrientationMarkers(self)

            self.MarkerHorizontal1=uilabel('Parent',self.Panel,...
            'Text','',...
            'Visible','off',...
            'VerticalAlignment','top',...
            'FontColor',[0.94,0.94,0.94],...
            'FontSize',18,...
            'Tag','HorizontalMarker1');

            self.MarkerHorizontal2=uilabel('Parent',self.Panel,...
            'Text','',...
            'Visible','off',...
            'VerticalAlignment','top',...
            'FontColor',[0.94,0.94,0.94],...
            'FontSize',18,...
            'Tag','HorizontalMarker2');

            self.MarkerVertical1=uilabel('Parent',self.Panel,...
            'Text','',...
            'Visible','off',...
            'VerticalAlignment','top',...
            'FontColor',[0.94,0.94,0.94],...
            'FontSize',18,...
            'Tag','VerticalMarker1');

            self.MarkerVertical2=uilabel('Parent',self.Panel,...
            'Text','',...
            'Visible','off',...
            'VerticalAlignment','top',...
            'FontColor',[0.94,0.94,0.94],...
            'FontSize',18,...
            'Tag','VerticalMarker2');

        end

    end

end