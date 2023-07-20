classdef View<handle

    properties(Transient)

VolumePanel
VolumeCamera
VolumeTransform
volumeRenderingView
Canvas

    end

    properties(Transient,Hidden,Access=private)
SizeChangedListener
    end

    properties(Dependent)
Parent
    end

    methods(Hidden)

        function delete(self)

            delete(self.volumeRenderingView);
            delete(self.Canvas);
            delete(self.VolumeTransform);
            delete(self.VolumeCamera);
            delete(self.VolumePanel);

            delete(self.SizeChangedListener);
            delete(self);

        end

        function setBackgroundColor(self,color)
            self.Canvas.Color=color;
        end

        function displayInvalidSpatialReferencingError(~,~)
            error(message('images:volumeViewer:invalidSpatialReferencing'));
        end

        function displayNumLabelsExceededError(~,~)
            error(message('images:volumeViewer:numLabelsExceeded'));
        end

        function updateViewTransform(self,data)
            self.VolumeTransform.Matrix=data.Transform;
        end

        function updateVolumeView(self,eventData)
            self.volumeRenderingView.updateVolumeWithNewData(eventData.Volume,...
            eventData.NumSlicesInX,eventData.NumSlicesInY,eventData.NumSlicesInZ)
        end

        function createView(self)



            createVolumeCanvasViewArea(self);

            createVolumeViewCamera(self);


            createVolumeRenderingView(self);


            self.SizeChangedListener=event.listener(self.VolumePanel,'SizeChanged',@(hobj,evt)self.manageVolumeFigureResize());

            self.VolumeCamera.Viewport.Units='pixels';
            setCameraViewportPosition(self);
        end

    end

    methods(Hidden,Access=private)

        function createVolumeCanvasViewArea(self)
            self.Canvas=self.VolumePanel.getCanvas;
        end

        function createVolumeViewCamera(self)

            self.VolumeCamera=matlab.graphics.axis.camera.UniformCamera3D;
            self.VolumeCamera.DepthSort='on';
            self.VolumeCamera.TransparencyMethodHint='objectsort';
            self.VolumeCamera.Parent=self.Canvas;

            set(self.VolumeCamera,'Position',[4,4,2.5],'upvector',[0,0,1],'viewangle',15);

            self.VolumeTransform=matlab.graphics.primitive.Transform('Parent',self.VolumeCamera,'Internal',true);

        end

        function createVolumeRenderingView(self)
            dummyVol=zeros(3,3,3,'uint8');
            self.volumeRenderingView=images.internal.volshow.VolumeRenderer(self.VolumeCamera,self.VolumeTransform,...
            self.Canvas,dummyVol);
        end

        function manageVolumeFigureResize(self)

            setCameraViewportPosition(self);

        end

        function setCameraViewportPosition(self)

            panelUnits=self.VolumePanel.Units;


            self.VolumePanel.Units='pixels';
            newFigSize=self.VolumePanel.Position;

            fullyInitialzedState=strcmp(self.VolumeCamera.Viewport.Units,'pixels');
            if fullyInitialzedState

                pos=newFigSize;

                if pos(4)/pos(3)>1
                    pos(4)=abs(pos(3));
                else
                    pos(3)=abs(pos(4));
                end

                offsetX=max(0,(newFigSize(3)-pos(3))/2);
                offsetY=max(0,(newFigSize(4)-pos(4))/2);
                pos(1:2)=[offsetX+1,offsetY+1];

                self.VolumeCamera.Viewport.Position=pos;

            end


            self.VolumePanel.Units=panelUnits;

        end

    end

end