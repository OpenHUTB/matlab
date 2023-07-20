function[compStr,cver]=hCreateCompStr(comp)



    if isempty(comp)||strcmp(comp.Manufacturer,'lcc')
        manufacturer='LCC';
    else
        manufacturer=comp.Manufacturer;
    end


    switch(manufacturer)
    case{'LCC','Apple'}


        cver='x';
    case 'GNU'
        cver='x';
    case 'Intel'




        compStr=comp.ShortName;
        cver=compStr(7:end);

        return;

    otherwise
        cver=comp.Version;
    end

    if(~isempty(comp)&&~isempty(strfind(comp.Name,'Microsoft'))&&...
        ~isempty(strfind(comp.Name,'SDK')))
        cver=[cver,'SDK'];
    end

    compStr=[manufacturer,'-',cver];

end
