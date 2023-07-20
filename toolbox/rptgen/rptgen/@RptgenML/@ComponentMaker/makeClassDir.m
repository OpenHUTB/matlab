function makeClassDir(h)




    if isempty(h.ClassName)
        error(message('rptgen:RptgenML_ComponentMaker:noClassName'));
    end

    [ok,errMsg]=mkdir(fullfile(h.PkgDir,['@',h.PkgName]),['@',h.ClassName]);
    if ok==0
        error(message('rptgen:RptgenML_ComponentMaker:noClassDir'));
    end
    h.ClassDir=fullfile(h.PkgDir,['@',h.PkgName],['@',h.ClassName]);

    rptgen.displayMessage(getString(message('rptgen:RptgenML_ComponentMaker:writeToDirectoryLabel',h.ClassDir)),2);