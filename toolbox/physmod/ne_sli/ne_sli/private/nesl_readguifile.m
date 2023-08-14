function[guiInfo,fileName]=nesl_readguifile(hObj)











    guiInfo=[];
    fileName='';




    hInfoObj=hObj.info;
    guiFile=hInfoObj.GuiFile;
    [guiFileDir,guiFileName]=fileparts(guiFile);
    fcn=pm_pathtofunctionhandle(guiFileDir,guiFileName);





    if~isempty(fcn)
        funcs=functions(fcn);
        guiInfo=fcn();
        fileName=funcs.file;
    end

end
