classdef CameraController<handle



    properties(Transient,Hidden)

ButtonDownListener
ButtonMotionRotateListener
ButtonUpRotateListener
ButtonMotionZoomListener
ButtonUpZoomListener

ScrollwheelZoomListener

UpdateViewCameraListener
UpdateOrientationAxesListener
UpdateLightPositionListener

hModel
hView

    end

    properties(Dependent)
Interactable
    end


    properties(Transient,Hidden,Access=private)

CamX
CamY
CamZ
Viewport
ViewportHeight
Radius
Center
CameraDistance

StartPoint
ZoomStartPoint

    end

    properties(Access=private)
        InteractableInternal=true;
    end

    methods

        function self=CameraController(hCanvas,hModel,hView)

            self.hView=hView;
            self.hModel=hModel;

            self.ButtonDownListener=event.listener(hCanvas,'ButtonDown',@(hObj,evt)self.buttonDown(evt));
            self.ButtonMotionRotateListener=event.listener(hCanvas,'ButtonMotion',@(hObj,evt)self.rotateButtonMotion(evt));
            self.ButtonUpRotateListener=event.listener(hCanvas,'ButtonUp',@(hObj,evt)self.rotateButtonUp(evt));
            self.ButtonMotionZoomListener=event.listener(hCanvas,'ButtonMotion',@(hObj,evt)self.zoomButtonMotion(evt));
            self.ButtonUpZoomListener=event.listener(hCanvas,'ButtonUp',@(hObj,evt)self.zoomButtonUp(evt));

            hFig=ancestor(self.hView.VolumePanel,'figure');
            self.ScrollwheelZoomListener=event.listener(hFig,'WindowScrollWheel',@(hobj,evt)self.zoomWheel(evt));

            self.ButtonMotionRotateListener.Enabled=false;
            self.ButtonUpRotateListener.Enabled=false;
            self.ButtonMotionZoomListener.Enabled=false;
            self.ButtonUpZoomListener.Enabled=false;



            self.UpdateViewCameraListener=event.listener(hModel,'CameraPositionChange',@(hObj,evt)self.updateViewCamera(evt));
            self.UpdateOrientationAxesListener=event.listener(hModel,'CameraPositionChange',@(hObj,evt)self.updateOrientationAxesCamera(evt));
            self.UpdateLightPositionListener=event.listener(hModel,'CameraPositionChange',@(hObj,evt)self.updateLightPosition(evt));

            setInteractivityState(self);

        end

        function delete(self)

            delete(self.ButtonDownListener);
            delete(self.ButtonMotionRotateListener);
            delete(self.ButtonUpRotateListener);
            delete(self.ButtonMotionZoomListener);
            delete(self.ButtonUpZoomListener);

            delete(self.UpdateViewCameraListener);
            delete(self.UpdateOrientationAxesListener);
            delete(self.UpdateLightPositionListener);

            delete(self.ScrollwheelZoomListener);

            self.hModel=[];
            self.hView=[];

            delete(self);

        end

    end


    methods(Access=private)

        function setInteractivityState(self)

            if self.InteractableInternal
                self.ButtonDownListener.Enabled=true;
                self.ScrollwheelZoomListener.Enabled=true;
            else
                self.ButtonDownListener.Enabled=false;
                self.ScrollwheelZoomListener.Enabled=false;
            end

        end

        function buttonDown(self,evt)

            pt=[evt.X,evt.Y];
            self.ZoomStartPoint=pt;

            self.CamY=self.hModel.CameraUpVector;

            self.CamZ=self.hModel.CameraPosition-self.hModel.CameraTarget;
            self.CameraDistance=norm(self.CamZ);
            self.CamZ=self.CamZ/self.CameraDistance;

            self.CamY=self.CamY/norm(self.CamY);
            self.CamX=cross(self.CamY,self.CamZ);








            hFig=ancestor(self.hView.VolumePanel,'figure');
            panelUnits=self.hView.VolumePanel.Units;


            self.hView.VolumePanel.Units='pixels';
            vpt=self.hView.VolumePanel.Position;
            self.hView.VolumePanel.Units=panelUnits;

            vpt(1)=1;
            vpt(2)=1;
            self.Radius=double(min(vpt(3)-vpt(1),vpt(4)-vpt(2))/2);
            self.Center=double([vpt(3)+vpt(1),vpt(4)+vpt(2)]/2);

            self.ViewportHeight=vpt(4)-vpt(1);

            pt(2)=self.ViewportHeight-pt(2);
            self.StartPoint=point_on_sphere(double(pt)-self.Center,self.Radius);

            ctrlClick=strcmp(cell2mat(hFig.CurrentModifier),'control')&&...
            (evt.Button==1);

            rightClick=evt.Button==3;
            zoomClickGesture=ctrlClick||rightClick;
            if zoomClickGesture
                self.ButtonMotionZoomListener.Enabled=true;
                self.ButtonUpZoomListener.Enabled=true;
            else
                self.ButtonMotionRotateListener.Enabled=true;
                self.ButtonUpRotateListener.Enabled=true;
            end

        end

        function zoomButtonMotion(self,evt)

            changeInY=double(evt.Y-self.ZoomStartPoint(2));

            if(changeInY>0)
                zoomFactor=1.15;
            elseif(changeInY<0)
                zoomFactor=1/1.15;
            else
                zoomFactor=1;
            end

            self.ZoomStartPoint=[evt.X,evt.Y];
            self.hModel.CameraPosition=self.hModel.CameraPosition/zoomFactor;

        end

        function zoomButtonUp(self,evt)

            self.ButtonMotionZoomListener.Enabled=false;
            self.zoomButtonMotion(evt);

            drawnow;


            self.hView.volumeRenderingView.updateVolumeAtFullResolution();
            self.ButtonUpZoomListener.Enabled=false;

        end

        function rotateButtonMotion(self,evt)

            pt=[evt.X,evt.Y];

            pt(2)=self.ViewportHeight-pt(2);
            currpt=point_on_sphere(double(pt)-self.Center,self.Radius);

            axis=cross(self.StartPoint,currpt);
            l=norm(axis);
            axis=axis/l;
            ang=asin(l);

            axis=axis(1)*self.CamX+axis(2)*self.CamY+axis(3)*self.CamZ;



            if any(isnan(axis))
                return;
            end



            t=makehgtform('axisrotate',axis,-ang);

            t=t(1:3,1:3);

            new_y=(t*self.CamY')';
            new_z=(t*self.CamZ')';

            new_pos=self.hModel.CameraTarget+self.CameraDistance*new_z;

            self.hModel.CameraPosition=new_pos;
            self.hModel.CameraUpVector=new_y;

        end

        function rotateButtonUp(self,evt)

            self.ButtonMotionRotateListener.Enabled=false;
            self.rotateButtonMotion(evt);

            drawnow;


            self.hView.volumeRenderingView.updateVolumeAtFullResolution();
            self.ButtonUpRotateListener.Enabled=false;

        end

    end


    methods(Access=private)

        function zoomWheel(self,evt)

            isZoomIn=evt.VerticalScrollCount<0;

            currentWhenMoving=self.hView.volumeRenderingView.VolumePrimitive.SampleDensityWhenMoving;
            self.hView.volumeRenderingView.VolumePrimitive.SampleDensityWhenMoving=self.hView.volumeRenderingView.VolumePrimitive.SampleDensity;

            if isZoomIn
                zoomFactor=1.2;
            else
                zoomFactor=1/1.2;
            end

            self.hModel.CameraPosition=self.hModel.CameraPosition/zoomFactor;

            self.hView.volumeRenderingView.VolumePrimitive.SampleDensityWhenMoving=currentWhenMoving;

        end

    end


    methods(Access=private)

        function updateViewCamera(self,evt)



            self.hView.VolumeCamera.Position=evt.CameraPosition;
            self.hView.VolumeCamera.UpVector=evt.CameraUpVector;
            self.hView.VolumeCamera.Target=evt.CameraTarget;
            self.hView.VolumeCamera.ViewAngle=evt.CameraViewAngle;

        end

        function updateOrientationAxesCamera(self,evt)


            if isa(self.hView,'images.internal.volshow.View')
                return;
            end




            normalizedPos=4*evt.CameraPosition./norm(evt.CameraPosition);

            self.hView.orientationAxesView.hAx.CameraPosition=normalizedPos;
            self.hView.orientationAxesView.hAx.CameraUpVector=evt.CameraUpVector;
            self.hView.orientationAxesView.hAx.CameraTarget=evt.CameraTarget;

        end

        function updateLightPosition(self,evt)



            self.hView.volumeRenderingView.Light.Position=evt.CameraPosition;

        end

    end

    methods

        function set.Interactable(self,TF)
            self.InteractableInternal=TF;
            setInteractivityState(self);
        end

        function TF=get.Interactable(self)
            TF=self.InteractableInternal;
            setInteractivityState(self);
        end

    end

end

function pt=point_on_sphere(src,radius)
    v=src/radius;
    len=v(1)*v(1)+v(2)*v(2);
    if(len>1)
        v=v/len;
        len=1;
    end
    pt=[v,sqrt(1-len)];
end
