function[name]=getMetalName(thickness,conductivity)

    S=findMetalMaterial;
    idx_t=zeros(1,numel(S));
    idx_c=zeros(1,numel(S));
    for m=1:numel(S)
        thickness_in_m=calculatethickness(S(m).Thickness,S(m).Units);
        idx_t(m)=(thickness_in_m==thickness);
        idx_c(m)=(S(m).Conductivity==conductivity);
    end
    idx1=find(idx_t);
    idx2=find(idx_c);
    idx=intersect(idx1,idx2);
    if idx
        name=S(idx).Name;
    else
        name='PEC';
    end

end

function thickness_in_m=calculatethickness(Thickness,Units)

    switch Units
    case 'm'
        thickness_in_m=Thickness;
    case 'cm'
        thickness_in_m=Thickness*1e-2;
    case 'mm'
        thickness_in_m=Thickness*1e-3;
    case 'um'
        thickness_in_m=Thickness*1e-6;
    case 'mil'
        thickness_in_m=Thickness*0.0000254;
    case 'inch'
        thickness_in_m=Thickness*0.0254;
    end
end