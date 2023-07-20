classdef(Abstract)RigidWarpOperator<handle





    properties
tform
        tformType='similarity';
    end

    methods
        [registeredImage,registeredRGBImage]=run(self,fixedImage,movingImage,movingRGB,fixedRefObj,movingRefObj)

        function settformType(self,input)
            self.tformType=input;
        end

    end

    methods(Static)
        function tform=moveTransformationToWorldCoordinateSystem(tform,Rmoving,Rfixed)

            Sx=Rmoving.PixelExtentInWorldX;
            Sy=Rmoving.PixelExtentInWorldY;
            Tx=Rmoving.XWorldLimits(1)-Rmoving.PixelExtentInWorldX*(Rmoving.XIntrinsicLimits(1));
            Ty=Rmoving.YWorldLimits(1)-Rmoving.PixelExtentInWorldY*(Rmoving.YIntrinsicLimits(1));
            tMovingIntrinsicToWorld=[Sx,0,0;0,Sy,0;Tx,Ty,1];
            tMovingWorldToIntrinsic=inv(tMovingIntrinsicToWorld);

            Sx=Rfixed.PixelExtentInWorldX;
            Sy=Rfixed.PixelExtentInWorldY;
            Tx=Rfixed.XWorldLimits(1)-Rfixed.PixelExtentInWorldX*(Rfixed.XIntrinsicLimits(1));
            Ty=Rfixed.YWorldLimits(1)-Rfixed.PixelExtentInWorldY*(Rfixed.YIntrinsicLimits(1));
            tFixedIntrinsicToWorld=[Sx,0,0;0,Sy,0;Tx,Ty,1];

            tMovingIntrinsicToFixedIntrinsic=tform.T;

            tComposite=tMovingWorldToIntrinsic*tMovingIntrinsicToFixedIntrinsic*tFixedIntrinsicToWorld;%#ok<MINV>

            if isa(tform,'affine2d')||isa(tform,'rigid2d')




                tform.T(1:3,1:2)=tComposite(1:3,1:2);
            else

                tform.T=tComposite;
            end

        end
    end
end
