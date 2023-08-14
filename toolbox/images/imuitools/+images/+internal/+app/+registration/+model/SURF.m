classdef SURF<images.internal.app.registration.model.FeatureProperty



    properties




    end

    properties(Dependent)
metricThreshold
numOctaves
numScaleLevels
    end

    methods
        function self=SURF()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create SURF object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)


            fixedu8=im2uint8(fixed);
            movingu8=im2uint8(moving);
            assert(size(fixedu8,3)==1);
            assert(size(movingu8,3)==1);

            params.nOctaveLayers=uint32(self.numScaleLevels)-uint32(2);
            params.nOctaves=uint32(self.numOctaves);
            params.hessianThreshold=uint32(self.metricThreshold);


            params.usingROI=false;
            params.ROI=int32([0,0,1,1]);

            fixedPoints=imagesocvDetectSURF(fixedu8,params);
            movingPoints=imagesocvDetectSURF(movingu8,params);
        end



        function[features,validPoints]=extractFeatures(self,image,points)




            surfSize=64;


            params.extended=(surfSize==128);
            params.upright=self.upright;

            Iu8=im2uint8(image);
            [validPoints,features]=imagesocvExtractSURF(Iu8,points,params);


            validPoints.Orientation(:)=single(2*pi)-validPoints.Orientation;
        end
    end

    methods

        function val=get.metricThreshold(self)
            val=500+self.featureNumber*500;
        end

        function val=get.numOctaves(self)
            val=round(1+(1-self.featureNumber)*3);
        end

        function val=get.numScaleLevels(self)
            val=round(3+(1-self.featureNumber)*3);
        end

    end

end