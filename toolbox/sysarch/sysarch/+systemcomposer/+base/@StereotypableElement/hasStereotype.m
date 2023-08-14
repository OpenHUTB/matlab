function tf=hasStereotype(this,stereotype)














    tf=false;
    stereotypeToFind=[];

    if ischar(stereotype)||(isstring(stereotype)&&isscalar(stereotype))
        stereotypeToFind=systemcomposer.profile.Stereotype.find(char(stereotype));

    elseif isa(stereotype,'systemcomposer.profile.Stereotype')&&isscalar(stereotype)
        stereotypeToFind=stereotype;

    end

    if~isempty(stereotypeToFind)
        stereotypeNames=this.getStereotypes();
        tf=cellfun(@(aStereo)localIsa(aStereo,stereotypeToFind),stereotypeNames);
        tf=any(tf);
    end

end

function tf=localIsa(s1Name,s2)



    s1=systemcomposer.profile.Stereotype.find(s1Name);
    tf=s1.isDerivedFrom(s2);

end
