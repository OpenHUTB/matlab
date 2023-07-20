function configureSliceMdlSampleTime(obj,origSys,sliceMdl)




    try
        if~isempty(obj.simHandler)&&obj.simHandler.UsingStepper
            origSampleTime=arrayfun(@(s)Simulink.SampleTime(s),get_param(bdroot(origSys),'SampleTimes'));
        else
            origSampleTime=Simulink.BlockDiagram.getSampleTimes(bdroot(origSys));
        end
        if strcmp(get_param(sliceMdl,'SolverType'),'Fixed-step')...
            &&strcmp(get_param(sliceMdl,'FixedStep'),'auto')
            Ts='auto';
            for i=1:length(origSampleTime)
                if origSampleTime(i).Value(1)~=0
                    Ts=sprintf('%.17g',origSampleTime(i).Value(1));
                    break;
                end
            end
            set_param(sliceMdl,'FixedStep',Ts);
        end
        if obj.options.SliceOptions.RootLevelInterfaces...
            &&strcmp(get_param(sliceMdl,'SaveFormat'),'Array')
            set_param(sliceMdl,'SaveFormat','StructureWithTime');
        end
    catch
    end
end

