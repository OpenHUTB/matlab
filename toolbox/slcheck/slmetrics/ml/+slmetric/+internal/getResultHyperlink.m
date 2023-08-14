function href=getResultHyperlink(varargin)






    ip=inputParser();
    ip.addRequired('ComponentID',@ischar);
    ip.parse(varargin{:});
    in=ip.Results;

    href=loc_getComponentHref(in.ComponentID);
end

function href=loc_getComponentHref(compID)


    [instanceSID,sid]=strtok(compID,'#');

    if isempty(sid)

        href=['matlab: slmetric.internal.open_system(''',instanceSID,''')'];
    else


        href=['matlab: slmetric.internal.open_system(''',sid(2:end),''')'];
    end
end