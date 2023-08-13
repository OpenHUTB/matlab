classdef FisheyeCamera<sim3d.sensors.AbstractCameraSensor


    properties
        MappingCoefficients(1,4)single=[320,-0.001,0,0];
        DistortionCenter(1,2)uint32=[640,320];

        StretchMatrix(2,2)single{sim3d.sensors.FisheyeCamera.stretchMatrixValidation(StretchMatrix)}=[1,0;0,1];
    end

    properties(Constant,Hidden)
        STRETCH_MATRIX_DET_MIN=10
    end

    methods
        function self=FisheyeCamera(sensorID,vehicleID,sensorProperties,transform)
            horizontalFieldOfView=min(360,single(45*double(sensorProperties.ImageSize(2))/double(sensorProperties.MappingCoefficients(1))));
            sensorName=sim3d.sensors.Sensor.getSensorName('Camera',sensorID);
            self@sim3d.sensors.AbstractCameraSensor(sensorName,vehicleID,...
            sensorProperties.ImageSize(2),sensorProperties.ImageSize(1),horizontalFieldOfView,transform)
            self.MappingCoefficients=single(sensorProperties.MappingCoefficients);
            self.DistortionCenter=uint32(sensorProperties.DistortionCenter);
            sim3d.sensors.FisheyeCamera.stretchMatrixValidation(sensorProperties.StretchMatrix);
            self.StretchMatrix=single(sensorProperties.StretchMatrix);
        end
        function image=read(self)


            image=read@sim3d.sensors.AbstractCameraSensor(self);
            if(self.Reader.StepCounter==1)&&(sim3d.engine.Engine.getWarmUpSteps()==0)

                image(:)=cast(0,class(image));
            end
        end
    end
    methods(Access=protected,Hidden=true)
        function focalLength=getFocalLength(self)
            focalLength=uint32([self.MappingCoefficients(1),self.MappingCoefficients(1)]);
        end

        function opticalCenter=getOpticalCenter(self)
            opticalCenter=uint32(self.DistortionCenter);
        end

        function skew=getSkew(~)
            skew=single(0);
        end

        function[radialDistortion,radialDistortionLength]=getRadialDistortion(self)
            [radialDistortion,~]=getRadialDistortion@sim3d.sensors.AbstractCameraSensor(self);
            mappingCoefficients=[self.MappingCoefficients(1),...
            zeros(1,'like',self.MappingCoefficients),...
            self.MappingCoefficients(2:end),reshape(inv(self.StretchMatrix)',1,4)];
            radialDistortionLength=min(length(radialDistortion),length(mappingCoefficients));
            radialDistortion(1:radialDistortionLength)=mappingCoefficients(1:radialDistortionLength);
        end

        function[tangentialDistortion,tangentialDistortionLength]=getTangentialDistortion(self)
            [tangentialDistortion,~]=getTangentialDistortion@sim3d.sensors.AbstractCameraSensor(self);
            tangentialDistortionLength=min(length(tangentialDistortion),length(self.StretchMatrix));
            tangentialDistortion(1:tangentialDistortionLength)=self.StretchMatrix(1:tangentialDistortionLength);
        end
    end

    methods(Static)
        function tagName=getTagName()
            tagName='Camera';
        end
    end


    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.FisheyeCamera;
        end
    end
    methods(Static,Access=public,Hidden=true)
        function stretchMatrixValidation(stretchMatrix)
            if stretchMatrix(2,2)~=1
                error(message('shared_sim3dblks:sim3dblkFisheyeCamera:invalidStretchMatrixElement22'));
            end

            stretchMatrixDetMin=sim3d.sensors.FisheyeCamera.STRETCH_MATRIX_DET_MIN*eps(class(stretchMatrix));
            if abs(det(stretchMatrix))<=stretchMatrixDetMin
                error(message('shared_sim3dblks:sim3dblkFisheyeCamera:zeroStretchMatrix'));
            end
        end
    end
    methods(Static)
        function sensorProperties=getFisheyeCameraProperties()
            sensorProperties=struct(...
            'ImageSize',[720,1280],...
            'MappingCoefficients',single([320,-0.001,0,0]),...
            'DistortionCenter',uint32([640,320]),...
            'StretchMatrix',single([1,0;0,1]));
        end
    end
end
