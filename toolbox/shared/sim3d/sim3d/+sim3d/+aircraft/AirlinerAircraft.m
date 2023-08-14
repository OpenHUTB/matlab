classdef AirlinerAircraft<sim3d.aircraft.Aircraft





    methods
        function self=AirlinerAircraft(actorName,AircraftType,varargin)




            numberOfParts=12;

            r=sim3d.aircraft.AirlinerAircraft.parseInputs(varargin{:});
            sim3d.aircraft.AirlinerAircraft.VerifyInitialTransformSize(...
            r.Translation,r.Rotation,r.Scale,numberOfParts);


            self@sim3d.aircraft.Aircraft(actorName,r.ActorID,r.Translation,...
            r.Rotation,r.Scale,numberOfParts);

            self.Mesh=self.getMesh(AircraftType);
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
                ret=[sim3d.aircraft.Aircraft.ContentRoot,'/Vehicles/Aircraft/MWAirliner/Materials/M_MWAirliner_Body-Tail_',clr,'.M_MWAirliner_Body-Tail_',clr];
            else
                error(message('aeroblks_sim3d:aerolibsim3d:sim3dInvalidColor'));
            end
        end

        function ret=getMesh(~,meshType)


            switch meshType
            case 'Airliner'
                ret=[sim3d.aircraft.Aircraft.ContentRoot,'/Vehicles/Aircraft/MWAirliner/Mesh/SK_MWAirliner.SK_MWAirliner'];
            otherwise
                ret='';
            end
        end

        function ret=getAnimation(~,meshType)


            switch meshType
            case 'Airliner'
                ret=[sim3d.aircraft.Aircraft.ContentRoot,'/Vehicles/Aircraft/MWAirliner/Animation/MWAirlinerAnimBP.MWAirlinerAnimBP_C'];
            otherwise
                ret='';
            end
        end
    end

    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.MWAirliner;
        end
        function numberOfParts=getNumberOfParts(self)
            numberOfParts=self.NumberOfParts;
        end
    end


    methods(Access=private,Static)
        function r=parseInputs(varargin)



            defaultParams=struct(...
            'Color','red',...
            'Mesh','Airliner',...
            'Animation','AnimationText',...
            'Translation',single(zeros(12,3)),...
            'Rotation',single(zeros(12,3)),...
            'Scale',single(ones(12,3)),...
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
