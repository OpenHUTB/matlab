function result=isWriteable(fPath)









    fid=fopen(fPath,'w');
    if fid<0
        result=false;
    else
        result=true;
        fclose(fid);
        delete(fPath);
    end

end
