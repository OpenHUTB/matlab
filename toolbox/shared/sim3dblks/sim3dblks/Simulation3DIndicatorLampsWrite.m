classdef Simulation3DIndicatorLampsWrite<matlab.System




    methods(Access=protected)
        function icon=getIconImpl(~)
            icon={'Transform','Set'};
        end
    end


    properties(Nontunable)



        Engine(1,1)logical=false;




        Oil(1,1)logical=false;




        TurnSignalLeft(1,1)logical=false;




        TurnSignalRight(1,1)logical=false;




        Hazards(1,1)logical=false;




        LowBeams(1,1)logical=false;




        HighBeams(1,1)logical=false;




        FrontFog(1,1)logical=false;

        ActorTag='SimulinkActor1';
        NumberOfParts=uint32(1);
    end

    properties(DiscreteState)
    end

    properties(Access=private)
        Writer=[];
    end

    methods(Access=protected)
        function setupImpl(self)
            if coder.target('MATLAB')&&sim3d.engine.Engine.isReady()
                self.Writer=sim3d.io.ActorTransformWriter(self.ActorTag,self.NumberOfParts);
                if~isempty(self.Writer)
                    self.Writer.write(self.Translation,self.Rotation,self.Scale);
                end
            end
        end

        function resetImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.write(self.Translation,self.Rotation,self.Scale);
                end
            end
        end

        function stepImpl(self,translation,rotation,scale)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.write(translation,rotation,scale);
                end
            end
        end

        function releaseImpl(self)
            if coder.target('MATLAB')
                if~isempty(self.Writer)
                    self.Writer.delete();
                    self.Writer=[];
                end
            end
        end
    end

    methods(Static,Access=protected)
        function simMode=getSimulateUsingImpl
            simMode='Interpreted execution';
        end
    end
end
