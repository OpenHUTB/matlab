function fwdpth=loader(enclosingFile,path)













    fwdpth=path;

    fdir=ne_private('ne_gendir');
    [fileDir,fileBase]=fdir(enclosingFile);
    verfile=fullfile(fileDir,[fileBase,'.pmver']);
    if~exist(verfile,'file')

        return;
    end

    depver=load(verfile,'-mat');
    depver=depver.depver;

    dotparts=strsplit(path,'.');
    libname=dotparts{1};
    if depver.isKey(libname)
        depVersion=depver(libname);
        [libver,forwards]=simscape.versioning.internal.libversion(libname);


        if depVersion<libver
            fwds=sortedForwards(forwards.ssc,path);
            for fwd=fwds
                if depVersion<fwd.Version&&...
                    ~isempty(fwd.LegacySimscapePath)
                    fwdpth=fwd.LegacySimscapePath;
                    return;
                end
            end
        end
    end
end