classdef FAST<images.internal.app.registration.model.FeatureProperty



    properties




    end

    properties(Dependent)
minContrast
minQuality
    end

    methods
        function self=FAST()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create FAST object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)


            fixedu8=im2uint8(fixed);
            assert(size(fixedu8,3)==1);
            movingu8=im2uint8(moving);
            assert(size(movingu8,3)==1);



            fixedPoints=imagesocvDetectFAST(fixedu8,im2uint8(self.minContrast));
            fixedPoints=self.applyMinQuality(fixedPoints);
            movingPoints=imagesocvDetectFAST(movingu8,im2uint8(self.minContrast));
            movingPoints=self.applyMinQuality(movingPoints);

        end


        function[features,validPoints]=extractFeatures(self,image,points)




            params.nbOctave=4;
            params.orientationNormalized=~self.upright;
            params.scaleNormalized=true;
            params.patternScale=7;

            len=size(points.Location,1);
            pointsTemp=points;
            pointsTemp.Misc=(int32(1):int32(len))';


            pointsTemp.Scale=ones(size(points.Metric),'single').*18;
            pointsTemp.Orientation=zeros(size(points.Metric),'single');

            Iu8=im2uint8(image);
            [vPoints,features]=imagesocvExtractFREAK(Iu8,pointsTemp,params);


            if self.upright

                vPoints.Orientation(:)=single(pi/2);
            else
                vPoints.Orientation(:)=single(2*pi)-vPoints.Orientation;
            end



            validPoints.Location=pointsTemp.Location(vPoints.Misc,:);
            validPoints.Metric=pointsTemp.Metric(vPoints.Misc);
        end


        function outputPoints=applyMinQuality(self,points)



            if~isempty(points.Metric)
                threshold=self.minQuality*max(points.Metric);

                validIndex=points.Metric>=threshold;
                outputPoints.Location=points.Location(validIndex,:);
                outputPoints.Metric=points.Metric(validIndex);
            else
                outputPoints.Location=zeros(0,2,'like',points.Location);
                outputPoints.Metric=zeros(0,1,'like',points.Metric);
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

    end
end