function str=xilinxhdlname(this,strin,isport)












    str=char(strin);
    if~isempty(str)

        str=lower(str);


        str(str<fix('0')|...
        (str>fix('9')&str<fix('a'))|...
        str>fix('z'))='_';

        unders=strfind(str,'__');
        while(any(unders))
            str(unders)=[];
            unders=strfind(str,'__');
        end


        if str=='_'
            str='x';
        end


        if str(1)=='_'
            str=str(2:end);
        end
        if str(end)=='_'
            str=str(1:end-1);
        end


        firstchar=upper(str(1));
        if firstchar>=fix('0')&&firstchar<=fix('9')
            str=['x',str];
        end



        if(isport==1)
            str=regexprep(str,'((?<=_)\d+(?!\w+))',['$1','i']);
        end
    end




