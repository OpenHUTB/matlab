function lib(libInfo)
    libInfo.Name='Simscape Fluids';
    pinfo=ver('toolbox/physmod/sh/sh');
    libInfo.Annotation=sprintf('%s %s\n%s',pinfo.Name,pinfo.Version,pmsl_copyright(2005));
end
