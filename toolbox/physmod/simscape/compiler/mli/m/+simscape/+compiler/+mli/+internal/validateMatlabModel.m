function validateMatlabModel(cm)





    assert(isa(cm,'NetworkEngine.ElementSchema'))




    path=cm.info.Path;
    txt=sprintf(['component wrapper\n'...
    ,'  components(ExternalAccess=none)\n'...
    ,'    x = %s;\n'...
    ,'  end\n'...
    ,'end\n'],path);
    mod=simscape.ComponentModel(txt);




    simscape.validateModel(mod);

end
