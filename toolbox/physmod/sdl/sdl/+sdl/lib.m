function lib(libInfo)
    libInfo.Name='Simscape Driveline';
    pinfo=ver('toolbox/physmod/sdl/sdl');
    libInfo.Annotation=sprintf('%s %s\n%s',pinfo.Name,pinfo.Version,pmsl_copyright(1998));
end
