classdef VolumeToolgroup<handle&matlab.mixin.SetGet




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

    end


    properties(SetAccess=immutable)

        Empty(1,1)logical=false;

    end


    properties(Access=protected,Transient)

        VisibleInternal(1,1)logical=true;
        AlphaInternal(1,1)double=0.5;
        OrientationAxesInternal(1,1)logical=false;
        WireframeInternal(1,1)logical=false;

    end


    properties(SetAccess=protected,Hidden,Transient)



        BackgroundColor(1,3)double=[0.215,0.215,0.275];

    end


    properties(GetAccess={?uitest.factory.Tester,...
        ?images.uitest.factory.Tester,...
        ?images.internal.app.segmenter.volume.display.VolumeToolgroup},SetAccess=protected,Transient)


        Camera images.internal.app.segmenter.volume.display.Camera

        DirtyPanel matlab.ui.container.Panel
        DirtyImage matlab.graphics.primitive.Image

        Panel matlab.ui.container.Panel

        VolumeTransform matlab.graphics.primitive.Transform

Datatip

Tag
    end


    properties(Access=protected,Hidden,Transient)


        Primitive matlab.graphics.primitive.world.osg.Volume
        LabelPrimitive matlab.graphics.primitive.world.osg.Volume
        OrientationAxesPrimitive matlab.graphics.primitive.world.osg.Volume

Canvas
        SizeChangedListener event.listener

        IsMerged(1,1)logical=true;

    end


    properties(SetAccess=protected,Dependent)

Data
LabelData

