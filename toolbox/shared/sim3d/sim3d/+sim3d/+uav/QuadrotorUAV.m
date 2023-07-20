classdef QuadrotorUAV<sim3d.uav.UAV






    methods
        function self=QuadrotorUAV(actorName,quadRotorType,varargin)


            r=sim3d.uav.QuadrotorUAV.parseInputs(varargin{:});
            self@sim3d.uav.UAV(actorName,r.ActorID,r.Translation,...
            r.Rotation,r.Scale);

            self.Mesh=self.getMesh(quadRotorType,r.Mesh);
            self.Animation=self.getAnimation(quadRotorType);
            self.Color=self.getColor(quadRotorType,r.Color);
            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;


            self.Config.MeshPath=self.Mesh;
            self.Config.AnimationPath=self.Animation;
            self.Config.ColorPath=self.Color;
            self.Config.AdditionalOptions='';
        end

        function ret=getColor(~,quadrotorType,color)


            if strcmp(quadrotorType,'custom')


                ret='/MathWorksUAVContent/UAVs/HexaRotorUAV/UAV_Body.UAV_Body';
            else
                switch color
                case 'black'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyBlack.M_QuadrotorUAV_BodyBlack';
                case 'blue'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyBlue.M_QuadrotorUAV_BodyBlue';
                case 'green'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyGreen.M_QuadrotorUAV_BodyGreen';
                case 'orange'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyOrange.M_QuadrotorUAV_BodyOrange';
                case 'red'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyRed.M_QuadrotorUAV_BodyRed';
                case 'silver'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodySilver.M_QuadrotorUAV_BodySilver';
                case 'white'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyWhite.M_QuadrotorUAV_BodyWhite';
                case 'yellow'
                    ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Material/M_QuadrotorUAV_BodyYellow.M_QuadrotorUAV_BodyYellow';
                otherwise
                    error('sim3d:invalidVehicleColor','Invalid Vehicle Color. Please check help and select a valid Vehicle Color.');
                end
            end
        end

        function ret=getMesh(~,quadRotorType,meshPath)


            switch quadRotorType
            case 'Quadrotor'
                ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Mesh/SK_QuadrotorUAV.SK_QuadrotorUAV';
            case 'Custom'
                ret=meshPath;
            otherwise
                ret='';
            end
        end

        function ret=getAnimation(~,quadRotorType)

            switch quadRotorType
            case 'Quadrotor'
                ret='/MathWorksUAVContent/UAVs/Quadrotor_UAV/Animation/QuadRotorAnimBP.QuadRotorAnimBP_C';
            case 'Custom'
                ret='/MathWorksUAVContent/UAVs/Custom/Animation/UAVAnimBP.UAVAnimBP_C';
            otherwise
                ret='';
            end
        end
    end

    methods(Access=public,Hidden=true)

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.QuadRotorUAV;
        end
    end


    methods(Access=private,Static)
        function r=parseInputs(varargin)



            defaultParams=struct(...
            'Color','black',...
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
