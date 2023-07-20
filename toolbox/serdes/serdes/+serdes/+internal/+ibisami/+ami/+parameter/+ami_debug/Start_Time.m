classdef Start_Time<serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter

...
...
...
...
...
...



    methods
        function param=Start_Time()
            param.NodeName="Start_Time";
            param.Usage=serdes.internal.ibisami.ami.usage.In;
            param.Type=serdes.internal.ibisami.ami.type.Float;
            param.Format=serdes.internal.ibisami.ami.format.Range(0,0,1);
            param.Description=...
            "Time in seconds for AMI Debug to begin wave file output.";
            param.NameLocked=true;
            param.Editable=false;
        end
    end
    methods(Access=protected)


        function ok=validateUsage(param,usage)
            if isa(usage,'serdes.internal.ibisami.ami.usage.In')
                ok=true;
            else
                error(message('serdes:ibis:NotPermittedProperty',usage.Name,'Usage',param.NodeName))
            end
        end
        function ok=validateType(param,type)
            if isa(type,'serdes.internal.ibisami.ami.type.Float')
                ok=true;
            else
                error(message('serdes:ibis:NotPermittedProperty',type.Name,'Type',param.NodeName))
            end
        end
        function ok=validateFormat(param,format)
            if isa(format,'serdes.internal.ibisami.ami.format.Value')||...
                isa(format,'serdes.internal.ibisami.ami.format.Range')
                ok=true;
            else
                error(message('serdes:ibis:NotPermittedProperty',format.Name,'Format',param.NodeName))
            end
        end
    end
end

