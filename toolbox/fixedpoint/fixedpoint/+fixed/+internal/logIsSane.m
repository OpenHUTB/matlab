function pass=logIsSane(log)




    pass=false;
    if~isStringField(log,'MexFileName');return;end
    if~isStringField(log,'TimeStamp');return;end
    if~isStringField(log,'buildDir');return;end
    if~isfield(log,'Functions');return;end

    for i=1:length(log.Functions)
        f=log.Functions(i);
        if~isStringField(f,'FunctionName');return;end
        if~isDoubleScalarField(f,'FunctionID');return;end
        if~isfield(f,'loggedLocations');return;end

        for j=1:length(f.loggedLocations)
            s=f.loggedLocations(j);
            if~isDoubleRowField(s,'SimMin');return;end
            if~isDoubleRowField(s,'SimMax');return;end
            if~isDoubleRowField(s,'OverflowWraps');return;end
            if~isDoubleRowField(s,'Saturations');return;end
            if~isLogicalRowField(s,'IsAlwaysInteger');return;end
            if~isDoubleRowField(s,'Index');return;end
            if numel(s.SimMin)~=numel(s.SimMax);return;end
            if numel(s.SimMin)~=numel(s.OverflowWraps);return;end
            if numel(s.SimMin)~=numel(s.Saturations);return;end
            if numel(s.SimMin)~=numel(s.IsAlwaysInteger);return;end
            if numel(s.SimMin)~=numel(s.Index);return;end
            if~isfield(s,'Fields');return;end
            if~isempty(s.Fields)...
                &&numel(s.SimMin)~=numel(s.Fields);return;end
            if~isfield(s,'Locations');return;end
            if isempty(s.Locations);return;end
            if~isrow(s.Locations);return;end
            if numel(s.Locations)>2;return;end
            for k=1:length(s.Locations)
                if~isDoubleScalarField(s.Locations(k),'TextStart');return;end
                if~isDoubleScalarField(s.Locations(k),'TextLength');return;end
            end
        end
    end
    pass=true;

    function yes=isDoubleScalarField(s,f)
        yes=isfield(s,f)&&isa(s.(f),'double')&&~isempty(s.(f))&&isscalar(s.(f));
    end
    function yes=isDoubleRowField(s,f)
        yes=isfield(s,f)&&isa(s.(f),'double')&&~isempty(s.(f))&&isrow(s.(f));
    end
    function yes=isLogicalScalarField(s,f)
        yes=isfield(s,f)&&islogical(s.(f))&&~isempty(s.(f))&&isscalar(s.(f));
    end
    function yes=isLogicalRowField(s,f)
        yes=isfield(s,f)&&islogical(s.(f))&&~isempty(s.(f))&&isrow(s.(f));
    end
    function yes=isStringField(s,f)
        yes=isfield(s,f)&&ischar(s.(f))&&~isempty(s.(f))&&isrow(s.(f));
    end
end
