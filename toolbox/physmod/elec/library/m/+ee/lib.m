function lib(libInfo)
    libInfo.Name='Simscape Electrical';
    pinfo=ver('toolbox/physmod/elec/library/m');
    libInfo.Annotation=sprintf('%s %s\n%s',pinfo.Name,pinfo.Version,pmsl_copyright(2007));
end