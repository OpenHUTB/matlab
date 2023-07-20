classdef IterativeIntensityOperator<images.internal.app.registration.model.RigidWarpOperator





    properties


iterativeIntensityProperty
    end

    methods

        function self=IterativeIntensityOperator(type)
            if strcmp(type,'monomodal')
                self.iterativeIntensityProperty=images.internal.app.registration.model.Monomodal;
            elseif strcmp(type,'multimodal')
                self.iterativeIntensityProperty=images.internal.app.registration.model.Multimodal;
            else
                assert(false,'Error: incorrect type of IterativeIntensityOperator specified. Monomodal or Multimodal are the only options.');
            end
        end

        function[registeredImage,movingRGB]=run(self,fixed,moving,movingRGB,fixedRefObj,movingRefObj)


            if strcmpi(self.iterativeIntensityProperty.alignCenters,'center of mass')
                [translationX,translationY]=alignCenterOfMass(double(fixed),fixedRefObj,double(moving),movingRefObj);
            else
                [translationX,translationY]=alignGeometricCenter(fixedRefObj,movingRefObj);
            end


            movingInit=moving;

            if self.iterativeIntensityProperty.applyBlur

                fixed=imgaussfilt(fixed,2*self.iterativeIntensityProperty.blurValue);
                movingInit=imgaussfilt(movingInit,2*self.iterativeIntensityProperty.blurValue);
            end

            if self.iterativeIntensityProperty.normalize
                fixed=mat2gray(fixed);
                movingInit=mat2gray(movingInit);
            end



            initTform=affine2d();
            initTform.T(3,1:2)=[translationX,translationY];


            self.tform=imregtform(movingInit,movingRefObj,fixed,fixedRefObj,self.tformType,...
            self.iterativeIntensityProperty.optimizer,...
            self.iterativeIntensityProperty.metric,...
            'PyramidLevels',self.iterativeIntensityProperty.pyramidLevels,...
            'InitialTransformation',initTform);




            registeredImage=imwarp(moving,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);

            if~isempty(movingRGB)
                movingRGB=imwarp(movingRGB,movingRefObj,self.tform,'OutputView',fixedRefObj,'SmoothEdges',true);
            end

        end
    end

end

function[translationX,translationY]=alignGeometricCenter(fixedRefObj,movingRefObj)


    fixedCenterXWorld=mean(fixedRefObj.XWorldLimits);
    fixedCenterYWorld=mean(fixedRefObj.YWorldLimits);

    movingCenterXWorld=mean(movingRefObj.XWorldLimits);
    movingCenterYWorld=mean(movingRefObj.YWorldLimits);

    translationX=fixedCenterXWorld-movingCenterXWorld;
    translationY=fixedCenterYWorld-movingCenterYWorld;

end

function[translationX,translationY]=alignCenterOfMass(fixed,fixedRefObj,moving,movingRefObj)


    [xFixed,yFixed]=meshgrid(1:size(fixed,2),1:size(fixed,1));
    [xMoving,yMoving]=meshgrid(1:size(moving,2),1:size(moving,1));

    sumFixedIntensity=sum(fixed(:));
    sumMovingIntensity=sum(moving(:));

    fixedXCOM=(fixedRefObj.PixelExtentInWorldX.*(sum(xFixed(:).*fixed(:))./sumFixedIntensity))+fixedRefObj.XWorldLimits(1);
    fixedYCOM=(fixedRefObj.PixelExtentInWorldY.*(sum(yFixed(:).*fixed(:))./sumFixedIntensity))+fixedRefObj.YWorldLimits(1);
    movingXCOM=(movingRefObj.PixelExtentInWorldX.*(sum(xMoving(:).*moving(:))./sumMovingIntensity))+movingRefObj.XWorldLimits(1);
    movingYCOM=(movingRefObj.PixelExtentInWorldY.*(sum(yMoving(:).*moving(:))./sumMovingIntensity))+movingRefObj.YWorldLimits(1);

    translationX=fixedXCOM-movingXCOM;
    translationY=fixedYCOM-movingYCOM;

end


