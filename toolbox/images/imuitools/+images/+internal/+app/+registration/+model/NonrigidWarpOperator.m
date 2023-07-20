classdef NonrigidWarpOperator<handle





    properties
demonsProperty
        displacementField;
    end

    methods

        function self=NonrigidWarpOperator()

            self.demonsProperty=images.internal.app.registration.model.DemonsProperty();
        end

        function[registeredImage,movingRGB]=run(self,fixed,moving,movingRGB)
            [estimatedDisplacementField,registeredImage]=imregdemons(moving,fixed,...
            self.demonsProperty.numberOfIterations,...
            'AccumulatedFieldSmoothing',self.demonsProperty.accumulatedFieldSmoothing,...
            'PyramidLevels',self.demonsProperty.pyramidLevels,...
            'DisplayWaitBar',false);

            if~isempty(movingRGB)
                movingRGB=imwarp(movingRGB,estimatedDisplacementField);
            end

            self.displacementField=estimatedDisplacementField;
        end

    end

end
