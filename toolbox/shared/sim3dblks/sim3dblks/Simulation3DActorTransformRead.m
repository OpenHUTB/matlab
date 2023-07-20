classdef(StrictDefaults)Simulation3DActorTransformRead<Simulation3DActor&...
Simulation3DHandleMap






    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'Transform','Get'};
        end
    end

    properties(Nontunable)
        ActorTag='SimulinkActor1';
        NumberOfParts=1;
    end

    properties(Access=private)
        Reader=[];
        ModelName=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            setupImpl@Simulation3DActor(self);
            if coder.target('MATLAB')
                self.Reader=sim3d.io.ActorTransformReader(self.ActorTag,uint32(self.NumberOfParts));
                self.ModelName=['Simulation3DActorTransformRead/',self.ActorTag];
                if self.loadflag
                    self.Sim3dSetGetHandle([self.ModelName,'/Reader'],self.Reader);
                end
            end
        end

        function loadObjectImpl(self,s,wasInUse)
            self.ActorTag=s.ActorTag;
            self.NumberOfParts=s.NumberOfParts;

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
            s.NumberOfParts=self.NumberOfParts;
            s.ModelName=self.ModelName;
        end

        function[translation,rotation,scale]=stepImpl(self)
            translation=single(zeros(self.NumberOfParts,3));
            rotation=single(zeros(self.NumberOfParts,3));
            scale=single(zeros(self.NumberOfParts,3));
            if coder.target('MATLAB')
                if~isempty(self.Reader)
                    [translation,rotation,scale]=self.Reader.read();
                    rotation=wrapToPi(rotation);
                end
            end
        end

        function releaseImpl(self)
            simulationStatus=get_param(bdroot,'SimulationStatus');
            if coder.target('MATLAB')
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
            num=3;
        end

        function[sz1,sz2,sz3]=getOutputSizeImpl(self)
            sz1=[double(self.NumberOfParts),3];
            sz2=[double(self.NumberOfParts),3];
            sz3=[double(self.NumberOfParts),3];
        end

        function[fz1,fz2,fz3]=isOutputFixedSizeImpl(~)
            fz1=true;
            fz2=true;
            fz3=true;
        end

        function[dt1,dt2,dt3]=getOutputDataTypeImpl(~)
            dt1='single';
            dt2='single';
            dt3='single';
        end

        function[cp1,cp2,cp3]=isOutputComplexImpl(~)
            cp1=false;
            cp2=false;
            cp3=false;
        end
    end
end
