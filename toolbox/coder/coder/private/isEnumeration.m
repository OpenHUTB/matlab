



function result=isEnumeration(className)
    m=meta.class.fromName(className);
    result=~isempty(m)&&~isempty(m.EnumerationMemberList);
end