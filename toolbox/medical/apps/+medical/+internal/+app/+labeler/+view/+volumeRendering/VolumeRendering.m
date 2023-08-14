classdef VolumeRendering<handle&matlab.mixin.SetGet




    properties

        Volume medical.internal.app.labeler.view.volumeRendering.Volume

        RenderingEditor medical.internal.app.labeler.view.volumeRendering.RenderingEditor

        IsVolumeDisplaySupported(1,1)logical=true;

    end

    properties(Dependent)
ShowMessageVolume
    end

    events

VolumeRenderingStyleChanged

AlphaControlPtsUpdated

ColorControlPtsUpdated

RedrawVolume

RefreshLabels3D

BringAppToFront

WarningThrown

    end

    methods

        function self=VolumeRendering(volumeFig,renderingEditorFig,isVolumeDisplaySupported)

            if~isVolumeDisplaySupported
                self.IsVolumeDisplaySupported=false;
                return;
            end

            wireupVolume(self,volumeFig);
            wireupRenderingEditor(self,renderingEditorFig);

        end


        function delete(self)
            delete(self.RenderingEditor);
            delete(self.Volume);
        end


        function clear(self)

            if~self.IsVolumeDisplaySupported
                return
            end

            self.RenderingEditor.clear();
            self.Volume.clear();

        end


        function redraw(self)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.notify('RedrawVolume')
        end

    end

    methods


        function updateVolume(self,vol,tform,volumeBounds)

            if~self.IsVolumeDisplaySupported
                return
            end


            self.Volume.updateVolume(vol,tform);
            self.Volume.VolumeBounds=volumeBounds;

            self.RenderingEditor.setVolumeBounds(volumeBounds);
            self.RenderingEditor.Visible=true;

        end


        function updateLabels(self,labels)

            if~self.IsVolumeDisplaySupported
                return
            end

            self.Volume.updateLabels(labels);
            self.Volume.IsLabelDirty=false;
        end


        function markLabelVolumeAsDirty(self)

            if~self.IsVolumeDisplaySupported
                return
            end

            self.Volume.IsLabelDirty=true;
        end


        function setVolumeRendering(self,renderingTechnique,volAlphaCP,volColorCP)

            if~self.IsVolumeDisplaySupported
                return
            end

            amap=medical.internal.app.labeler.utils.computeAlphamapFromControlPoints(volAlphaCP,self.Volume.VolumeBounds);
            cmap=medical.internal.app.labeler.utils.computeColormapFromControlPoints(volColorCP,self.Volume.VolumeBounds);


            self.RenderingEditor.updateRendering(renderingTechnique,volAlphaCP,volColorCP);
            self.RenderingEditor.updateBackgroundColormap(cmap);

            self.Volume.updateVolumeRendering(renderingTechnique,cmap,amap);

        end


        function[renderer,colorCP,alphaCP]=getRendering(self)

            if~self.IsVolumeDisplaySupported
                return
            end

            [renderer,colorCP,alphaCP]=self.RenderingEditor.getRendering();
        end


        function setOrientationAxesLabels(self,axesLabels)

            if~self.IsVolumeDisplaySupported
                return
            end

            self.Volume.OrientationAxesLabels=axesLabels;
        end


        function setBackgroundGradient(self,TF)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.BackgroundGradient=TF;

        end


        function TF=getBackgroundGradient(self)

            TF=false;
            if~self.IsVolumeDisplaySupported
                return
            end
            TF=self.Volume.BackgroundGradient;

        end


        function color=getVolumeBackgroundColor(self)

            color=[];
            if~self.IsVolumeDisplaySupported
                return
            end

            color=self.Volume.BackgroundColor;

        end


        function setVolumeBackgroundColor(self,color)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.BackgroundColor=color;

        end


        function color=getVolumeGradientColor(self)

            color=[];
            if~self.IsVolumeDisplaySupported
                return
            end
            color=self.Volume.GradientColor;

        end


        function setVolumeGradientColor(self,color)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.GradientColor=color;

        end


        function restoreVolumeBackground(self)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.restoreVolumeBackground();

        end


        function setOrientationAxes(self,TF)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.DisplayOrientationAxes=TF;

        end


        function setScaleBar(self,TF)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.DisplayScaleBar=TF;

        end


        function TF=getVolumeVisiblity(self)

            if~self.IsVolumeDisplaySupported
                return
            end
            TF=self.Volume.Visible;

        end


        function setVolumeVisiblity(self,TF)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.Visible=TF;

        end


        function updateLabelAlpha(self,labelOpacity)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.LabelAlpha=labelOpacity;

        end


        function updateLabelColor(self,labelColormap)

            if~self.IsVolumeDisplaySupported
                return
            end
            self.Volume.LabelColor=labelColormap;

        end

    end

    methods(Access=protected)

        function wireupVolume(self,volumeFig)

            self.Volume=medical.internal.app.labeler.view.volumeRendering.Volume(volumeFig);
            addlistener(self.Volume,'RefreshLabels3D',@(src,evt)self.notify('RefreshLabels3D'));
            addlistener(self.Volume,'WarningThrown',@(src,evt)self.notify('WarningThrown',evt));

        end

        function wireupRenderingEditor(self,renderingEditorFig)

            self.RenderingEditor=medical.internal.app.labeler.view.volumeRendering.RenderingEditor(renderingEditorFig);

            addlistener(self.RenderingEditor,'VolumeRenderingStyleChanged',@(src,evt)self.reactToVolumeRenderingStyleChanged(evt));
            addlistener(self.RenderingEditor,'AlphaControlPtsUpdated',@(src,evt)self.reactToAlphamapUpdate(evt));
            addlistener(self.RenderingEditor,'ColorControlPtsUpdated',@(src,evt)self.reactToColormapUpdate(evt));
            addlistener(self.RenderingEditor,'BringAppToFront',@(src,evt)self.notify('BringAppToFront'));

        end

    end


    methods(Access=protected)

        function reactToVolumeRenderingStyleChanged(self,evt)

            self.Volume.VolumeRenderingStyle=string(evt.Value);

            self.notify('VolumeRenderingStyleChanged',evt)

        end

        function reactToAlphamapUpdate(self,evt)

            amap=medical.internal.app.labeler.utils.computeAlphamapFromControlPoints(evt.Value,self.Volume.VolumeBounds);
            self.Volume.VolumeAlpha=amap;

            self.notify('AlphaControlPtsUpdated',evt);

        end

        function reactToColormapUpdate(self,evt)

            cmap=medical.internal.app.labeler.utils.computeColormapFromControlPoints(evt.Value,self.Volume.VolumeBounds);
            self.Volume.VolumeColor=cmap;

            self.RenderingEditor.updateBackgroundColormap(cmap);

            self.notify('ColorControlPtsUpdated',evt);

        end

    end


    methods


        function TF=get.ShowMessageVolume(self)
            TF=self.Volume.ShowMessage;
        end

        function set.ShowMessageVolume(self,TF)
            self.Volume.ShowMessage=TF;
        end

    end

end
