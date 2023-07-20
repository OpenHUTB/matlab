classdef Prop<handle












































    properties(SetAccess='private',GetAccess='public')

        ObjectType;


        ActorIdentifier;


        ActorTag;
    end

    properties(SetAccess='public',GetAccess='public')

        Mesh;


        Translation;


        Rotation;


        Scale;


        ActorID;
    end

    properties(Access=private)
        Reader=[];
        Writer=[];
        CreateActor=[];
    end

    properties(Access=private,Constant=true)
        NumberOfParts=1;
    end

    methods
        function self=Prop(actorName,objectType,varargin)
            narginchk(2,inf);

            self.ActorTag=actorName;
            self.ObjectType=objectType;


            r=sim3d.Prop.parseInputs(varargin{:});
            switch objectType
            case 'Custom'
                self.Mesh=r.Mesh;
            otherwise
                self.Mesh=self.getMesh();
            end

            self.Translation=single(r.Translation);
            self.Rotation=single(r.Rotation);
            self.Scale=single(r.Scale);
            self.ActorID=r.ActorID;


            self.CreateActor=sim3d.utils.CreateActor;
            self.CreateActor.setActorName(self.ActorTag);
            self.CreateActor.setParentName('Scene Origin');
            self.CreateActor.setCreateActorType(self.getActorType());
            self.CreateActor.setMesh(self.Mesh);
            actorLocation=struct(...
            'translation',single(zeros(1,3)),...
            'rotation',single(zeros(1,3)),...
            'scale',single(ones(1,3)));
            self.CreateActor.setActorId(self.ActorID);
            if~isempty(self.Translation)
                actorLocation.translation=self.Translation;
            end
            if~isempty(self.Rotation)
                actorLocation.rotation=self.Rotation;
            end
            if~isempty(self.Scale)
                actorLocation.scale=self.Scale;
            end
            self.CreateActor.setActorLocation(actorLocation);


            self.CreateActor.setMobility(sim3d.utils.MobilityTypes.Movable);
            self.CreateActor.setVisiblity(true);
            self.CreateActor.setHidden(false);
            self.CreateActor.setPhysics(true);


            self.CreateActor.write;
        end

        function ret=getMesh(self)
            switch self.ObjectType
            case 'Cone'
                ret='/Game/Environment/Industrial/Props/Cone/Mesh/SM_Cone.SM_Cone';
            case 'Checkerboard'
                ret='/Game/Environment/Industrial/Props/Validation/SM_CheckerboardPatternPlane.SM_CheckerboardPatternPlane';
            otherwise
                ret='';
            end
        end

        function actorType=getActorType(~)
            actorType=sim3d.utils.ActorTypes.BaseStatic;
        end

        function delete(self)

            if~isempty(self.Reader)
                self.Reader.delete();
                self.Reader=[];
            end
            if~isempty(self.Writer)
                self.Writer.delete();
                self.Writer=[];
            end
            if~isempty(self.CreateActor)
                self.CreateActor.delete();
                self.CreateActor=[];
            end
        end

    end

    methods(Access=private,Static=true,Hidden=true)
        function r=parseInputs(varargin)

            defaultParams=struct(...
            'Mesh','MeshText',...
            'Translation',[0,0,0],...
            'Rotation',[0,0,0],...
            'Scale',[1,1,1],...
            'ActorID',4);


            parser=inputParser;
            parser.addParameter('Mesh',defaultParams.Mesh);
            parser.addParameter('Translation',defaultParams.Translation);
            parser.addParameter('Rotation',defaultParams.Rotation);
            parser.addParameter('Scale',defaultParams.Scale);
            parser.addParameter('ActorID',defaultParams.ActorID);


            parser.parse(varargin{:});
            r=parser.Results;
        end
    end
end