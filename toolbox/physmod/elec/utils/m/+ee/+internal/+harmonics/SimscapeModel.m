classdef SimscapeModel




    properties
SimlogId
ModelName
SimTime
    end

    methods
        function obj=SimscapeModel(modelName)
            if~bdIsLoaded(modelName)
                load_system(modelName);
                sim(modelName);
            end

            obj.ModelName=modelName;
            simTimeVariable=get_param(obj.ModelName,'StopTime');
            if isnan(str2double(simTimeVariable))



                obj.SimTime=evalin('base',simTimeVariable);
            else
                obj.SimTime=str2double(simTimeVariable);
            end
        end
    end
end

