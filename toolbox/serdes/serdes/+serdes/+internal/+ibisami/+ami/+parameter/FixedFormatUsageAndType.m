classdef(Abstract)FixedFormatUsageAndType<serdes.internal.ibisami.ami.parameter.ReservedParameter




    methods(Access=protected)


        function ok=validateType(parameter,type)
            ok=true;
            if~isempty(parameter.Type)
                if~strcmp(type.Name,parameter.Type.Name)
                    warning(message('serdes:ibis:CannotModify',"Type",parameter.NodeName))
                    ok=false;
                end
            end
        end
        function ok=validateUsage(parameter,usage)
            ok=true;
            if~isempty(parameter.Usage)
                if~strcmp(usage.Name,parameter.Usage.Name)
                    warning(message('serdes:ibis:CannotModify',"Usage",parameter.NodeName))
                    ok=false;
                end
            end
        end
        function ok=validateFormat(parameter,format)
            ok=true;
            if~isempty(parameter.Format)
                if~strcmp(format.Name,parameter.Format.Name)
                    warning(message('serdes:ibis:CannotModify',"Format",parameter.NodeName))
                    ok=false;
                end
            end
        end
    end
end

