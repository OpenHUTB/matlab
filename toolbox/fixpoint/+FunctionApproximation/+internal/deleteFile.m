function deleteFile(fullFileName)






    if exist(fullFileName,'file')
        delete(fullFileName);
    end
end