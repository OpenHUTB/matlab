classdef SimulinkModel<stm.internal.util.SimulinkModel




    properties

        workerSysPath='';
    end

    methods
        function obj=SimulinkModel(model,system)
            obj@stm.internal.util.SimulinkModel(model,system);
        end

        function flag=readStopTestBit(obj)
            stopSignFile=fullfile(obj.workerSysPath,'STOP');
            flag=(exist(stopSignFile,'file')>0);
        end

        function restore(obj)
            if~obj.ModelLoadedOrOpened
                bdclose(obj.ModelName);
            end
            obj.ModelLoadedOrOpened='';
        end
    end
end
