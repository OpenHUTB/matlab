function s=saveobj(h)

    s=struct;

    if~isempty(h.Data)&&isa(h.Data,'embedded.fi')
        s.Constructor={'fi',h.Data.Data,struct(h.Data)};
    else
        s.Data=h.Data;
        s.Constructor=h.Constructor;
    end