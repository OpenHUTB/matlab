function removeFile(self,filename)






    [found,loc]=ismember(filename,self.files);
    if(found)
        self.filestate(loc)=[];
        self.files(loc)=[];
        self.autodates(loc)=[];
        self.filedates(loc)=[];
        if(self.numFiles()==0)
            if(self.windowopen)
                delete(self.mywindow);
                self.windowopen=false;
            end
            self.close();


            slprivate('slautosave','release');
            return;
        end
        if(self.windowopen)
            self.mywindow.restoreFromSchema();
        end
    end

end
