function customizeIDLGeneratedFiles(filePath,files)





    for i=1:length(files)
        file=fullfile(filePath,files{i});
        [~,filename,ext]=fileparts(file);
        if(slfeature('TypeMapping')>0)&&strcmp(ext,'.h')...
            &&~contains(file,'PubSubTypes.h')
            customizeHeader=dds.internal.customizeHeaderUtil(file);
            customizeHeader.getAndCustomizeMembers();
        end
        if strcmp(ext,'.cxx')

            movefile(file,fullfile(filePath,[filename,'.cpp']));
        end
    end
end
