classdef Simulation3DActorRayTraceRead<Simulation3DActor&...
Simulation3DHandleMap


    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'Ray Trace','Get'};
        end
    end

    properties(Nontunable)
        ActorTag='SimulinkVehicle1';
        NumberOfRays=1;
    end


    properties(Access=private)
        Reader=[];
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            if coder.target('MATLAB')
                self.Reader=sim3d.io.ActorRayTraceReader(self.ActorTag,uint32(self.NumberOfRays));
                self.ModelName=['Simulation3DActorRayTraceRead/',self.ActorTag];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Reader'],self.Reader);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.ActorTag=s.ActorTag;
            self.NumberOfRays=s.NumberOfRays;

            if self.loadflag
                self.ModelName=s.ModelName;
                self.Reader=self.Sim3dSetGetHandle([self.ModelName,'/Reader']);
            else
                self.Reader=s.Reader;
            end

            loadObjectImpl@matlab.System(self,s,wasInUse);
        end

        function s=saveObjectImpl(self)
            s=saveObjectImpl@matlab.System(self);

            s.Reader=self.Reader;
            s.ActorTag=self.ActorTag;
            s.NumberOfRays=self.NumberOfRays;
            s.ModelName=self.ModelName;
        end

        function[traceStart,traceEnd]=stepImpl(self)
            traceStart=single(zeros(self.NumberOfRays,3));
            traceEnd=single(zeros(self.NumberOfRays,3));
            if coder.target('MATLAB')
                if~isempty(self.Reader)
                    [traceStart,traceEnd]=self.Reader.read();
                end
            end
        end

        function releaseImpl(self)
            if coder.target('MATLAB')
                simulationStatus=get_param(bdroot,'SimulationStatus');
                if strcmp(simulationStatus,'terminating')
                    if~isempty(self.Reader)
                        self.Reader.delete();
                        self.Reader=[];
                        if self.loadflag
                            self.Sim3dSetGetHandle([self.ModelName,'/Reader'],[]);
                        end
                    end
                end
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function[sz1,sz2]=getOutputSizeImpl(self)
            sz1=[double(self.NumberOfRays),3];
            sz2=[double(self.NumberOfRays),3];
        end

        function[fz1,fz2]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
        end

        function[dt1,dt2]=getOutputDataTypeImpl(~)
            dt1='single';
            dt2='single';
        end

        function[cp1,cp2]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
        end
    end
end