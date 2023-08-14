function toFront(self)




    if(~self.windowopen)
        try
            self.mywindow=DAStudio.Dialog(self);
            self.windowopen=true;
        catch E %#ok<NASGU>



            f=self.getFiles;
            if~isempty(f)
                fprintf('%s\n',DAStudio.message('Simulink:dialog:autosaveNoDialog'));
                fprintf('   %s.autosave\n',f{:});
                self.removeFile(f);
            end
        end
    else
        self.mywindow.show();
    end

end
