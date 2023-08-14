function TF=hasWriteAccess(path)




    if isempty(path)
        TF=false;
        return;
    end

    TF=true;
    fileName=fullfile(path,'tmpFile.txt');

    try
        fid=fopen(fileName,'w');
    catch
        TF=false;
    end

    if(fid<0)
        TF=false;
    end

    if TF
        fclose(fid);
        delete(fileName);
    end

end
