classdef KAZE<images.internal.app.registration.model.FeatureProperty





    properties




        diffusion='region'
    end

    properties(Dependent)
threshold
numOctaves
numScaleLevels
    end

    methods
        function self=KAZE()
            if~images.internal.app.registration.model.validateMethod
                error('cannot create KAZE object');
            end
        end

        function[fixedPoints,movingPoints]=detectFeatures(self,fixed,moving)



            fixedu8=im2uint8(fixed);
            movingu8=im2uint8(moving);
            assert(size(fixedu8,3)==1);
            assert(size(movingu8,3)==1);

            numScaleLevels_I=uint8(self.numScaleLevels);
            numOctaves_I=uint8(self.numOctaves);
            threshold_I=single(self.threshold);

            switch self.diffusion
            case 'region'
                diffusivity=uint8(1);
            case 'sharpedge'
                diffusivity=uint8(0);
            case 'edge'
                diffusivity=uint8(2);
            otherwise
                diffusivity=uint8(1);
            end



            extended=true;
            upright=true;

            fixedPoints=imagesocvDetectKAZE(fixedu8,extended,upright,...
            threshold_I,numOctaves_I,numScaleLevels_I,diffusivity);

            movingPoints=imagesocvDetectKAZE(movingu8,extended,upright,...
            threshold_I,numOctaves_I,numScaleLevels_I,diffusivity);

            fixedPoints.Scale=fixedPoints.Scale/2;
            movingPoints.Scale=movingPoints.Scale/2;

        end

        function[features,validPoints]=extractFeatures(self,image,points)




            kazeSize=64;


            extended=(kazeSize==128);
            upright=self.upright;

            Threshold=single(0);
            NumOctaves=uint8(self.numOctaves);
            NScaleLevels=uint8(self.numScaleLevels);

            switch self.diffusion
            case 'region'
                diffusionCode=uint8(1);
            case 'sharpedge'
                diffusionCode=uint8(0);
            case 'edge'
                diffusionCode=uint8(2);
            otherwise
                diffusionCode=uint8(1);
            end

            points.Scale=points.Scale*2;

            Iu8=im2uint8(image);

            [features,validPoints]=imagesocvExtractKAZE(Iu8,points,...
            extended,upright,Threshold,...
            NumOctaves,NScaleLevels,diffusionCode);


            validPoints.Orientation=single(pi/2)-validPoints.Orientation;
            validPoints.Scale=validPoints.Scale/2;
        end

    end

    methods

        function val=get.threshold(self)
            val=self.featureNumber/100;
        end

        function val=get.numOctaves(self)
            val=round(1+(1-self.featureNumber)*3);
        end

        function val=get.numScaleLevels(self)
            val=round(3+(1-self.featureNumber)*3);
        end

    end

end
