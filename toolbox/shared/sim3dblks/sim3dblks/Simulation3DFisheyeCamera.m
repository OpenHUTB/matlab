classdef Simulation3DFisheyeCamera<Simulation3DSensor&...
Simulation3DHandleMap


    properties(Nontunable)

        OpticalCenter(1,2)uint32=[320,320];


        ImageSize(1,2)uint32=[640,640];

        MappingCoefficients(1,4)single=[320,-0.001,0,0];

        StretchMatrix(2,2)single{sim3d.sensors.FisheyeCamera.stretchMatrixValidation(StretchMatrix)}=[1,0;0,1];

        TransformOutportEnabled(1,1)logical=true;

        TranslationInportEnabled(1,1)logical=false;

        RotationInportEnabled(1,1)logical=false;
    end

    properties(Access=private)
        ModelName=[];
    end


    methods(Access=protected)
        function validateInputsImpl(~,Translation,Rotation)
            validateattributes(Translation,{'numeric','embedded.fi'},{'size',[1,3]});
            validateattributes(Rotation,{'numeric','embedded.fi'},{'size',[1,3]});
        end

        function setupImpl(self,~,~)
            if coder.target('MATLAB')
                licenseCheckout=builtin('license','checkout','Video_and_Image_Blockset');
                licenseTest=builtin('license','test','Video_and_Image_Blockset');
                if~licenseTest||~licenseCheckout
                    error(message('shared_sim3dblks:sim3dsharederrAutoIcon:invalidCVTLicense'));
                end
                setupImpl@Simulation3DSensor(self);
                fisheyeCameraProperties=sim3d.sensors.FisheyeCamera.getFisheyeCameraProperties();
                fisheyeCameraProperties.ImageSize=self.ImageSize;
                fisheyeCameraProperties.MappingCoefficients=self.MappingCoefficients;
                fisheyeCameraProperties.DistortionCenter=self.OpticalCenter;
                fisheyeCameraProperties.StretchMatrix=self.StretchMatrix;
                fisheyeCameraTransform=sim3d.utils.Transform(self.Translation,self.Rotation);
                self.Sensor=sim3d.sensors.FisheyeCamera(self.SensorIdentifier,...
                self.VehicleIdentifier,fisheyeCameraProperties,fisheyeCameraTransform);
                self.Sensor.setup();
                self.Sensor.reset();
                self.MountTransform=sim3d.utils.Transform(self.Sensor.getTranslation(),self.Sensor.getRotation(),self.Sensor.getScale());
                self.ModelName=['Simulation3DFisheyeCamera/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
            end
        end

        function[Image,varargout]=stepImpl(self,Translation,Rotation)
            varargout={};
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    if self.TranslationInportEnabled||self.RotationInportEnabled


                        relativeTransform=sim3d.utils.Transform();
                        relativeTransform.copy(self.MountTransform);
                        offsetTransform=sim3d.utils.TransformISO8855(Translation,Rotation);

                        relativeTransform.add(offsetTransform);

                        [translation,rotation,~]=relativeTransform.get();
                        if self.TranslationInportEnabled
                            self.Sensor.setTranslation(translation);
                        end
                        if self.RotationInportEnabled
                            self.Sensor.setRotation(rotation);
                        end
                        self.Sensor.writeTransform();
                    end
                    [Image]=self.Sensor.read();
                    if self.TransformOutportEnabled
                        groundTruth=self.Sensor.readGroundTruth();
                        varargout{end+1}=groundTruth.Translation;
                        varargout{end+1}=groundTruth.Rotation;
                    end
                else
                    Image=zeros(self.ImageSize(1),self.ImageSize(2),3,'uint8');
                end
            else
                Image=zeros(self.ImageSize(1),self.ImageSize(2),3,'uint8');
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            if self.loadflag
                self.ModelName=s.ModelName;
                self.Sensor=self.Sim3dSetGetHandle([self.ModelName,'/Sensor']);
                loadObjectImpl@matlab.System(self,s,wasInUse);
            else
                loadObjectImpl@Simulation3DSensor(self,s,wasInUse);
            end
        end

        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);

            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end

        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DSensor(self);
            s.ModelName=self.ModelName;
        end

        function num=getNumOutputsImpl(self)
            num=1;
            if self.TransformOutportEnabled
                num=num+2;
            end
        end

        function[sz1,varargout]=getOutputSizeImpl(self)
            sz1=[double(self.ImageSize(1)),double(self.ImageSize(2)),3];
            varargout={};
            if self.TransformOutportEnabled
                varargout{end+1}=[1,3];
                varargout{end+1}=[1,3];
            end
        end

        function[fz1,varargout]=isOutputFixedSizeImpl(self)
            fz1=true;
            varargout={};
            if self.TransformOutportEnabled
                varargout{end+1}=true;
                varargout{end+1}=true;
            end
        end

        function[dt1,varargout]=getOutputDataTypeImpl(self)
            dt1='uint8';
            varargout={};
            if self.TransformOutportEnabled
                varargout{end+1}='single';
                varargout{end+1}='single';
            end
        end

        function[cp1,varargout]=isOutputComplexImpl(self)
            cp1=false;
            varargout={};
            if self.TransformOutportEnabled
                varargout{end+1}=false;
                varargout{end+1}=false;
            end
        end
        function icon=getIconImpl(~)

            icon=matlab.system.display.Icon('sim3d_fisheye_cam.png');
        end
    end
end