XLimits
YLimits
ZLimits

    end


    properties(Access=protected,Constant)

        DefaultAlphaFunc=0.02;
        DefaultSampleDensity=0.005;

        DataMax=intmax('uint8');
        MergedVolumeBuffer=(intmax('uint8')/2)+1;

    end


    methods




        function self=VolumeToolgroup(hfig,pos,show3DDisplay)

            if~show3DDisplay
                self.Empty=true;
                return;
            end

            self.Panel=uipanel('Parent',hfig,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Position',pos,...
            'Visible','off',...
            'Tag','VolumePanel');

            self.DirtyPanel=uipanel('Parent',hfig,...
            'BorderType','none',...
            'Units','pixels',...
            'HandleVisibility','off',...
            'Visible','off',...
            'Position',pos,...
            'Tag','DirtyVolumePanel');

            try %#ok<TRYNC>

                set(self.DirtyPanel,'ButtonDownFcn',@(~,~)notify(self,'RedrawVolume'));
            end

            ax=axes('Parent',self.DirtyPanel,'Units','normalized','Position',[0,0,1,1]);
            self.DirtyImage=imshow(zeros(100),'Parent',ax,'InitialMagnification','fit','Interpolation','nearest');

            self.Datatip=text('Parent',ax,'String',getString(message('images:segmenter:clickToRefresh')),...
            'BackgroundColor',[1,1,1],'EdgeColor',[0,0,0],'Color',[0,0,0],'Visible','off',...
            'PickableParts','none','HitTest','off','VerticalAlignment','bottom','Margin',2);

            set(self.DirtyImage,'PickableParts','none','HitTest','off');

            self.Canvas=getCanvas(self.Panel);

            if isa(self.Canvas,'matlab.graphics.primitive.canvas.HTMLCanvas')
                set(self.Canvas,'ServerSideRendering',true);
                set(self.Panel,'AutoResizeChildren','off');
                set(self.DirtyPanel,'AutoResizeChildren','off');
            end

            self.Camera=images.internal.app.segmenter.volume.display.Camera(self.Canvas);
            addlistener(self.Camera,'MotionFinished',@(~,~)updateAtFullResolution(self));

            createView(self);

        end




        function updateVolume(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            [m,n,p]=size(vol,1:3);
            updateDataLimits(self,n,m,p);

            updateVolumeHeavyweight(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels);

        end




        function updateVolumeHeavyweight(self,vol,labels,amapVol,cmapVol,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            self.LabelPrimitive.SampleDensity=self.DefaultSampleDensity;
            self.Primitive.SampleDensity=self.DefaultSampleDensity;

            markVolumeAsClean(self);

            if~isempty(labels)&&max(labels(:))>self.DataMax-self.MergedVolumeBuffer


                self.IsMerged=false;
                self.Data=zeros(3,3,3,'uint8');
                self.LabelData=labels;

            else

                if~self.IsMerged


                    self.LabelData=zeros(3,3,3,'uint8');
                end

                self.IsMerged=true;
                [vol,cmapVol,amapVol]=merge(self,vol,labels,amapLabels,cmapVol,amapVol);
                self.Data=vol;

            end

            updateRGBA(self,amapVol,cmapVol,amapLabels,cmapLabels);

        end




        function updateRGBA(self,amapData,cmapData,amapLabels,cmapLabels)

            if~self.Visible||self.Empty
                return;
            end

            amapLabels=amapLabels*self.AlphaInternal;

            if self.IsMerged

                amap=[amapData(1);amapData(2:2:end);amapLabels(1:self.DataMax-self.MergedVolumeBuffer+1)];
                cmap=[cmapData(1,:);cmapData(2:2:end,:);cmapLabels(1:self.DataMax-self.MergedVolumeBuffer+1,:)];



                self.Primitive.TransferFunction=im2uint8(double([cmap,amap]'));

            else


                self.Primitive.TransferFunction=im2uint8(double([cmapData,amapData]'));
                self.LabelPrimitive.TransferFunction=im2uint8(double([cmapLabels,amapLabels]'));

            end

        end




        function setBackgroundColor(self,color)

            if self.Empty
                return;
            end

            self.Canvas.Color=color;
            self.DirtyPanel.BackgroundColor=color;

            s=settings;
            s.images.VolumeSegmenter.BackgroundColor.PersonalValue=color;

        end




        function delete(self)

            delete(self.Canvas);
            delete(self.VolumeTransform);
            delete(self.Panel);

            delete(self.SizeChangedListener);
            delete(self);

        end




        function scroll(self,scrollCount)

            if self.Empty
                return;
            end



            dens=self.Primitive.SampleDensityWhenMoving;
            self.Primitive.SampleDensityWhenMoving=self.DefaultSampleDensity;

            scroll(self.Camera,scrollCount);

            self.Primitive.SampleDensityWhenMoving=dens;

        end




        function resize(self,pos)

            if self.Empty
                return;
            end

            if~isequal(self.Panel.Position,pos)

                self.Panel.Position=pos;
                self.DirtyPanel.Position=pos;

            end

        end




        function clear(self)

            if self.Empty
                return;
            end

            self.Primitive.Data=zeros(3,3,3,'uint8');
            self.LabelPrimitive.Data=zeros(3,3,3,'uint8');
            updateDataLimits(self,3,3,3);

            self.Panel.Visible='off';
            self.DirtyPanel.Visible='off';
            self.Datatip.Visible='off';

        end




        function reset(self)

            if self.Empty
                return;
            end

            reset(self.Camera);

        end




        function markVolumeAsDirty(self)

            if self.Empty
                return;
            end

            bufferSize=5;

            if strcmp(self.DirtyPanel.Visible,'off')

                try

                    I=getframe(self.DirtyPanel.Parent);
                    im=I.cdata;
                catch
                    pos=self.Panel.Position;
                    im=im2uint8(repmat(permute(self.BackgroundColor,[1,3,2]),[pos(4),pos(3),1]));
                end

                [refreshIcon,~,alpha]=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+segmenter','+volume','+icons','Volume_Warning_30.png'));

                iconSize=size(refreshIcon);
                imageSize=size(im);

                if~any(iconSize(1:2)>imageSize(1:2)+bufferSize)

                    regionToBlend=im2single(im(1+bufferSize:iconSize(1)+bufferSize,1+bufferSize:iconSize(2)+bufferSize,:));

                    alpha=im2single(repmat(alpha,[1,1,3]));

                    blendedRegion=(regionToBlend.*(1-alpha))+(im2single(refreshIcon).*alpha);

                    im(1+bufferSize:iconSize(1)+bufferSize,1+bufferSize:iconSize(2)+bufferSize,:)=im2uint8(blendedRegion);

                end

                self.DirtyImage.CData=im;

                xLim=get(self.DirtyImage,'XData')+[-0.5,0.5];
                yLim=get(self.DirtyImage,'YData')+[-0.5,0.5];
                set(self.DirtyImage.Parent,'XLim',xLim,'YLim',yLim);

                set(self.Datatip,'Position',[0,self.DirtyImage.YData(2),0]);

            end

            self.Panel.Visible='off';
            self.DirtyPanel.Visible='on';

        end




        function markVolumeAsClean(self)

            self.Panel.Visible='on';
            self.DirtyPanel.Visible='off';
            self.Datatip.Visible='off';

        end




        function showDatatip(self,TF)

            if self.Empty
                return;
            end

            if self.DirtyPanel.Visible
                self.Datatip.Visible=TF;
            else
                self.Datatip.Visible=false;
            end

        end




        function setOrientationAxes(self,TF,wireframeTF)

            self.OrientationAxesInternal=TF;
            self.WireframeInternal=wireframeTF;
            setOrientationAxesColormap(self);

        end




        function setTag(self,tag)
            self.Tag=tag;
        end
    end


    methods(Access=protected)


        function[vol,cmap,volamap]=merge(self,vol,label,amap,cmap,volamap)




            if ndims(vol)>3

                sz=size(vol);
                vol=reshape(vol,[sz(1),sz(2)*sz(3),sz(4)]);
                [vol,newmap]=rgb2ind(vol,double(self.MergedVolumeBuffer-1),'dither');

                if size(newmap,1)<self.MergedVolumeBuffer-1
                    newmap(end+1:self.MergedVolumeBuffer-2,:)=0;
                end

                newmap=imresize(newmap,[256,3],'nearest');

                cmap(2:end,:)=newmap(1:255,:);
                vol=reshape(vol,sz(1:3))+1;

                idx=find(volamap);

                if~isempty(idx)
                    pct=(idx(1)-1)/255;
                    volamap(all(cmap<pct,2))=0;
                end

            else



                vol=vol(:,:,:,1)/2;

            end

            if~isempty(label)




                maxlabel=max(label(:));

                for idx=1:self.DataMax-self.MergedVolumeBuffer




                    if amap(idx+1)>0&&idx<=maxlabel
                        vol(label==(idx))=idx+self.MergedVolumeBuffer;
                    end

                end

            end

        end


        function createView(self)



            self.VolumeTransform=matlab.graphics.primitive.Transform('Parent',self.Camera.Primitive,'Internal',true);


            createPrimitive(self);


            self.SizeChangedListener=event.listener(self.Panel,'SizeChanged',@(~,~)setCameraViewport(self));

            self.Camera.Units='pixels';

            setCameraViewport(self);

            s=settings;
            color=s.images.VolumeSegmenter.BackgroundColor.ActiveValue;

            if isnumeric(color)
                self.BackgroundColor=color;
            end

            self.Canvas.Color=self.BackgroundColor;
            self.DirtyPanel.BackgroundColor=self.BackgroundColor;

        end


        function createPrimitive(self)

            self.OrientationAxesPrimitive=matlab.graphics.primitive.world.osg.Volume();
            self.OrientationAxesPrimitive.Data=zeros(3,3,3,'uint8');
            self.OrientationAxesPrimitive.TransferFunction=im2uint8([0,0,0,0;1,0,0,1;0,1,0,1;0,0,1,1;zeros([252,4],'single')]');
            self.OrientationAxesPrimitive.Parent=self.VolumeTransform;
            self.OrientationAxesPrimitive.SampleDensity=self.DefaultSampleDensity;
            self.OrientationAxesPrimitive.SampleDensityWhenMoving=self.DefaultSampleDensity*2;
            self.OrientationAxesPrimitive.AlphaFunc=self.DefaultAlphaFunc;
            self.OrientationAxesPrimitive.Interpolation='Nearest';
            self.OrientationAxesPrimitive.Isosurface=0;
            self.OrientationAxesPrimitive.MaximumIntensityProjection=0;


            self.Primitive=matlab.graphics.primitive.world.osg.Volume();
            self.Primitive.Data=zeros(3,3,3,'uint8');
            self.Primitive.TransferFunction=im2uint8([gray(256),linspace(0,1,256)']');
            self.Primitive.Parent=self.VolumeTransform;
            self.Primitive.SampleDensity=self.DefaultSampleDensity;
            self.Primitive.SampleDensityWhenMoving=self.DefaultSampleDensity*2;
            self.Primitive.AlphaFunc=self.DefaultAlphaFunc;
            self.Primitive.Interpolation='Nearest';
            self.Primitive.Isosurface=0;
            self.Primitive.MaximumIntensityProjection=0;


            self.LabelPrimitive=matlab.graphics.primitive.world.osg.Volume();
            self.LabelPrimitive.Data=zeros(3,3,3,'uint8');
            self.LabelPrimitive.TransferFunction=im2uint8([images.internal.app.segmenter.volume.data.colorOrder(),[0;ones([255,1],'single')]]');
            self.LabelPrimitive.Parent=self.VolumeTransform;
            self.LabelPrimitive.SampleDensity=self.DefaultSampleDensity;
            self.LabelPrimitive.SampleDensityWhenMoving=self.DefaultSampleDensity*2;
            self.LabelPrimitive.AlphaFunc=self.DefaultAlphaFunc;
            self.LabelPrimitive.Interpolation='Nearest';
            self.LabelPrimitive.Isosurface=0;
            self.LabelPrimitive.MaximumIntensityProjection=0;

            data=zeros(100,100,100,'uint8');
            data(:,1,1)=1;
            data(1,:,1)=2;
            data(1,1,:)=3;
            data(:,end,end)=4;
            data(end,:,end)=4;
            data(end,end,:)=4;
            data(:,1,end)=4;
            data(:,end,1)=4;
            data(1,:,end)=4;
            data(end,:,1)=4;
            data(1,end,:)=4;
            data(end,1,:)=4;

            self.OrientationAxes=self.OrientationAxesInternal;

            self.OrientationAxesPrimitive.Data=data;

            self.setPrimitiveRenderingTechnique();

        end


        function setCameraViewport(self)

            panelUnits=self.Panel.Units;


            self.Panel.Units='pixels';
            newFigSize=self.Panel.Position;

            fullyInitialzedState=strcmp(self.Camera.Units,'pixels');

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

                self.Camera.Position=pos;

            end


            self.Panel.Units=panelUnits;

        end


        function updateDataLimits(self,numSlicesInX,numSlicesInY,numSlicesInZ)





            self.Camera.Units='normalized';
            drawnow;

            self.XLimits=[0.5,numSlicesInX+0.5];
            self.YLimits=[0.5,numSlicesInY+0.5];
            self.ZLimits=[0.5,numSlicesInZ+0.5];



            self.Camera.Units='pixels';

        end


        function setOrientationAxesColormap(self)

            if self.OrientationAxesInternal
                if self.WireframeInternal
                    self.OrientationAxesPrimitive.TransferFunction=im2uint8([0,0,0,0;1,0,0,1;0,1,0,1;0,0,1,1;0.5,0.5,0.5,1;zeros([251,4],'single')]');
                else
                    self.OrientationAxesPrimitive.TransferFunction=im2uint8([0,0,0,0;1,0,0,1;0,1,0,1;0,0,1,1;zeros([252,4],'single')]');
                end
                self.OrientationAxesPrimitive.Visible='on';
            elseif self.WireframeInternal
                self.OrientationAxesPrimitive.TransferFunction=im2uint8([0,0,0,0;0.5,0.5,0.5,1;0.5,0.5,0.5,1;0.5,0.5,0.5,1;0.5,0.5,0.5,1;zeros([251,4],'single')]');
                self.OrientationAxesPrimitive.Visible='on';
            else
                self.OrientationAxesPrimitive.Visible='off';
            end

            if self.Dirty
                notify(self,'RedrawVolume');
            end

            drawnow;
        end

    end

    methods

        function updateAtFullResolution(self)









            self.Canvas.Color=self.Canvas.Color;

        end


        function setPrimitiveRenderingTechnique(self)



            if iptgetpref('VolumeViewerUseHardware')
                self.Primitive.VolumeTechnique='RayTraced';
                self.LabelPrimitive.VolumeTechnique='RayTraced';
                self.OrientationAxesPrimitive.VolumeTechnique='RayTraced';
            else
                self.Primitive.VolumeTechnique='FixedFunction';
                self.LabelPrimitive.VolumeTechnique='FixedFunction';
                self.OrientationAxesPrimitive.VolumeTechnique='FixedFunction';
            end
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

            self.Camera.Interactable=TF;

        end

        function TF=get.Enabled(self)

            if self.Empty
                TF=false;
            else
                TF=self.Camera.Interactable;
            end

        end




        function set.Transform(self,tform)

            if self.Empty
                return;
            end

            self.VolumeTransform.Matrix=tform;

        end

        function tform=get.Transform(self)

            if self.Empty
                tform=eye(4);
            else
                tform=self.VolumeTransform.Matrix;
            end

        end




        function set.Data(self,volData)

            if self.Empty
                return;
            end

            if isempty(volData)
                volData=zeros(3,3,3,'uint8');
            end

            self.Primitive.Data=permute(volData,[2,1,3]);

        end

        function vol=get.Data(self)

            vol=permute(self.Primitive.Data,[2,1,3]);

        end




        function set.LabelData(self,volData)

            if self.Empty
                return;
            end

            if isempty(volData)
                volData=zeros(3,3,3,'uint8');
            end

            self.LabelPrimitive.Data=permute(volData,[2,1,3]);

        end

        function vol=get.LabelData(self)

            vol=permute(self.LabelPrimitive.Data,[2,1,3]);

        end




        function set.XLimits(self,xlim)

            self.Primitive.XLim=xlim;
            self.LabelPrimitive.XLim=xlim;
            self.OrientationAxesPrimitive.XLim=xlim;

        end

        function lim=get.XLimits(self)

            lim=self.Primitive.XLim;

        end




        function set.YLimits(self,ylim)

            self.Primitive.YLim=ylim;
            self.LabelPrimitive.YLim=ylim;
            self.OrientationAxesPrimitive.YLim=ylim;

        end

        function lim=get.YLimits(self)

            lim=self.Primitive.YLim;

        end




        function set.ZLimits(self,zlim)

            self.Primitive.ZLim=zlim;
            self.LabelPrimitive.ZLim=zlim;
            self.OrientationAxesPrimitive.ZLim=zlim;

        end

        function lim=get.ZLimits(self)

            lim=self.Primitive.ZLim;

        end




        function set.Alpha(self,val)

            self.AlphaInternal=val;
            markVolumeAsDirty(self);

        end

        function val=get.Alpha(self)

            val=self.AlphaInternal;

        end




        function set.OrientationAxes(self,val)

            self.OrientationAxesInternal=val;
            setOrientationAxesColormap(self);

        end

        function val=get.OrientationAxes(self)

            val=self.OrientationAxesInternal;

        end




        function set.Wireframe(self,val)

            self.WireframeInternal=val;
            setOrientationAxesColormap(self);

        end

        function val=get.Wireframe(self)

            val=self.WireframeInternal;

        end




        function TF=get.Dirty(self)

            if self.Empty
                TF=false;
            else
                TF=strcmp(self.DirtyPanel.Visible,'on');
            end

        end

    end


end