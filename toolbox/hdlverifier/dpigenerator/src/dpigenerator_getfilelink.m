function link=dpigenerator_getfilelink(fileName)



    if feature('hotlinks')
        if fileName(1)==filesep||...
            (fileName(2)==':'&&fileName(3)==filesep)||...
            (fileName(1)=='\'&&fileName(2)=='\')

            separators=strfind(fileName,filesep);
            displayName=fileName(separators(end)+1:end);
        else
            displayName=fileName;
        end
        link=sprintf('<a href="matlab:edit(''%s'')">%s</a>',fileName,displayName);
    else
        link=fileName;
    end




