function closestf(fid,prevfpos)



    if prevfpos>=0
        fseek(fid,prevfpos,-1);
    else
        fclose(fid);
    end
