
function out=writeToXML(xmlFile,xmlString)

    fid=fopen(xmlFile,'w','n','UTF-8');

    out=fwrite(fid,xmlString,'char');
    fclose(fid);


end
