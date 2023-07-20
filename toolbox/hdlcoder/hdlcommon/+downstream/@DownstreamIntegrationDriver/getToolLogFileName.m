function file=getToolLogFileName(obj,taskName)




    hDI=obj;

    file=fullfile(hDI.getFullHdlsrcDir,hDI.getModelName,sprintf('workflow_task_%s.log',matlab.lang.makeValidName(taskName)));

end