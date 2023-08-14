classdef ORB<images.internal.app.registration.model.FeatureProperty





    properties




    end

    properties
        scaleFactor=1.2;
        numLevels=4;
        WarningFlag(1,1)logical=false;
    end

    methods
        function self=ORB()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create ORB object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)

            Iu8=im2uint8(fixed);
            imgSize=size(Iu8);

            minSize=min([size(fixed,1,2),size(moving,1,2)]);

            EdgeThreshold=int32(31);
            FirstLevel=uint8(0);
            SamplingPairs=uint8(2);
            PatchSize=int32(31);
            FastThreshold=uint8(20);
            ScoreType=uint8(0);
            NumFeatures=int32(imgSize(1)*imgSize(2));
            ScaleFactor=single(self.scaleFactor);


            MaxNumLevels=uint8(floor((log(minSize)-log(double(PatchSize)*2+1))/log(double(ScaleFactor)))+1);

            if self.numLevels>MaxNumLevels
                NumLevels=MaxNumLevels;
            else
                NumLevels=uint8(self.numLevels);
            end

            fixedPoints=imagesocvDetectORB(Iu8,NumFeatures,ScaleFactor,...
            NumLevels,EdgeThreshold,FirstLevel,...
            SamplingPairs,ScoreType,PatchSize,FastThreshold);

            fixedPoints.Scale=fixedPoints.Scale/single(PatchSize);

            Iu8=im2uint8(moving);
            imgSize=size(Iu8);
            NumFeatures=int32(imgSize(1)*imgSize(2));

            movingPoints=imagesocvDetectORB(Iu8,NumFeatures,ScaleFactor,...
            NumLevels,EdgeThreshold,FirstLevel,...
            SamplingPairs,ScoreType,PatchSize,FastThreshold);

            movingPoints.Scale=movingPoints.Scale/single(PatchSize);

        end

        function[features,validPoints]=extractFeatures(self,image,points)

            Iu8=im2uint8(image);

            ScaleFactor=single(self.scaleFactor);
            NumLevels=uint8(self.numLevels);


            PatchSize=int32(31);
            EdgeThreshold=int32(31);
            FirstLevel=uint8(0);
            SamplingPairs=uint8(2);
            FastThreshold=uint8(20);
            ScoreTypeCode=uint8(0);
            NumFeatures=int32(numel(image));

            points.Scale=points.Scale*single(PatchSize);
            points.Orientation=points.Orientation*(180/pi);

            [features,validPoints]=imagesocvExtractORB(Iu8,...
            points,NumFeatures,ScaleFactor,...
            NumLevels,EdgeThreshold,FirstLevel,...
            SamplingPairs,ScoreTypeCode,PatchSize,FastThreshold);

            validPoints.Scale=validPoints.Scale/single(PatchSize);

        end

    end

end
