function str=alterahdlname(this,strin)












    str=char(strin);
    if~isempty(str)

        str(str<fix('0')|...
        (str>fix('9')&str<fix('A'))|...
        (str>fix('Z')&str<fix('a'))|...
        str>fix('z'))='_';


        unders=strfind(str,'__');
        while(any(unders))
            str(unders)=[];
            unders=strfind(str,'__');
        end


        firstchar=upper(str(1));
        if str(1)=='_'
            str=['id',str];
        elseif firstchar<fix('A')||firstchar>fix('Z')
            str=['id_',str];
        end


        if str(end)=='_'
            str=str(1:end-1);
        end
    end




