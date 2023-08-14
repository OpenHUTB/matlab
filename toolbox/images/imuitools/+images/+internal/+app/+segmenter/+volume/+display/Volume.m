classdef Volume<handle&matlab.mixin.SetGet




    events

RedrawVolume

    end


    properties(Dependent)


Transform


Enabled


Visible


Alpha


OrientationAxes


Wireframe

    end

    properties(Dependent,SetAccess=protected)

Dirty
Data
OverlayData

    end


    properties(SetAccess=immutable)

        Empty(1,1)logical=false;

    end


    properties(Access=protected,Transient)

        VisibleInternal(1,1)logical=true;
        AlphaInternal(1,1)double=0.5;

    end


    properties(SetAccess=protected,Hidden,Transient)



        BackgroundColor(1,3)double=[0.0,0.329,0.529];
        GradientColor(1,3)double=[0.0,0.561,1.0];
        UseGradient(1,1)logical=true;

    end


    properties(GetAccess={?uitest.factory.Tester,...
        ?images.uitest.factory.Tester,...
        ?images.internal.app.segmenter.volume.display.Volume},SetAccess=protected,Transient)

GridLayout
Viewer
VolumeObject
TooltipText

        Tag=''

    end


    methods




        function self=Volume(hfig,show3DDisplay)

            if~show3DDisplay
                self.Empty=true;
                return;
            end

            self.GridLayout=uigridlayout(hfig,[1,1],'Padding',0);

            self.Viewer=images.ui.graphics3d.Viewer3D(self.GridLayout,'Tag','Viewer3D');

            self.VolumeObject=images.ui.graphics3d.Volume(self.Viewer,...
            'RescaleOverlayData',false,'Tag','VolumeObject','RescaleData',false,'Visible','on',...
            'RenderingStyle','GradientOpacity','GradientOpacityValue',0.2);

            self.TooltipText=getString(message('images:segmenter:clickToRefresh'));

            s=settings;
            color=s.images.VolumeSegmenter.BackgroundColor.ActiveValue;

            if isnumeric(color)
                self.BackgroundColor=color;
            end

            color=s.images.VolumeSegmenter.GradientColor.ActiveValue;
            if isnumeric(color)
                self.GradientColor=color;
            end

            self.UseGradient=s.images.VolumeSegmenter.BackgroundGradient.ActiveValue;

            set(self.Viewer,'BackgroundColor',self.BackgroundColor,'GradientColor',self.GradientColor,...
            'BackgroundGradient',self.UseGradient,'Interactions',["rotate","pan","zoom"]);

        end




        function updateVolume(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            updateVolumeHeavyweight(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels);

        end




        function updateVolumeHeavyweight(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            set(self.VolumeObject,'Data',vol,'OverlayData',labels,'Visible','on');

            markVolumeAsClean(self);

            updateRGBA(self,amapVol,cmapVol,amapLabels,cmapLabels);

        end




        function updateRGBA(self,amapData,cmapData,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            amapLabels=amapLabels*self.AlphaInternal;

            set(self.VolumeObject,'Colormap',cmapData,'Alphamap',amapData,...
            'OverlayColormap',cmapLabels,'OverlayAlphamap',amapLabels);

        end




        function setBackgroundGradient(self,useGrad)

            if self.Empty
                return;
            end

            self.UseGradient=useGrad;
            set(self.Viewer,'BackgroundGradient',useGrad);

            s=settings;
            s.images.VolumeSegmenter.BackgroundGradient.PersonalValue=logical(useGrad);

        end




        function setGradientColor(self,color)

            if self.Empty
                return;
            end

            self.GradientColor=color;
            set(self.Viewer,'GradientColor',color);

            s=settings;
            s.images.VolumeSegmenter.GradientColor.PersonalValue=color;

        end




        function setBackgroundColor(self,color)

            if self.Empty
                return;
            end

            self.BackgroundColor=color;
            set(self.Viewer,'BackgroundColor',color);

            s=settings;
            s.images.VolumeSegmenter.BackgroundColor.PersonalValue=color;

        end




        function delete(self)

            delete(self.Viewer);
            delete(self.GridLayout);

            delete(self);

        end




        function scroll(self,~)

            if self.Empty
                return;
            end

        end




        function resize(self,~)

            if self.Empty
                return;
            end

        end




        function clear(self)

            if self.Empty
                return;
            end

            set(self.VolumeObject,'Data',[],'OverlayData',[]);

        end




        function reset(self)

            if self.Empty
                return;
            end

        end




        function markVolumeAsDirty(self)

            if self.Empty
                return;
            end

            set(self.Viewer,'Badge','warning','Tooltip',self.TooltipText);

        end




        function markVolumeAsClean(self)

            set(self.Viewer,'Badge','none','Tooltip','');

        end




        function showDatatip(self,~)

            if self.Empty
                return;
            end

        end




        function setOrientationAxes(self,TF,wireframeTF)

            set(self.Viewer,'OrientationAxes',TF,'Box',wireframeTF);

        end




        function setTag(self,tag)
            self.Tag=tag;
        end

    end

    methods




        function set.Visible(self,TF)

            self.VisibleInternal=TF;

            if~TF
                clear(self);
            end

        end

        function TF=get.Visible(self)

            TF=self.VisibleInternal;

        end




        function set.Enabled(self,TF)

            if self.Empty
                return;
            end

            if TF
                self.Viewer.Interactions=["rotate","pan","zoom"];
            else
                self.Viewer.Interactions="none";
            end

        end

        function TF=get.Enabled(self)

            if self.Empty
                TF=false;
            else
                TF=all(self.Viewer.Interactions~="none");
            end

        end




        function set.Transform(self,tform)

            if self.Empty
                return;
            end

            self.VolumeObject.Transformation=tform';

        end

        function tform=get.Transform(self)

            if self.Empty
                tform=eye(4);
            else
                tform=self.VolumeObject.Transformation.T;
            end

        end




        function set.Alpha(self,val)

            self.AlphaInternal=val;
            self.VolumeObject.OverlayAlphamap=val;

        end

        function val=get.Alpha(self)

            val=self.AlphaInternal;

        end




        function set.OrientationAxes(self,val)

            set(self.Viewer,'OrientationAxes',val);

        end

        function val=get.OrientationAxes(self)

            if self.Empty
                val=false;
            else
                val=logical(self.Viewer.OrientationAxes);
            end

        end




        function set.Wireframe(self,val)

            set(self.Viewer,'Box',val);

        end

        function val=get.Wireframe(self)

            if self.Empty
                val=false;
            else
                val=logical(self.Viewer.Box);
            end

        end




        function TF=get.Dirty(self)

            if self.Empty
                TF=false;
            else
                TF=strcmp(self.Viewer.Badge,'warning');
            end

        end


        function data=get.Data(self)
            data=self.VolumeObject.Data;
        end

        function data=get.OverlayData(self)
            data=self.VolumeObject.OverlayData;
        end

    end


end