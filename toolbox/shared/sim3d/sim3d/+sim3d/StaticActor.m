classdef StaticActor<sim3d.AbstractActor

    properties(Access=private)
        SignalReader=[];
    end
    
    methods
        function self=StaticActor(actorName,meshFile,translation,varargin)
            narginchk(3,inf);
            r=sim3d.StaticActor.parseInputs(varargin{:});
            self@sim3d.AbstractActor(...
            actorName,...
            r.ParentActor,...
            single(translation),...
            single(r.Rotation),...
            single(r.Scale),...
            'ActorClassId',uint16(r.CustomDepthStencilValue),...
            'Mesh',meshFile,...
            'Mobility',r.Mobility,...
            'Visibility',r.Visibility,...
            'HiddenInGame',r.HiddenInGame,...
            'SimulatePhysics',r.SimulatePhysics,...
            'EnableGravity',r.EnableGravity,...
            'CastShadow',r.CastShadow);
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.BaseStatic;
        end

        function writeTransform(self,translation,rotation,scale)

            self.Translation=translation;
            self.Rotation=rotation;
            self.Scale=scale;
            writeTransform@sim3d.AbstractActor(self);
        end

        function reset(self)
            self.SignalReader=setupSimulation3DMessageInt8Reader(self.getTag(),uint32((1)));
        end

        function collision=readMessage(self)

            if isempty(self.SignalReader)
                collision=0;
            else
                [result,readMessage]=readSimulation3DMessageInt8(self.SignalReader,uint32(1));
            end

            if result==0&&~isempty(readMessage)
                collision=double(reshape(readMessage,[1,1]));

            elseif result==13&&~isempty(readMessage)


            else
                collision=0;
            end
        end

        function delete(self)


            delete@sim3d.AbstractActor(self);
        end
    end

    methods(Access=private,Static)
        function r=parseInputs(varargin)

            defaultParams=struct(...
            'Rotation',single(zeros(1,3)),...
            'Scale',single(ones(1,3)),...
            'ParentActor','Scene Origin',...
            'CustomDepthStencilValue',uint16(sim3d.utils.SemanticType.None),...
            'Mobility',int32(sim3d.utils.MobilityTypes.Static),...
            'Visibility',true,...
            'HiddenInGame',false,...
            'SimulatePhysics',false,...
            'EnableGravity',true,...
            'CastShadow',true);


            parser=inputParser;
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ParentActor',defaultParams.ParentActor);
            parser.addParameter('CustomDepthStencilValue',defaultParams.CustomDepthStencilValue);
            parser.addParameter('Mobility',defaultParams.Mobility);
            parser.addParameter('Visibility',defaultParams.Visibility);
            parser.addParameter('HiddenInGame',defaultParams.HiddenInGame);
            parser.addParameter('SimulatePhysics',defaultParams.SimulatePhysics);
            parser.addParameter('EnableGravity',defaultParams.EnableGravity);
            parser.addParameter('CastShadow',defaultParams.CastShadow);


            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end