function unitmanifest=privategetunitmanifest(unitvector,listtype)










    unitmanifest='';


    if(~isempty(unitvector))
        if(strcmpi(listtype,'userdefined'))
            header1=sprintf('\n%3s%s\n','','SimBiology UserDefined Units');
        else
            header1=sprintf('\n%3s%s\n','','SimBiology Units');
        end
        header2=sprintf('%3s%-8s%-16s%-25.25s%-16s%-13s',...
        '','Index:','Name:','Composition:','Multiplier:');
        unitmanifest=header1;
        unitmanifest=char(unitmanifest,header2);
        n=length(unitvector);
        for i=1:n


            len=length(unitvector(i).name);
            if(len>15)
                tempname=['[1x',num2str(len),' char]'];
            else
                tempname=unitvector(i).name;
            end


            len=length(unitvector(i).composition);
            if(len>24)
                tempcomp=['[1x',num2str(len),' char]'];
            else
                tempcomp=unitvector(i).composition;
            end

            mult=unitvector(i).Multiplier;
            displine=sprintf('%3s%-8d%-16s%-25.25s%-16f','',...
            i,tempname,tempcomp,mult);
            unitmanifest=char(unitmanifest,displine);
        end
    end
    return

