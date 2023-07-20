classdef Enable<serdes.internal.ibisami.ami.parameter.SerDesModelSpecificParameter

...
...
...
...
...
...



    methods
        function param=Enable()
            param.NodeName="Enable";
            param.Usage=serdes.internal.ibisami.ami.usage.In;
            param.Type=serdes.internal.ibisami.ami.type.Boolean;
            param.Format=serdes.internal.ibisami.ami.format.List(true,false);
            param.Description=...
            "If True, debug files are produced.";
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
            if isa(type,'serdes.internal.ibisami.ami.type.Boolean')
                ok=true;
            else
                error(message('serdes:ibis:NotPermittedProperty',type.Name,'Type',param.NodeName))
            end
        end
        function ok=validateFormat(param,format)
            if isa(format,'serdes.internal.ibisami.ami.format.List')||...
                isa(format,'serdes.internal.ibisami.ami.format.Value')
                ok=true;
            else
                error(message('serdes:ibis:NotPermittedProperty',format.Name,'Format',param.NodeName))
            end
        end
    end
end

