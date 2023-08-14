classdef NotInterpolable<Simulink.stawebscope.servermanager.inserter.Inserter







    methods
        function obj=NotInterpolable(item,inputData)
            obj@Simulink.stawebscope.servermanager.inserter.Inserter(item,inputData);
        end
        function data=interpolate(obj,row,col)
            if row==1

                data=obj.InputData{row}{col};
            elseif row>=length(obj.InputData)

                data=obj.InputData{end}{col};
            else
                data=obj.InputData{row-1}{col};
            end
        end

    end
end