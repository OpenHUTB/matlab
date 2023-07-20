function data=guiStruct(guiFile)
    fcn=pm_pathtofunctionhandle(guiFile);
    data=fcn();
end
