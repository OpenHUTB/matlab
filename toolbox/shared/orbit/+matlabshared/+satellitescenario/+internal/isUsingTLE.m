function usingTLE=isUsingTLE(file)





    coder.allowpcode('plain');

    fileID=fopen(file,'r');

    if fileID==-1
        error(message('shared_orbit:orbitPropagator:UnableToOpenTLEOrSEMFile'));
    end

    fgetl(fileID);
    secondLine=strtrim(fgetl(fileID));
    if numel(secondLine)>60
        usingTLE=true;
    else
        usingTLE=false;
    end
    fclose(fileID);
end
