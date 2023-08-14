classdef Simulation3DCamera<Simulation3DSensor&...
Simulation3DHandleMap




    properties(Nontunable)



        FocalLength(1,2)single{mustBePositive(FocalLength)}=[1108,1108]




        OpticalCenter(1,2)single{mustBePositive(OpticalCenter)}=[640,360]




        ImageSize(1,2)uint32{mustBePositive(ImageSize)}=[720,1280]




        RadialDistortion(1,:)single{Simulation3DCamera.validateRadialDistortion(RadialDistortion)}=[0,0]




        TangentialDistortion(1,2)single=[0,0]




        SensorSkew(1,1)single=0




        DepthOutportEnabled(1,1)logical=false




        SemanticOutportEnabled(1,1)logical=false




        TransformOutportEnabled(1,1)logical=false




        TranslationInportEnabled(1,1)logical=false




        RotationInportEnabled(1,1)logical=false
    end

    properties(Access=protected)
        DepthSensor=[];
        SemanticSensor=[];
    end

    properties(Hidden=true,Constant=true,Access=private)
        ConstantNumberOfOutports=true;
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
            setupImpl@Simulation3DSensor(self);
            visionSensorProperties=sim3d.sensors.VisionSensor.getVisionSensorProperties();
            visionSensorProperties.FocalLength=self.FocalLength;
            visionSensorProperties.OpticalCenter=self.OpticalCenter;
            visionSensorProperties.ImageSize=self.ImageSize;
            visionSensorProperties.RadialDistortion=self.RadialDistortion;
            visionSensorProperties.TangentialDistortion=self.TangentialDistortion;
            visionSensorProperties.SensorSkew=self.SensorSkew;
            visionSensorTransform=sim3d.utils.Transform(self.Translation,self.Rotation);
            if coder.target('MATLAB')
                self.Sensor=sim3d.sensors.CameraVisionSensor(self.SensorIdentifier,self.VehicleIdentifier,...
                visionSensorProperties,visionSensorTransform);
                self.Sensor.setup();
                self.Sensor.reset();

                self.MountTransform=sim3d.utils.Transform(self.Sensor.getTranslation(),self.Sensor.getRotation(),self.Sensor.getScale());
                self.ModelName=['Simulation3DCamera/',num2str(self.SensorIdentifier),'/',self.VehicleIdentifier];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],self.Sensor);
                end
                if self.DepthOutportEnabled
                    self.DepthSensor=sim3d.sensors.DepthVisionSensor(self.SensorIdentifier,self.VehicleIdentifier,...
                    visionSensorProperties,visionSensorTransform);
                    self.DepthSensor.setup();
                    self.DepthSensor.reset();
                    if self.loadflag
                        self.Sim3dSetGetHandle([self.ModelName,'/DepthSensor'],self.DepthSensor);
                    end
                end
                if self.SemanticOutportEnabled
                    self.SemanticSensor=sim3d.sensors.SemanticSegmentationVisionSensor(self.SensorIdentifier,self.VehicleIdentifier,...
                    visionSensorProperties,visionSensorTransform);
                    self.SemanticSensor.setup();
                    self.SemanticSensor.reset();
                    if self.loadflag
                        self.Sim3dSetGetHandle([self.ModelName,'/SemanticSensor'],self.SemanticSensor);
                    end
                end
            end
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Sensor)
                    self.Sensor.reset();
                end
                if self.DepthOutportEnabled
                    if~isempty(self.DepthSensor)
                        self.DepthSensor.reset();
                    end
                end
                if self.SemanticOutportEnabled
                    if~isempty(self.SemanticSensor)
                        self.SemanticSensor.reset();
                    end
                end
            end
        end

        function[Image,varargout]=stepImpl(self,Translation,Rotation)
            varargout={};
            if coder.target('MATLAB')
                if self.TranslationInportEnabled||self.RotationInportEnabled


                    relativeTransform=sim3d.utils.Transform();
                    relativeTransform.copy(self.MountTransform);
                    offsetTransform=sim3d.utils.TransformISO8855(Translation,Rotation);

                    relativeTransform.add(offsetTransform);

                    [translation,rotation,~]=relativeTransform.get();
                end
                if~isempty(self.Sensor)
                    if self.TranslationInportEnabled
                        self.Sensor.setTranslation(translation);
                    end
                    if self.RotationInportEnabled
                        self.Sensor.setRotation(rotation);
                    end
                    self.Sensor.writeTransform();
                    [Image]=self.Sensor.read();
                else
                    Image=zeros(self.ImageSize(1),self.ImageSize(2),3,'uint8');
                end
                if self.DepthOutportEnabled
                    if~isempty(self.DepthSensor)
                        if self.TranslationInportEnabled
                            self.DepthSensor.setTranslation(translation);
                        end
                        if self.RotationInportEnabled
                            self.DepthSensor.setRotation(rotation);
                        end
                        self.DepthSensor.writeTransform();
                        varargout{end+1}=self.DepthSensor.read();
                    else
                        varargout{end+1}=zeros(self.ImageSize(1),self.ImageSize(2),'double');
                    end
                else
                    varargout{end+1}=0;
                end
                if self.SemanticOutportEnabled
                    if~isempty(self.SemanticSensor)
                        if self.TranslationInportEnabled
                            self.SemanticSensor.setTranslation(translation);
                        end
                        if self.RotationInportEnabled
                            self.SemanticSensor.setRotation(rotation);
                        end
                        self.SemanticSensor.writeTransform();
                        varargout{end+1}=self.SemanticSensor.read();
                    else
                        varargout{end+1}=zeros(self.ImageSize(1),self.ImageSize(2),'uint8');
                    end
                else
                    varargout{end+1}=uint8(0);
                end

                if self.TransformOutportEnabled
                    if~isempty(self.Sensor)
                        groundTruth=self.Sensor.readGroundTruth();
                        varargout{end+1}=groundTruth.Translation;
                        varargout{end+1}=groundTruth.Rotation;
                    else
                        varargout{end+1}=zeros(self.Sensor.getNumberOfParts(),3,'single');
                        varargout{end+1}=zeros(self.Sensor.getNumberOfParts(),3,'single');
                    end
                else
                    varargout{end+1}=single(0);
                    varargout{end+1}=single(0);
                end
            else
                Image=zeros(self.ImageSize(1),self.ImageSize(2),3,'uint8');
                if self.DepthOutportEnabled
                    varargout{end+1}=zeros(self.ImageSize(1),self.ImageSize(2),'double');
                else
                    varargout{end+1}=0;
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}=zeros(self.ImageSize(1),self.ImageSize(2),'uint8');
                else
                    varargout{end+1}=uint8(0);
                end
                if self.TransformOutportEnabled
                    varargout{end+1}=zeros(self.Sensor.getNumberOfParts(),3,'single');
                    varargout{end+1}=zeros(self.Sensor.getNumberOfParts(),3,'single');
                else
                    varargout{end+1}=single(0);
                    varargout{end+1}=single(0);
                end
            end
        end

        function releaseImpl(self)
            releaseImpl@Simulation3DSensor(self);
            if self.loadflag
                self.Sim3dSetGetHandle([self.ModelName,'/Sensor'],[]);
            end
            if self.DepthOutportEnabled
                if~isempty(self.DepthSensor)
                    self.DepthSensor.delete();
                    self.DepthSensor=[];
                    if self.loadflag
                        self.Sim3dSetGetHandle([self.ModelName,'/DepthSensor'],[]);
                    end
                end
            end
            if self.SemanticOutportEnabled
                if~isempty(self.SemanticSensor)
                    self.SemanticSensor.delete();
                    self.SemanticSensor=[];
                    if self.loadflag
                        self.Sim3dSetGetHandle([self.ModelName,'/SemanticSensor'],[]);
                    end
                end
            end
        end

        function num=getNumOutputsImpl(self)
            if Simulation3DCamera.ConstantNumberOfOutports
                num=5;
            else
                num=1;
                if self.DepthOutportEnabled
                    num=num+1;
                end
                if self.SemanticOutportEnabled
                    num=num+1;
                end
                if self.TransformOutportEnabled
                    num=num+2;
                end
            end
        end
        function loadObjectImpl(self,s,wasInUse)
            if self.loadflag
                self.ModelName=s.ModelName;
                if self.DepthOutportEnabled
                    self.DepthSensor=self.Sim3dSetGetHandle([self.ModelName,'/DepthSensor']);
                end
                if self.SemanticOutportEnabled
                    self.SemanticSensor=self.Sim3dSetGetHandle([self.ModelName,'/SemanticSensor']);
                end
                self.Sensor=self.Sim3dSetGetHandle([self.ModelName,'/Sensor']);
                loadObjectImpl@matlab.System(self,s,wasInUse);
            else
                if self.DepthOutportEnabled
                    self.DepthSensor=s.DepthSensor;
                end
                if self.SemanticOutportEnabled
                    self.SemanticSensor=s.SemanticSensor;
                end
                loadObjectImpl@Simulation3DSensor(self,s,wasInUse);
            end
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@Simulation3DSensor(self);
            s.ModelName=self.ModelName;
            if self.DepthOutportEnabled
                s.DepthSensor=self.DepthSensor;
            end
            if self.SemanticOutportEnabled
                s.SemanticSensor=self.SemanticSensor;
            end
        end

        function[sz1,varargout]=getOutputSizeImpl(self)
            sz1=[double(self.ImageSize(1)),double(self.ImageSize(2)),3];
            if Simulation3DCamera.ConstantNumberOfOutports
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}=[double(self.ImageSize(1)),double(self.ImageSize(2))];
                else
                    varargout{end+1}=[1,1];
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}=[double(self.ImageSize(1)),double(self.ImageSize(2))];
                else
                    varargout{end+1}=[1,1];
                end
                if self.TransformOutportEnabled
                    varargout{end+1}=[1,3];
                    varargout{end+1}=[1,3];
                else
                    varargout{end+1}=[1,1];
                    varargout{end+1}=[1,1];
                end
            else
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}=[double(self.ImageSize(1)),double(self.ImageSize(2))];
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}=[double(self.ImageSize(1)),double(self.ImageSize(2))];
                end
                if self.TransformOutportEnabled
                    varargout{end+1}=[1,3];
                    varargout{end+1}=[1,3];
                end
            end
        end

        function[fz1,varargout]=isOutputFixedSizeImpl(self)
            fz1=true;
            if Simulation3DCamera.ConstantNumberOfOutports
                varargout={true,true,true,true};
            else
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}=true;
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}=true;
                end
                if self.TransformOutportEnabled
                    varargout{end+1}=true;
                    varargout{end+1}=true;
                end
            end
        end

        function[dt1,varargout]=getOutputDataTypeImpl(self)
            dt1='uint8';
            if Simulation3DCamera.ConstantNumberOfOutports
                varargout={'double','uint8','single','single'};
            else
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}='double';
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}='uint8';
                end
                if self.TransformOutportEnabled
                    varargout{end+1}='single';
                    varargout{end+1}='single';
                end
            end
        end

        function[cp1,varargout]=isOutputComplexImpl(self)
            cp1=false;
            if Simulation3DCamera.ConstantNumberOfOutports
                varargout={false,false,false,false};
            else
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}=false;
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}=false;
                end
                if self.TransformOutportEnabled
                    varargout{end+1}=false;
                    varargout{end+1}=false;
                end
            end
        end

        function[pn1,varargout]=getOutputNamesImpl(self)

            pn1='Image';
            if Simulation3DCamera.ConstantNumberOfOutports
                varargout={'Distance','Class IDs','Translation','Rotation'};
            else
                varargout={};
                if self.DepthOutportEnabled
                    varargout{end+1}='Distance';
                end
                if self.SemanticOutportEnabled
                    varargout{end+1}='Class IDs';
                end
                if self.TransformOutportEnabled
                    varargout{end+1}='Translation';
                    varargout{end+1}='Rotation';
                end
            end
        end
        function icon=getIconImpl(~)

            icon=matlab.system.display.Icon('sim3d_cam_model.dvg');
        end
    end

    methods(Access=public,Hidden=true)
        function tag=getTag(self)
            tag=sprintf('Camera%d',self.SensorIdentifier);
        end
    end

    methods(Static=true,Access=public,Hidden=true)
        function validateRadialDistortion(radialDistortion)
            radialDistortionSize=size(radialDistortion);
            if~(all(radialDistortionSize==[1,2])||...
                all(radialDistortionSize==[1,3])||...
                all(radialDistortionSize==[1,6]))
                error(message('shared_sim3dblks:sim3dblkCameraPinHole:blkPrmError_RadialDistortionSize'));
            end
        end
    end
end
