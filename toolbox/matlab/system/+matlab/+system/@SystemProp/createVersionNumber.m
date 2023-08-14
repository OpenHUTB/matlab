function num=createVersionNumber(bMajor)

    v=builtin('version');
    version_numbers=strsplit(v,{'.',' '});

    if strcmp(bMajor,'major')
        num=uint16(str2double(version_numbers{1}));
    else
        num=uint16(str2double(version_numbers{2}))*256+...
        uint16(str2double(version_numbers{3}));
    end
end
