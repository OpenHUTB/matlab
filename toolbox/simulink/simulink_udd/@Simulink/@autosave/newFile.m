function newFile(self,filename)





    fileinfo=dir(filename);
    if length(fileinfo)~=1
        DAStudio.error('Simulink:dialog:autosaveCantDateFile',filename);
    end

    autosavefile=[filename,self.autosaveext];
    autosavefileinfo=dir(autosavefile);
    if length(autosavefileinfo)~=1
        DAStudio.error('Simulink:dialog:autosaveCantDateFile',...
        [filename,self.autosaveext]);
    end

    if autosavefileinfo.datenum<=fileinfo.datenum
        return;
    end

    self.addFileName(filename,fileinfo.date,autosavefileinfo.date);
    if(self.windowopen)
        self.mywindow.restoreFromSchema();
    end


end
