function v=isSystem(candidate,desFilter)




    if nargin<2
        desFilter=false;
    end

    if isstring(candidate)&&isscalar(candidate)
        candidate=char(candidate);
    end


    if~ischar(candidate)
        v=false;
        return;
    end


    try
        mc=meta.class.fromName(candidate);
        if isempty(mc)||~isa(mc,'matlab.system.SysObjCustomMetaClass')
            v=false;
        elseif desFilter
            d=(mc<=?matlab.DiscreteEventSystem);
            v=(~isempty(d)&&d);
        else
            v=true;
        end
    catch err %#ok<NASGU>
        v=false;
    end
end