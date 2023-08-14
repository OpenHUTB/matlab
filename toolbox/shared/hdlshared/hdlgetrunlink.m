function link=hdlgetrunlink(fileName)












    if feature('hotlinks')
        separators=strfind(fileName,filesep);
        displayName=fileName(separators(end)+1:end);
        link=sprintf('<a href="matlab:run(''%s'')">%s</a>',fileName,displayName);
    else
        link=fileName;
    end


