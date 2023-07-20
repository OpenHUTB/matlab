classdef FixedWingAircraft<sim3d.aircraft.Aircraft





    methods
        function self=FixedWingAircraft(actorName,AircraftType,varargin)







            numberOfParts=57;

            r=sim3d.aircraft.FixedWingAircraft.parseInputs(varargin{:});
            sim3d.aircraft.FixedWingAircraft.VerifyInitialTransformSize(...
            r.Translation,r.Rotation,r.Scale,numberOfParts);



            self@sim3d.aircraft.Aircraft(actorName,r.ActorID,r.Translation,...
            r.Rotation,r.Scale,numberOfParts);

            self.Mesh=self.getMesh(AircraftType,r.Mesh);
            self.Animation=self.getAnimation(AircraftType);
            self.Color=self.getColor(r.Color);
            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;


            self.Config.MeshPath=self.Mesh;
            self.Config.AnimationPath=self.Animation;
            self.Config.ColorPath=self.Color;


            self.LightModule=sim3d.vehicle.VehicleLightingModule(r.LightConfiguration);
            self.Config.AdditionalOptions=self.LightModule.generateInitMessageString();
        end

        function ret=getColor(~,color)


            if ismember(color,sim3d.aircraft.Aircraft.Colors)
                clr=[upper(color(1)),color(2:end)];
                ret=[sim3d.aircraft.Aircraft.ContentRoot,'/Vehicles/Aircraft/Custom/Materials/M_Aircraft_',clr,'.M_Aircraft_',clr];
            else
                error(message('aeroblks_sim3d:aerolibsim3d:sim3dInvalidColor'));
            end
        end

        function ret=getMesh(~,meshType,meshPath)


            switch meshType
            case 'Custom'
                ret=meshPath;
            otherwise
                ret='';
            end
        end

        function ret=getAnimation(~,meshType)


            switch meshType
            case 'Custom'
                ret=[sim3d.aircraft.Aircraft.ContentRoot,'/Vehicles/Aircraft/Custom/Animation/AircraftAnimBP.AircraftAnimBP_C'];
            otherwise
                ret='';
            end
        end
    end

    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.FixedWing;
        end
        function numberOfParts=getNumberOfParts(self)
            numberOfParts=self.NumberOfParts;
        end
    end


    methods(Access=private,Static)
        function r=parseInputs(varargin)



            defaultParams=struct(...
            'Color','red',...
            'Mesh','FixedWing',...
            'Animation','AnimationText',...
            'Translation',single(zeros(57,3)),...
            'Rotation',single(zeros(57,3)),...
            'Scale',single(ones(57,3)),...
            'ActorID',10);


            parser=inputParser;
            parser.addParameter('Color',defaultParams.Color);
            parser.addParameter('Mesh',defaultParams.Mesh);
            parser.addParameter('Animation',defaultParams.Animation);
            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);
            parser.addParameter('LightConfiguration',{});


            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end
