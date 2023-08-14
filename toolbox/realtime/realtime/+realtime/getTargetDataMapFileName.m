function mapFile=getTargetDataMapFileName(modelName,buildFolder)




    endPattern='_targ_data_map';
    mapFile='';
    files=dir(buildFolder);
    for i=1:length(files)
        if~files(i).isdir
            file=files(i).name;
            [~,fileName,fileExt]=fileparts(file);
            if isequal(fileExt,'.m')&&endsWith(fileName,endPattern)&&...
                contains(modelName,strrep(fileName,endPattern,''))
                mapFile=file;
                return;
            end
        end
    end
end
