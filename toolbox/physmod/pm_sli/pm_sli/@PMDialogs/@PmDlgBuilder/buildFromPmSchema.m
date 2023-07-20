function retVal=buildFromPmSchema(hThis,varargin)











    retVal=true;

    if(nargin==0)
        pm_abort('Missing arguments');
    end

    if(nargin>2)
        warning('physmod:pmdialogs:pmdlgbuilder:buildfrompmschema:IgnoreAdditionalArgs','Additional arguments will be ignored.');
    end

    schema=varargin{1};

    retVal=hThis.buildChildrenFromPmSchema(schema);


