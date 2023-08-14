function sourceName=convertFileNameToModelName(sourceName)



    if ischar(sourceName)
        [~,fname,ext]=fileparts(sourceName);
        if strcmp(ext,'.mdl')||strcmp(ext,'.slx')
            sourceName=fname;
        end
    end
end