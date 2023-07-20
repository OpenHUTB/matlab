classdef InterfaceType<handle




    enumeration
Informal
Formal
Invalid
    end

    methods(Static)

        function type=determineInterfaceType(definition)
            import Simulink.ModelManagement.Project.BatchJob.Runners.InterfaceType;

            if(isFormal(definition.Command))
                type=InterfaceType.Formal;
            elseif(isInformal(definition.Command))
                type=InterfaceType.Informal;
            else
                type=InterfaceType.Invalid;
            end
        end

    end

end


function formal=isFormal(command)


    formal=isa(command,'slproject.BatchJob');
end

function informal=isInformal(command)

    informal=isa(command,'function_handle');
end

