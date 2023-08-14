classdef(Abstract)IterativeIntensityProperty



    properties
optimizer
metric
        normalize=false;
        applyBlur=false;
        blurValue=0.5;
        pyramidLevels=3;
        alignCenters='geometric';
    end

end