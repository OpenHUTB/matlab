function[libver,forwards]=libversion(pkgname)









    libver=simscape.versioning.version;
    forwards.ssc=simscape.versioning.internal.ForwardImpl.empty;
    forwards.sl=simscape.versioning.internal.ForwardImpl.empty;

    libm=[pkgname,'.lib'];
    libpth=which(libm);
    if isempty(libpth)
        return;
    else


        fdirpath=ne_private('ne_packagenamefromdirectorypath');
        [~,pkgpart]=fdirpath(fileparts(libpth));
        if~strcmp(pkgpart,pkgname)
            return;
        end
    end

    try
        [libver,forwards]=loadLib(libm);
    catch ME
        exe=MException(message('physmod:ne_sli:versioning:InvalidVersioningData',...
        char(libpth)));
        exe=exe.addCause(ME);
        throw(exe);
    end
end

