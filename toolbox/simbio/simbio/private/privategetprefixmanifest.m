function prefixmanifest=privategetprefixmanifest(prefixvector,listtype)














    prefixmanifest='';


    if(~isempty(prefixvector))
        if(strcmpi(listtype,'userdefined'))
            header1=sprintf('\n%3s%s\n','','SimBiology UserDefined Unit Prefixes');
        else
            header1=sprintf('\n%3s%s\n','','SimBiology Unit Prefixes');
        end
        header2=sprintf('%3s%-8s%-16s%-25s',...
        '','Index:','Name:','Multiplier:');
        prefixmanifest=header1;
        prefixmanifest=char(prefixmanifest,header2);
        n=length(prefixvector);
        for i=1:n

            len=length(prefixvector(i).name);
            if(len>15)
                tempname=['[1x',num2str(len),' char]'];
            else
                tempname=prefixvector(i).name;
            end
            if strcmp(class(prefixvector(i)),'SimBiology.UnitPrefix')
                mult=power(10,prefixvector(i).exponent);
            else
                mult=prefixvector(i).multiplier;
            end
            displine=sprintf('%3s%-8d%-16s%-25d','',...
            i,tempname,mult);

            prefixmanifest=char(prefixmanifest,displine);
        end
    end

    return;
