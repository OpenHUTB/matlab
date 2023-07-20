function lib(libInfo)
    libInfo.Name='Simscape Fluids';
    pinfo=ver('toolbox/physmod/fluids/fluids');
    libInfo.Annotation=sprintf('%s %s\n%s',pinfo.Name,pinfo.Version,pmsl_copyright(2015));
end
