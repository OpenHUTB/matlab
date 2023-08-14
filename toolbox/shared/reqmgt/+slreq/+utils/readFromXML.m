

function content=readFromXML(xmlFilePath)



    content=[];


    fid=fopen(xmlFilePath,'r','n','UTF-8');
    if fid==-1
        return;
    end


    content=fread(fid,'*char');
    fclose(fid);
end
