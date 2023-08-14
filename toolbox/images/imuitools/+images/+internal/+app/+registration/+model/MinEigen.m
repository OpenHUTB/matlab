classdef MinEigen<images.internal.app.registration.model.FeatureProperty



    properties




    end

    properties(Dependent)
minQuality
filterSize
    end

    methods
        function self=MinEigen()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create MinEigen object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)

            fixedPoints=images.internal.app.registration.model.harrismineigen(...
            'mineigen',fixed,'MinQuality',self.minQuality,...
            'FilterSize',self.filterSize);
            movingPoints=images.internal.app.registration.model.harrismineigen(...
            'mineigen',moving,'MinQuality',self.minQuality,...
            'FilterSize',self.filterSize);
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
    end

    methods

        function val=get.filterSize(self)
            FilterSize=2+round(self.featureNumber*10);
            val=FilterSize+rem(FilterSize,2)+1;
        end

        function val=get.minQuality(self)
            val=self.featureNumber;
        end

    end

end