



classdef LabelOverlayConfiguration<handle

    properties
RenderingStyle
AlphaControlPoints
ColorControlPoints
VolumeColormapName
Lighting

NumLabels
Labels
LabelNames
ShowLabelThumbs
Colormap
ShowFlags
Opacities
Threshold
OpacityValue

OverlayColormap
OverlayAlphamap
    end


    properties
Alphamap
LabelColors
    end

    methods
        function obj=LabelOverlayConfiguration(labelConfig)

            import images.internal.app.volview.*

            obj.RenderingStyle='LabelOverlayRendering';
            obj.Lighting=false;
            obj.Threshold=100;
            obj.OpacityValue=0.50;
            obj.computeOverlayConfiguration(labelConfig)

        end

        function computeOverlayConfiguration(self,labelConfig)


            self.Labels=labelConfig.Labels;
            self.NumLabels=labelConfig.NumLabels;
            self.LabelNames=labelConfig.LabelNames;
            self.Opacities=labelConfig.Opacities;
            self.ShowFlags=labelConfig.ShowFlags;
            self.ShowLabelThumbs=labelConfig.ShowLabelThumbs;
            self.LabelColors=labelConfig.LabelColors;
            self.Colormap=gray(256);
            self.OverlayColormap=labelConfig.Colormap;

            self.Alphamap=self.computeAlphamap();
            self.OverlayAlphamap=labelConfig.Alphamap;
        end


        function amap=computeAlphamap(self)



            numValues=256;

            amapUniform=zeros(1,numValues);
            stepStart=self.Threshold;
            stepEnd=min(self.Threshold+56,255);
            stepSize=stepEnd-stepStart;

            amapUniform(stepStart+1:stepEnd)=linspace(0,self.OpacityValue,stepSize);
            amapUniform(stepEnd+1:end)=amapUniform(stepEnd+1:end)+self.OpacityValue;

            xq=linspace(1,numValues,256);
            amap=zeros(1,256);
            amap(1:256)=interp1(1:numValues,amapUniform,xq);

        end

    end
end
