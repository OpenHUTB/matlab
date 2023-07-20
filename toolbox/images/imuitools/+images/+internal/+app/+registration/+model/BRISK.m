classdef BRISK<images.internal.app.registration.model.FeatureProperty



    properties




    end

    properties(Dependent)
minContrast
minQuality
numOctaves
    end

    methods
        function self=BRISK()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create BRISK object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)

            nOctaves=self.adjustNumOctaves(size(fixed));
            fixedPoints=imagesocvDetectBRISK(im2uint8(fixed),im2uint8(self.minContrast),nOctaves);
            fixedPoints=self.selectPoints(fixedPoints);

            nOctaves=self.adjustNumOctaves(size(moving));
            movingPoints=imagesocvDetectBRISK(im2uint8(moving),im2uint8(self.minContrast),nOctaves);
            movingPoints=self.selectPoints(movingPoints);
        end


        function[features,validPoints]=extractFeatures(self,image,points)




            params.nbOctave=4;
            params.orientationNormalized=~self.upright;
            params.scaleNormalized=true;
            params.patternScale=7;

            len=size(points.Location,1);
            pointsTemp=points;
            pointsTemp.Misc=(int32(1):int32(len))';


            pointsTemp.Scale=pointsTemp.Scale.*(18/12);

            Iu8=im2uint8(image);
            [vPoints,features]=imagesocvExtractFREAK(Iu8,pointsTemp,params);


            if self.upright

                vPoints.Orientation(:)=single(pi/2);
            else
                vPoints.Orientation(:)=single(2*pi)-vPoints.Orientation;
            end



            validPoints.Location=points.Location(vPoints.Misc,:);
            validPoints.Scale=points.Scale(vPoints.Misc);
            validPoints.Metric=points.Metric(vPoints.Misc);

            validPoints.Orientation=vPoints.Orientation;


        end


        function nOctaves=adjustNumOctaves(self,imageSize)
            maxNumOctaves=uint8(floor(log2(min(imageSize))));
            if self.numOctaves>maxNumOctaves
                nOctaves=maxNumOctaves;
            else
                nOctaves=uint8(self.numOctaves);
            end
        end


        function outputPoints=selectPoints(self,inputPoints)
            if isempty(inputPoints)
                outputPoints=inputPoints;
            else
                maxMetric=max(inputPoints.Metric);
                minMetric=self.minQuality*maxMetric;
                idx=inputPoints.Metric>=minMetric;
                outputPoints.Location=inputPoints.Location(idx,:);
                outputPoints.Scale=inputPoints.Scale(idx);
                outputPoints.Metric=inputPoints.Metric(idx);
                outputPoints.Orientation=inputPoints.Orientation(idx);
            end
        end
    end

    methods

        function val=get.minContrast(self)
            val=0.2+0.8*self.featureNumber-eps;
        end

        function val=get.minQuality(self)
            val=0.1+0.9*self.featureNumber;
        end

        function val=get.numOctaves(self)
            val=round(4-3*self.featureNumber);
        end

    end

end