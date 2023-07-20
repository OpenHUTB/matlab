function filename=assignFilenameFromURL(url)















    url=convertStringsToChars(url);
    [~,~,ext]=fileparts(url);
    if contains(ext,'?')
        ext=extractBefore(ext,'?');
    end

    basename=tempname;
    if isempty(ext)
        filename=basename;
    else
        filename=[basename,ext];
    end
end