function addFileName(self,filename,filedate,autodate)





    if(~ismember(filename,self.files))

        self.filestate=[self.filestate,2];
        self.filedates=[self.filedates,filedate];
        self.autodates=[self.autodates,autodate];
        self.files=[self.files,filename];

    else


    end

end