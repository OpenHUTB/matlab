function isReadOnly=isCSCRegFileReadOnly(hUI)





    isReadOnly=false;
    if strcmp(hUI.RegFileInfo{3},'.m')

        existingFile=exist(hUI.RegFilePath,'file');

        fid=fopen(hUI.RegFilePath,'a');
        if fid==-1
            isReadOnly=true;
        else
            fclose(fid);

            if~existingFile

                delete(hUI.RegFilePath);
            end
        end

    else
        isReadOnly=true;
    end

