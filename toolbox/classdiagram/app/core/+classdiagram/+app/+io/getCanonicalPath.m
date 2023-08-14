function abs=getCanonicalPath(fileName)

    fileName=string(strip(fileName));
    if fileName.startsWith('/')||fileName.startsWith('\')||fileName.contains(":")
        abs=fileName;
    else
        abs=string(fullfile(pwd,fileName));
    end
    if~abs.endsWith(".mldatx")
        abs=abs+".mldatx";
    end
end

