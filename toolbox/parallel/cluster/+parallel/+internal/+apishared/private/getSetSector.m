function sector=getSetSector(clientSector)


mlock
    persistent myCurrentSector;

    if~feature('isdmlworker')||isempty(myCurrentSector)
        sector=builtin('_pctLicenseType');
    else
        sector=myCurrentSector;
    end

    if nargin>0&&feature('isdmlworker')
        myCurrentSector=clientSector;
    end
