function isEnum=isSLEnumType(dt)



    if~isempty(regexp(dt,'[()]','once'))

        isEnum=false;
    elseif strncmpi('Enum:',dt,5)
        isEnum=true;
    elseif strncmpi('Bus: ',dt,5)
        isEnum=false;
    else
        possEnumType=eval(['?',dt]);
        isEnum=false;
        if~isempty(possEnumType)
            isEnum=isa(possEnumType,'meta.class')&&possEnumType.Enumeration;
        end
    end
end
