classdef Camera<handle




    events


MotionStarted


MotionFinished

    end


    properties(Dependent)


Interactable


Lighting


Units


Position

    end


    properties(Access=private,Transient)


        CameraPosition(1,3)double=[4,4,2.5];
        CameraTarget(1,3)double=[0,0,0];
        CameraUpVector(1,3)double=[0,0,1];
        CameraViewAngle(1,1)double=15;


        ButtonDownListener event.listener
        ButtonMotionRotateListener event.listener
        ButtonUpRotateListener event.listener
        ButtonMotionZoomListener event.listener
        ButtonUpZoomListener event.listener

CamX
CamY
CamZ

ViewportHeight
Radius
Center
CameraDistance

StartPoint
ZoomStartPoint

        InteractableInternal(1,1)logical=true;

    end


    properties(GetAccess={?images.internal.app.segmenter.volume.display.VolumeToolgroup,...
        ?images.uitest.factory.Tester,...
        ?uitest.factory.Tester},SetAccess=private,Transient)

        Primitive matlab.graphics.axis.camera.UniformCamera3D

    end


    properties(GetAccess=?uitest.factory.Tester,SetAccess=private,Transient)

        Light matlab.graphics.primitive.world.LightSource

    end


    methods




        function self=Camera(hCanvas)

            createCamera(self,hCanvas);

            self.ButtonDownListener=event.listener(hCanvas,'ButtonDown',@(src,evt)self.buttonDown(src,evt));
            self.ButtonMotionRotateListener=event.listener(hCanvas,'ButtonMotion',@(src,evt)self.rotateButtonMotion(evt));
            self.ButtonUpRotateListener=event.listener(hCanvas,'ButtonUp',@(src,evt)self.rotateButtonUp(evt));
            self.ButtonMotionZoomListener=event.listener(hCanvas,'ButtonMotion',@(src,evt)self.zoomButtonMotion(evt));
            self.ButtonUpZoomListener=event.listener(hCanvas,'ButtonUp',@(src,evt)self.zoomButtonUp(evt));




            self.ButtonMotionRotateListener.Enabled=false;
            self.ButtonUpRotateListener.Enabled=false;
            self.ButtonMotionZoomListener.Enabled=false;
            self.ButtonUpZoomListener.Enabled=false;

            setInteractivityState(self);

        end




        function reset(self)



            self.CameraPosition=[4,4,2.5];
            self.CameraTarget=[0,0,0];
            self.CameraUpVector=[0,0,1];
            self.CameraViewAngle=15;

            update(self);

        end




        function scroll(self,scrollCount)

            zoomWheel(self,scrollCount);

        end




        function delete(self)

            delete(self.ButtonDownListener);
            delete(self.ButtonMotionRotateListener);
            delete(self.ButtonUpRotateListener);
            delete(self.ButtonMotionZoomListener);
            delete(self.ButtonUpZoomListener);

            delete(self);

        end

    end


    methods(Access=private)


        function createCamera(self,hCanvas)

            self.Primitive=matlab.graphics.axis.camera.UniformCamera3D;
            self.Primitive.DepthSort='on';
            self.Primitive.TransparencyMethodHint='objectsort';
            self.Primitive.Parent=hCanvas;

            set(self.Primitive,...
            'Position',self.CameraPosition,...
            'Target',self.CameraTarget,...
            'UpVector',self.CameraUpVector,...
            'ViewAngle',self.CameraViewAngle);

            self.Light=matlab.graphics.primitive.world.LightSource('Parent',self.Primitive,'Visible','on','Style','ambient');

        end


        function setInteractivityState(self)

            if self.InteractableInternal
                self.ButtonDownListener.Enabled=true;
            else
                self.ButtonDownListener.Enabled=false;
            end

        end


        function buttonDown(self,src,evt)

            pt=[evt.X,evt.Y];
            self.ZoomStartPoint=pt;

            self.CamY=self.CameraUpVector;

            self.CamZ=self.CameraPosition-self.CameraTarget;
            self.CameraDistance=norm(self.CamZ);
            self.CamZ=self.CamZ/self.CameraDistance;

            self.CamY=self.CamY/norm(self.CamY);
            self.CamX=cross(self.CamY,self.CamZ);








            hPanel=ancestor(src,'uipanel');
            vpt=hPanel.Position;

            clickType=images.roi.internal.getClickType(ancestor(hPanel,'figure'));

            vpt(1)=1;
            vpt(2)=1;
            self.Radius=double(min(vpt(3)-vpt(1),vpt(4)-vpt(2))/2);
            self.Center=double([vpt(3)+vpt(1),vpt(4)+vpt(2)]/2);

            self.ViewportHeight=vpt(4)-vpt(1);

            pt(2)=self.ViewportHeight-pt(2);
            self.StartPoint=pointOnSphere(double(pt)-self.Center,self.Radius);

            zoomClickGesture=any(strcmp(clickType,{'ctrl','right'}));

            resetClickGesture=strcmp(clickType,'double');

            if zoomClickGesture
                self.ButtonMotionZoomListener.Enabled=true;
                self.ButtonUpZoomListener.Enabled=true;
            elseif resetClickGesture
                reset(self);
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
            self.CameraPosition=self.CameraPosition/zoomFactor;

            update(self);

        end


        function zoomButtonUp(self,evt)

            self.ButtonMotionZoomListener.Enabled=false;
            self.ButtonUpZoomListener.Enabled=false;

            self.zoomButtonMotion(evt);

            drawnow;


            notify(self,'MotionFinished');

        end


        function rotateButtonMotion(self,evt)

            pt=[evt.X,evt.Y];

            pt(2)=self.ViewportHeight-pt(2);
            currpt=pointOnSphere(double(pt)-self.Center,self.Radius);

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

            new_pos=self.CameraTarget+self.CameraDistance*new_z;

            self.CameraPosition=new_pos;
            self.CameraUpVector=new_y;

            update(self);

        end


        function rotateButtonUp(self,evt)

            self.ButtonMotionRotateListener.Enabled=false;
            self.ButtonUpRotateListener.Enabled=false;

            self.rotateButtonMotion(evt);

            drawnow;


            notify(self,'MotionFinished');

        end


        function zoomWheel(self,scrollCount)

            isZoomIn=scrollCount<0;

            if isZoomIn
                zoomFactor=1.2;
            else
                zoomFactor=1/1.2;
            end

            self.CameraPosition=self.CameraPosition/zoomFactor;

            update(self);

        end


        function update(self)



            self.Primitive.Position=self.CameraPosition;
            self.Primitive.UpVector=self.CameraUpVector;
            self.Primitive.Target=self.CameraTarget;
            self.Primitive.ViewAngle=self.CameraViewAngle;



            self.Light.Position=self.CameraPosition;

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




        function set.Lighting(self,onOff)

            self.Light.Visible=onOff;

        end

        function onOff=get.Lighting(self)

            onOff=self.Light.Visible;

        end




        function set.Position(self,val)

            self.Primitive.Viewport.Position=val;

        end

        function val=get.Position(self)

            val=self.Primitive.Viewport.Position;

        end




        function set.Units(self,val)

            self.Primitive.Viewport.Units=val;

        end

        function val=get.Units(self)

            val=self.Primitive.Viewport.Units;

        end

    end

end


function pt=pointOnSphere(src,radius)
    v=src/radius;
    len=v(1)*v(1)+v(2)*v(2);
    if(len>1)
        v=v/len;
        len=1;
    end
    pt=[v,sqrt(1-len)];
end
