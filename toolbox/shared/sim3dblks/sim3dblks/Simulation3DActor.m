classdef(StrictDefaults)Simulation3DActor<matlab.System

    properties(Nontunable)
        SampleTime=Simulation3DEngine.DEFAULT_SAMPLE_TIME;
    end

    methods(Access=protected)
        function sts=getSampleTimeImpl(self)
            sampleTime=Simulation3DEngine.getEngineSampleTime(self.SampleTime);
            if self.SampleTime==-1
                if sampleTime==-1
                    sts=createSampleTime(self,'Type','Inherited');
                else
                    sts=createSampleTime(self,'Type','Discrete','SampleTime',sampleTime);
                end
            else
                sts=createSampleTime(self,'Type','Discrete','SampleTime',self.SampleTime);
            end
        end

        function setupImpl(self)
            if coder.target('MATLAB')
                sim3d.engine.Engine.start();

                sts=self.getSampleTime();
                sampleTime=sts.SampleTime;
                if sampleTime<Simulation3DEngine.MIN_SAMPLE_TIME
                    warning('sim3d:Simulation3DActor:setupSampleTime:SampleTimeError',...
                    ['The interpreted sample time for the block ''',gcb...
                    ,''' is less than the recommended minimum sample time for the game engine interface. Specify a sample time greater than '...
                    ,num2str(Simulation3DEngine.MIN_SAMPLE_TIME),' s'...
                    ,' (',num2str(1/Simulation3DEngine.MIN_SAMPLE_TIME)...
                    ,' Hz).']);
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