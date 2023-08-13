classdef FixedWingUAV<sim3d.uav.UAV


    methods
        function self=FixedWingUAV(actorName,FixedWingType,varargin)


            r=sim3d.uav.FixedWingUAV.parseInputs(varargin{:});
            self@sim3d.uav.UAV(actorName,r.ActorID,r.Translation,...
            r.Rotation,r.Scale);

            self.Mesh=self.getMesh(FixedWingType);
            self.Animation=self.getAnimation(FixedWingType);
            self.Color=self.getColor(r.Color);
            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;


            self.Config.MeshPath=self.Mesh;
            self.Config.AnimationPath=self.Animation;
            self.Config.ColorPath=self.Color;
            self.Config.AdditionalOptions='';
        end

        function ret=getColor(~,color)


            switch color
            case 'black'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_BlackInstance.FixedWingUAV_BlackInstance';
            case 'blue'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Blue.FixedWingUAV_Blue';
            case 'green'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Green.FixedWingUAV_Green';
            case 'orange'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Orange.FixedWingUAV_Orange';
            case 'red'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Red.FixedWingUAV_Red';
            case 'silver'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Silver.FixedWingUAV_Silver';
            case 'white'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_WhiteInstance.FixedWingUAV_WhiteInstance';
            case 'yellow'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Material/FixedWingUAV_Yellow.FixedWingUAV_Yellow';
            otherwise
                error('sim3d:invalidVehicleColor','Invalid Vehicle Color. Please check help and select a valid Vehicle Color.');
            end
        end

        function ret=getMesh(~,fixedWingType)


            switch fixedWingType
            case 'FixedWing'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Mesh/SK_FixedWingUAV.SK_FixedWingUAV';
            otherwise
                ret='';
            end
        end

        function ret=getAnimation(~,fixedWingType)


            switch fixedWingType
            case 'FixedWing'
                ret='/MathWorksUAVContent/UAVs/Fixed_Wing_UAV/Animation/FixedWingAnimBP.FixedWingAnimBP_C';
            otherwise
                ret='';
            end
        end

    end
    methods(Access=public,Hidden=true)
        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.FixedWingUAV;
        end
    end


    methods(Access=private,Static)
        function r=parseInputs(varargin)



            defaultParams=struct(...
            'Color','white',...
            'Mesh','MeshText',...
            'Animation','AnimationText',...
            'Translation',single(zeros(1,3)),...
            'Rotation',single(zeros(1,3)),...
            'Scale',single(ones(1,3)),...
            'ActorID',10,...
            'DebugRayTrace',false);


            parser=inputParser;
            parser.addParameter('Color',defaultParams.Color);
            parser.addParameter('Mesh',defaultParams.Mesh);
            parser.addParameter('Animation',defaultParams.Animation);
            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);


            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end
