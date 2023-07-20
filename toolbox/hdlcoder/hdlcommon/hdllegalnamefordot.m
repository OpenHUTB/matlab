


function str=hdllegalnamefordot(strin)


    str=char(strin);
    if~isempty(str)


        firstchar=upper(str(1));
        if firstchar<fix('A')||firstchar>fix('Z')
            str=['alpha',str];
        end

        str(str<fix('0')|...
        (str>fix('9')&str<fix('A'))|...
        (str>fix('Z')&str<fix('a'))|...
        str>fix('z'))='_';


        if str(end)=='_'
            str=[str,'under'];
        end

        str=regexprep(str,'(_)+','_');
    end
