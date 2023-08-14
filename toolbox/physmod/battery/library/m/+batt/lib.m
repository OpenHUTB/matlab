function lib(libInfo)




    libInfo.Name='Simscape Battery';
    pinfo=ver('toolbox/physmod/battery/library/m/simscapebattery');
    libInfo.Annotation=sprintf('%s %s\n%s',pinfo.Name,pinfo.Version,pmsl_copyright(2022));
end
