function[fdt,isfix]=formatNumericTypeString(this,dt)
    fdt=strrep(dt,' ','');
    isfix=false;
    isFix=strfind(fdt,'fix');
    if~isempty(isFix)
        ind=strfind(fdt,'*');
        commaInd=strfind(fdt,',');
        if~isempty(ind)&&length(commaInd)==2

            fdt(ind:end)=[];
            fdt=[fdt,'0)'];
        elseif~isempty(ind)&&length(commaInd)==3
            if strcmp(fdt(commaInd(2)+1),'*')
                fdt(commaInd(2)+1)='1';
            end
            if strcmp(fdt(commaInd(3)+1),'*')
                fdt(commaInd(3)+1)='0';
            end
        end
    end
    if~isempty(strfind(fdt,'fixdt'))
        fdt=strrep(fdt,'fixdt','numerictype');
        isfix=true;
    end
    if(~isempty(strfind(fdt,'fix'))||~isempty(strfind(fdt,'flt')))...
        &&isempty(strfind(fdt,'numerictype'))
        fdt=['numerictype(''',fdt,''')'];
        isfix=true;
    end
    if~isempty(strfind(fdt,'numerictype'))
        isfix=true;
    end
    fdt=strrep(fdt,' ','');

    if isfix
        try
            dtypeEmbedded=eval(fdt);
            tmpArg=RTW.TflArgNumeric;
            tmpArg.Name='unused';
            tmpArg.Type=dtypeEmbedded;
            formattedString=tmpArg.toString;
        catch ME
            throw(ME);
        end
    else
        try
            tmpArg=this.object.getTflArgFromString('unused',fdt);
            formattedString=tmpArg.toString;
        catch ME
            throw(ME);
        end
    end

    fdt=formattedString;


