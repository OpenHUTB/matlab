classdef VisionSensor<sim3d.sensors.AbstractCameraSensor

    properties(Access=protected,Constant=true)


        MaxHorizontalFieldOfView(1,1)single=150;



        NumberOfCoefficientsOpenCVModel(1,1)uint32=6
    end

    properties



        FocalLength=[1109,1109];




        OpticalCenter=[640,360];




        ImageSize=[720,1280];




        RadialDistortion=[0,0];




        TangentialDistortion=[0,0];




        SensorSkew=0;
    end

    methods
        function self=VisionSensor(sensorID,vehicleID,sensorProperties,transform)
            horizontalFieldOfView=single(2*rad2deg(atan(0.5*double(sensorProperties.ImageSize(2))/double(sensorProperties.FocalLength(1)))));
            sensorName=sim3d.sensors.Sensor.getSensorName('VisionSensor',sensorID);
            self@sim3d.sensors.AbstractCameraSensor(sensorName,vehicleID,...
            uint32(sensorProperties.ImageSize(2)),uint32(sensorProperties.ImageSize(1)),horizontalFieldOfView,transform)
            self.FocalLength=uint32(sensorProperties.FocalLength);
            self.OpticalCenter=uint32(sensorProperties.OpticalCenter);
            self.ImageSize=uint32(sensorProperties.ImageSize);
            self.RadialDistortion=single(sensorProperties.RadialDistortion);
            self.TangentialDistortion=single(sensorProperties.TangentialDistortion);
            self.SensorSkew=single(sensorProperties.SensorSkew);
        end
    end
    methods(Access=protected,Hidden=true)
        function focalLength=getFocalLength(self)
            focalLength=uint32(self.FocalLength);
        end

        function opticalCenter=getOpticalCenter(self)
            opticalCenter=uint32(self.OpticalCenter);
        end

        function skew=getSkew(self)
            skew=single(self.SensorSkew/single(self.FocalLength(2)));
        end

        function[radialDistortion,radialDistortionLength]=getRadialDistortion(self)
            radialDistortion=single(zeros(1,9));
            radialDistortionLength=length(self.RadialDistortion);
            radialDistortion(1:radialDistortionLength)=self.RadialDistortion(1:radialDistortionLength);
        end

        function[tangentialDistortion,tangentialDistortionLength]=getTangentialDistortion(self)
            tangentialDistortion=single(zeros(1,2));
            tangentialDistortionLength=length(self.TangentialDistortion);
            tangentialDistortion(1:tangentialDistortionLength)=self.TangentialDistortion(1:tangentialDistortionLength);
        end

        function parameters=createCameraConfigurationParameters(self)
            parameters=createCameraConfigurationParameters@sim3d.sensors.AbstractCameraSensor(self);
            parameters=self.recalculateRadialDistortionCoefficients(parameters);
            if parameters.horizontalFieldOfView>self.MaxHorizontalFieldOfView||...
                parameters.verticalFieldOfView>self.MaxHorizontalFieldOfView
                error(message('shared_sim3dblks:sim3dblkCameraPinHole:blkPrmError_fieldOfView'));
            end
        end
        function cameraParameters=recalculateRadialDistortionCoefficients(self,cameraParameters)
            m=double(cameraParameters.horizontalResolution);
            n=double(cameraParameters.verticalResolution);
            cx=double(cameraParameters.opticalCenter(1));
            cy=double(cameraParameters.opticalCenter(2));
            fx=double(cameraParameters.focalLength(1));
            fy=double(cameraParameters.focalLength(2));
            radialDistortionLength=cameraParameters.radialDistortionLength;
            radialDistortion=double(cameraParameters.radialDistortion(1:radialDistortionLength));
            [map]=self.distortionFunctionMap(m,n,cx,cy,fx,fy,radialDistortion);
            [y,x,val]=find(map);
            r2=((x(:)-cx)/fx).*((x(:)-cx)/fx)+((y(:)-cy)/fy).*((y(:)-cy)/fy);
            radialDistortion=polyfit(r2,val,2);
            radialDistortion=fliplr(radialDistortion);
            radialDistortion=radialDistortion(2:end);
            radialDistortionLength=length(radialDistortion);
            cameraParameters.radialDistortion(1:radialDistortionLength)=radialDistortion(1:radialDistortionLength);
            cameraParameters.radialDistortionLength=uint32(radialDistortionLength);
        end

        function[map]=distortionFunctionMap(self,m,n,cx,cy,fx,fy,radialDistortion)

            map=zeros(n,m);
            for y=1:n
                for x=1:m
                    df=self.distortionFunction(x,y,cx,cy,fx,fy,radialDistortion);
                    [xd,yd]=self.undistortionPoint(x,y,cx,cy,fx,fy,df);
                    xd=round(xd);
                    yd=round(yd);
                    if(xd>=1)&&(xd<=m)&&(yd>=1)&&(yd<=n)
                        map(yd,xd)=df;
                    end
                end
            end
        end

        function[distortion]=distortionFunction(~,x,y,cx,cy,fx,fy,radialDistortion)

            u=(x-cx)/fx;
            v=(y-cy)/fy;
            r2=u^2+v^2;


            N=length(radialDistortion);
            if N==sim3d.sensors.VisionSensor.NumberOfCoefficientsOpenCVModel





                numerator=1;
                denominator=1;
                N_2=N/2;
                rn=1;
                for coeffIndex=1:N_2
                    rn=rn*r2;
                    numerator=numerator+radialDistortion(coeffIndex)*rn;
                    denominator=denominator+radialDistortion(coeffIndex+N_2)*rn;
                end
                distortion=numerator/denominator;
            else
                distortion=1;
                rn=1;
                for coeffIndex=1:N
                    rn=rn*r2;
                    distortion=distortion+radialDistortion(coeffIndex)*rn;
                end
            end
        end

        function[xd,yd]=undistortionPoint(~,x,y,cx,cy,fx,fy,distortion)

            u=(x-cx)/fx;
            v=(y-cy)/fy;

            ud=u*distortion;
            vd=v*distortion;

            xd=ud*fx+cx;
            yd=vd*fy+cy;
        end
    end
    methods(Static)
        function visionSensorProperties=getVisionSensorProperties()
            visionSensorProperties=struct(...
            'FocalLength',[1108,1108],...
            'OpticalCenter',[640,360],...
            'ImageSize',[720,1280],...
            'RadialDistortion',[0,0],...
            'TangentialDistortion',[0,0],...
            'SensorSkew',0);
        end
    end
end

