function tokens=splitName(name)











    if(regexp(name,'^\[[^\[\]]*\]\.\[[^\[\]]*\]$'))

        tokens=regexp(name,'^\[([^\[\]]*)\]\.\[([^\[\]]*)\]$','tokens');
        tokens=tokens{:};
    elseif(regexp(name,'^[^\[\]]*\.\[[^\[\]]*\]$'))

        tokens=regexp(name,'^([^\[\]]*)\.\[([^\[\]]*)\]$','tokens');
        tokens=tokens{:};
    elseif(regexp(name,'^\[[^\[\]]*\]\.[^\[\]]*$'))

        tokens=regexp(name,'^\[([^\[\]]*)\]\.([^\[\]]*)$','tokens');
        tokens=tokens{:};
    elseif(regexp(name,'^\[[^\[\]]*\]$'))

        tokens=regexp(name,'^\[([^\[\]]*)\]$','tokens');
        tokens=tokens{:};
    elseif(regexp(name,'^[^\[\]]*\.[^\[\]]*$'))

        tokens=regexp(name,'^([^\[\]]*)\.([^\[\]]*)$','tokens');
        tokens=tokens{:};
    else
        tokens=name;
    end

    if~iscell(tokens)
        tokens={tokens};
    end
end
