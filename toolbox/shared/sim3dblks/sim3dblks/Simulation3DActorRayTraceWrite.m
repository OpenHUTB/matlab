classdef Simulation3DActorRayTraceWrite<Simulation3DActor&...
Simulation3DHandleMap


    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'Ray Trace','Set'};
        end
    end


    properties
TraceStart
TraceEnd
    end

    properties(Nontunable)
        ActorTag='SimulinkVehicle1';
        NumberOfRays=1;
    end

    properties(DiscreteState)
    end

    properties(Access=private)
        Writer=[];
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            if coder.target('MATLAB')
                self.Writer=sim3d.io.ActorRayTraceWriter(self.ActorTag,...
                uint32(self.NumberOfRays));
                if~isempty(self.Writer)
                    self.Writer.write(single(self.TraceStart),...
                    single(self.TraceEnd));
                end
                self.ModelName=['Simulation3DActorRayTraceWrite/',self.ActorTag];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Writer'],self.Writer);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)

            self.ActorTag=s.ActorTag;
            self.NumberOfRays=s.NumberOfRays;
            self.TraceStart=s.TraceStart;
            self.TraceEnd=s.TraceEnd;

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
            s.NumberOfRays=self.NumberOfRays;
            s.TraceStart=self.TraceStart;
            s.TraceEnd=self.TraceEnd;
            s.ModelName=self.ModelName;
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.write(single(self.TraceStart),...
                    single(self.TraceEnd));
                end
            end
        end

        function stepImpl(self,traceStart,traceEnd)
            if coder.target('MATLAB')
                if~isempty(self.Writer)

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