

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
    end


    properties
Alphamap
LabelColors
    end

    methods
        function obj=LabelOverlayConfiguration(labelConfig,intensityBreakdownIdx)

            import images.internal.app.volviewToolgroup.*

            obj.RenderingStyle='LabelOverlayRendering';
            obj.Lighting=false;
            obj.Threshold=100;
            obj.OpacityValue=0.50;
            obj.computeOverlayConfiguration(labelConfig,intensityBreakdownIdx)

        end

        function computeOverlayConfiguration(self,labelConfig,intensityBreakdownIdx)

            numLabels=labelConfig.NumLabels;

            self.Labels=labelConfig.Labels;
            self.NumLabels=labelConfig.NumLabels;
            self.LabelNames=labelConfig.LabelNames;
            self.Opacities=labelConfig.Opacities;
            self.ShowFlags=labelConfig.ShowFlags;
            self.ShowLabelThumbs=labelConfig.ShowLabelThumbs;
            self.LabelColors=labelConfig.LabelColors;

            cmap=zeros(256,3);
            cmap(1:intensityBreakdownIdx,:)=gray(intensityBreakdownIdx);
            cmap(intensityBreakdownIdx+1:intensityBreakdownIdx+numLabels,:)=labelConfig.LabelColors;
            self.Colormap=cmap;

            self.Alphamap=self.computeAlphamap(intensityBreakdownIdx);
        end


        function amap=computeAlphamap(self,intensityBreakdownIdx)



            numValues=256;

            amapUniform=zeros(1,numValues);
            stepStart=self.Threshold;
            stepEnd=min(self.Threshold+56,255);
            stepSize=stepEnd-stepStart;

            amapUniform(stepStart+1:stepEnd)=linspace(0,self.OpacityValue,stepSize);
            amapUniform(stepEnd:end)=amapUniform(stepEnd:end)+self.OpacityValue;

            xq=linspace(1,numValues,intensityBreakdownIdx);
            amap=zeros(1,256);
            amap(1:intensityBreakdownIdx)=interp1(1:numValues,amapUniform,xq);
            for i=1:self.NumLabels
                amap(intensityBreakdownIdx+i)=self.ShowFlags(i);
            end

        end

    end
end