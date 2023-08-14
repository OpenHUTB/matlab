classdef FeatureOperator<images.internal.app.registration.model.RigidWarpOperator





    properties


featureProperty

fixedPoints
movingPoints

fixedFeatures
movingFeatures

fixedValidPoints
movingValidPoints

indexPairs

fixedMatchedPoints
movingMatchedPoints

numberOfFeatures
timeToCompute

    end

    methods

        function self=FeatureOperator()

            self.featureProperty=[];
            self.tformType='projective';
        end

        function getMatchingFeatures(self,fixed,moving,matchMetric)
            [self.fixedPoints,self.movingPoints]=self.featureProperty.detectFeatures(fixed,moving);
            self.extractFeatures(fixed,moving);
            self.matchFeatures(matchMetric);
        end

        function[registeredImage,movingRGB]=run(self,~,moving,movingRGB,fixedRefObj,movingRefObj)


            [tform,~,~]=...
            images.internal.app.registration.model.imEstimateGeometricTransform(...
            self.movingMatchedPoints,self.fixedMatchedPoints,...
            self.tformType);

            self.tform=self.moveTransformationToWorldCoordinateSystem(tform,movingRefObj,fixedRefObj);


            registeredImage=imwarp(moving,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);

            if~isempty(movingRGB)
                movingRGB=imwarp(movingRGB,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);
            end

        end

        function[]=extractFeatures(self,fixed,moving)

            [self.fixedFeatures,fixedValidPointsStruct]=...
            self.featureProperty.extractFeatures(fixed,self.fixedPoints);
            self.fixedValidPoints=fixedValidPointsStruct.Location;
            [self.movingFeatures,movingValidPointsStruct]=...
            self.featureProperty.extractFeatures(moving,self.movingPoints);
            self.movingValidPoints=movingValidPointsStruct.Location;
        end

        function[]=matchFeatures(self,matchMetric)

            try
                self.indexPairs=images.internal.app.registration.model.imMatchFeatures(...
                self.fixedFeatures,self.movingFeatures,...
                'MatchThreshold',self.featureProperty.matchThreshold,...
                'MaxRatio',self.featureProperty.maxRatio,...
                'Metric',matchMetric);
                self.fixedMatchedPoints=self.fixedValidPoints(self.indexPairs(:,1),:);
                self.movingMatchedPoints=self.movingValidPoints(self.indexPairs(:,2),:);
            catch
                self.fixedMatchedPoints=[NaN,NaN];
                self.movingMatchedPoints=[NaN,NaN];
            end

        end
    end

end
