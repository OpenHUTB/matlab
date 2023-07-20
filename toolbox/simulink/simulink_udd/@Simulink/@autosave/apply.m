function[success,errstring]=apply(self)




    success=true;
    errstring='';


    files_to_ignore=self.files(self.filestate==2);
    for currf=files_to_ignore
        self.removeFile(currf);
    end


    files_to_restore=self.files(self.filestate==0);
    for currf=files_to_restore
        try
            [thisfilesuccess,msg]=self.restore(currf{1},self.keeporiginal);
            if(thisfilesuccess)

                self.removeFile(currf);
            else
                errstring=i_AppendMessage(errstring,msg);
                success=false;
            end
        catch E


            errstring=i_AppendMessage(errstring,E.message);
            load_system(currf{1});
            success=false;
        end
    end


    files_to_discard=self.files(self.filestate==1);
    for currf=files_to_discard
        filename=currf{1};
        try
            i_Discard(self,filename);

            self.removeFile(filename);
        catch E
            success=false;
            errstring=i_AppendMessage(errstring,E.message);
        end
    end




    if(self.windowopen)
        self.mywindow.restoreFromSchema();
    end

end


function i_Discard(self,filename)

    [exists,attribs]=fileattrib([filename,self.autosaveext]);
    if~exists
        return
    end
    if~attribs.UserWrite
        DAStudio.error('Simulink:dialog:autosaveDiscardError',...
        [filename,self.autosaveext]);
    end

    try
        delete([filename,self.autosaveext]);
    catch E
        DAStudio.error('Simulink:dialog:autosaveDiscardError',...
        [filename,self.autosaveext]);
    end
end


function str=i_AppendMessage(str,msg)
    if isempty(str)
        str=DAStudio.message('Simulink:dialog:autosaveDefaultApplyErr',msg);
    else
        str=[str,'<br>',msg];
    end

end
