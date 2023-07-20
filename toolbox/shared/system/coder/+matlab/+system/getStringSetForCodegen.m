function enumSet=getStringSetForCodegen(className,propName)






    mc=meta.class.fromName(className);

    mp=findobj(mc.PropertyList,'-depth',1,'Name',propName);

    if isempty(mp)||~isa(mp,'matlab.system.CustomMetaProp')
        enumSet='';
        return
    end

    if mp.ConstrainedSet
        setMP=findobj(mc.PropertyList,'-depth',1,'Name',[propName,'Set']);
        enumSet=char(setMP.DefaultValue.getAllowedValues());
    elseif~isempty(mp.MustBeMember)
        enumSet=char(mp.MustBeMember.Values);
    end
end
