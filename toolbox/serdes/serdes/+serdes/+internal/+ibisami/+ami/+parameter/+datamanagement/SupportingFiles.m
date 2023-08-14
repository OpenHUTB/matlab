classdef SupportingFiles<serdes.internal.ibisami.ami.parameter.DataManagementReservedParameter

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    methods
        function param=SupportingFiles(varargin)
            format=serdes.internal.ibisami.ami.format.Table();
            if nargin==1
                format.Values=varargin{1};
            elseif nargin>1
                error(message('serdes:ibis:InvalidConstructor'))
            end
            param.NodeName="Supporting_Files";
            param.Usage=serdes.internal.ibisami.ami.usage.Info();
            param.Type=serdes.internal.ibisami.ami.type.String();
            param.Format=format;
            param.Description=...
            "Contains file names and/or directory names to point to files and/or directories which are used by the AMI executable model directly or by the EDA tool to function properly.";
        end
    end
    methods(Access=protected)
        function ok=validateFormat(parameter,format)

            ok=false;
            if~validateFormat@serdes.internal.ibisami.ami.parameter.FixedFormatUsageAndType(parameter,format)
                return
            end
            sz=size(format.Values);
            if~isempty(format.Values)
                if sz(2)~=1
                    warning(message('serdes:ibis:MustBeOneColumn',parameter.NodeName))
                    return
                end
            end
            ok=true;
        end
    end
end

