function ret=registerrealtimecataloglocation(folder)








    ret=true;
    try
        matlab.internal.msgcat.setAdditionalResourceLocation(folder);
    catch ex
        ret=false;
    end


end