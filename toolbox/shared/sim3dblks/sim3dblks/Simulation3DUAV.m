classdef Simulation3DUAV<Simulation3DActor


    properties
        Translation=zeros(1,3)

        Rotation=zeros(1,3)
    end

    properties(Nontunable)
        Mesh=messageString('TypeQuadrotor')


        MeshPath='/MathWorksUAVContent/UAVs/HexaRotorUAV/HexaRotor.HexaRotor'
        UAVColor=messageString('ColorBlack')

        ActorTag='SimulinkVehicle1'
    end

    properties(Hidden,Constant)

        MeshSet=matlab.system.StringSet({messageString('TypeQuadrotor'),...
        messageString('TypeFixedWing'),messageString('TypeCustom')})


        UAVColorSet=matlab.system.StringSet({...
        messageString('ColorRed'),messageString('ColorOrange'),messageString('ColorYellow'),...
        messageString('ColorGreen'),messageString('ColorBlue'),messageString('ColorBlack'),...
        messageString('ColorWhite'),messageString('ColorSilver')})
    end

    properties(Access=private)

VehObj


VehicleType


ActorColor
    end

    methods(Access=protected)
        function setupImpl(self)

            setupImpl@Simulation3DActor(self);
            self.ActorColor=lower(self.UAVColor);
            self.VehicleType=sim3d.utils.internal.StringMap.fwd(self.Mesh);
            if strcmp(self.VehicleType,messageString('TypeCustom'))
                actorClass='QuadrotorUAV';
            else
                actorClass=[self.VehicleType,'UAV'];
            end



            self.VehObj=sim3d.uav.(actorClass)(self.ActorTag,self.VehicleType,...
            'Color',self.ActorColor,...
            'Translation',self.Translation,...
            'Rotation',self.Rotation,...
            'Mesh',self.MeshPath);
            self.VehObj.setup();
            self.VehObj.reset();
        end

        function stepImpl(self,translation,rotation)


            translation=self.convertTranslationToUnreal(translation(:)');
            rotation=self.convertRotationToUnreal(rotation(:)');

            if coder.target('MATLAB')
                if~isempty(self.VehObj)
                    self.VehObj.writeTransform(single(translation),single(rotation),single(ones(size(translation))));
                end
            end
        end

        function releaseImpl(self)

            simulationStatus=get_param(bdroot,'SimulationStatus');
            if strcmp(simulationStatus,'terminating')
                if coder.target('MATLAB')
                    if~isempty(self.VehObj)
                        self.VehObj.delete();
                        self.VehObj=[];
                    end
                end
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)



            if strcmp(prop,"MeshPath")
                flag=strcmp(obj.Mesh,messageString('TypeCustom'));
            else
                flag=true;
            end
        end

        function loadObjectImpl(self,s,wasInUse)


            self.VehObj=s.VehObj;
            self.VehicleType=s.VehicleType;
            self.ActorColor=s.ActorColor;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Mesh=s.Mesh;
            self.UAVColor=s.UAVColor;
            self.ActorTag=s.ActorTag;

            loadObjectImpl@Simulation3DActor(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)


            s=saveObjectImpl@Simulation3DActor(self);

            s.VehObj=self.VehObj;
            s.VehicleType=self.VehicleType;
            s.ActorColor=self.ActorColor;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Mesh=self.Mesh;
            s.UAVColor=self.UAVColor;
            s.ActorTag=self.ActorTag;
        end

        function icon=getIconImpl(~)

            icon={'UAV'};
        end
    end

    methods(Static,Access=protected)
        function translation=convertTranslationToUnreal(translation)




            translation(2)=-translation(2);
        end

        function rotation=convertRotationToUnreal(rotation)











            rotation=[-rotation(2),rotation(3),-rotation(1)];
        end
    end

    methods
        function set.Translation(self,translation)





            translation=translation(:)';
            self.Translation=self.convertTranslationToUnreal(translation);
        end

        function set.Rotation(self,rotation)





            rotation=rotation(:)';
            self.Rotation=self.convertRotationToUnreal(rotation);
        end

        function[Transformation,Rotation,Scale]=getPosition(self)


            [Transformation,Rotation,Scale]=self.VehObj.read();
        end
    end
end

function msgStr=messageString(tag)
    msgStr=message("uav:robotsluav:uavvehicle:"+string(tag)).getString;
end
