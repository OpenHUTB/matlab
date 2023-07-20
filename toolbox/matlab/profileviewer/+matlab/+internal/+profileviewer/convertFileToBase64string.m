function base64string=convertFileToBase64string(file)


    fid=fopen(file,'rb');
    bytes=fread(fid,'uint8=>uint8');
    fclose(fid);
    base64string=matlab.net.base64encode(bytes);
end