classdef(StrictDefaults)Simulation3DActorTransformWrite<Simulation3DActor&...
Simulation3DHandleMap


    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'Transform','Set'};
        end
    end


    properties
        Translation=zeros(1,3);
        Rotation=zeros(1,3);
        Scale=ones(1,3);
    end

    properties(Nontunable)
        ActorTag='SimulinkActor1';
        NumberOfParts=1;
    end

    properties(Access=private)
        Writer=[];
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            if coder.target('MATLAB')

                if~all(size(self.Translation)==[self.NumberOfParts,3])||...
                    ~all(size(self.Rotation)==[self.NumberOfParts,3])||...
                    ~all(size(self.Scale)==[self.NumberOfParts,3])
                    parameterVerificationException=MException(...
                    'sim3d:Simulation3DActorTransformWrite:setupImpl:ParameterError',...
                    ['3D Simulation actor translation, rotation, and scale parameters should be real-valued '...
                    ,num2str(self.NumberOfParts),'-by-3 arrays.']);
                    throw(parameterVerificationException);
                end
                self.Writer=sim3d.io.ActorTransformWriter(self.ActorTag,...
                uint32(self.NumberOfParts));
                if~isempty(self.Writer)
                    self.Writer.write(single(self.Translation),...
                    single(self.Rotation),single(self.Scale));
                end
                self.ModelName=['Simulation3DActorTransformWrite/',self.ActorTag];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Writer'],self.Writer);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.ActorTag=s.ActorTag;
            self.NumberOfParts=s.NumberOfParts;
            self.Translation=s.Translation;
            self.Rotation=s.Rotation;
            self.Scale=s.Scale;

            if self.loadflag
                self.ModelName=s.ModelName;
                self.Writer=self.Sim3dSetGetHandle([self.ModelName,'/Writer']);
            else
                self.Writer=s.Writer;
            end

            loadObjectImpl@matlab.System(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@matlab.System(self);
            s.Writer=self.Writer;
            s.ActorTag=self.ActorTag;
            s.NumberOfParts=self.NumberOfParts;
            s.Translation=self.Translation;
            s.Rotation=self.Rotation;
            s.Scale=self.Scale;
            s.ModelName=self.ModelName;
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.write(single(self.Translation),...
                    single(self.Rotation),single(self.Scale));
                end
            end
        end

        function stepImpl(self,translation,rotation,scale)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.write(single(translation),...
                    single(rotation),single(scale));
                end
            end
        end

        function releaseImpl(self)
            if coder.target('MATLAB')
                simulationStatus=get_param(bdroot,'SimulationStatus');
                if strcmp(simulationStatus,'terminating')
                    if~isempty(self.Writer)
                        self.Writer.delete();
                        self.Writer=[];
                        if self.loadflag
                            self.Sim3dSetGetHandle([self.ModelName,'/Writer'],[]);
                        end
                    end

                end
            end
        end
    end
end
