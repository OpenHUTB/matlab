function import=grl2import(file)

    if exist(file,'file')~=2
        error('File %s not found.',file);
    end

    grl=internal.CodeImporter.grlimport(file);
    n=length(grl);
    len=0;
    index=zeros(1,n,'logical');

    for idx=1:n
        if(strcmp(grl(idx).parameter,'parameter')||strcmp(grl(idx).parameter,'axis')||strcmp(grl(idx).parameter,'online'))
            len=len+1;
            index(idx)=true;
        end
    end
    index=find(index);


    n=length(index);
    import(n).Name={};
    import(n).Type={};
    import(n).fixdt={};
    import(n).Value={};
    import(n).RealValue={};
    import(n).Min={};
    import(n).Max={};
    import(n).Units={};
    import(n).Description={};

    realIndex=1;
    for idx=index




        import(realIndex).Name=grl(idx).name;
        import(realIndex).Type=grl(idx).datatype;
        import(realIndex).Value=grl(idx).values;

        import(realIndex).Min=grl(idx).min;
        import(realIndex).Max=grl(idx).max;

        import(realIndex).Units=strrep(grl(idx).units,'''','');
        if contains(import(realIndex).Units,'\260')
            import(realIndex).Units=strrep(import(realIndex).Units,'\260','°');
        end

        if strcmp(import(realIndex).Units,'-')
            import(realIndex).Units='';
        end

        import(realIndex).Description=strrep(grl(idx).description,'"','');

        [rv,t]=convert(str2num(grl(idx).values),grl(idx));%#ok
        import(realIndex).RealValue=rv;
        import(realIndex).fixdt=t;

        realIndex=realIndex+1;
    end
end

function[res,fdt]=convert(val,import)
    fdt=[];
    conversion=import.conversion;
    if~isempty(conversion)&&contains(conversion,'LINEAR')

        pos1=strfind(conversion,'[');
        pos2=strfind(conversion,',');
        low=str2double(conversion(pos1(1)+1:pos2(1)-1));
        high=str2double(conversion(pos1(2)+1:pos2(2)-1));
        pos1=strfind(conversion,']');
        c_low=hex2dec(conversion(pos2(1)+2:pos1(1)-2));
        c_high=hex2dec(conversion(pos2(2)+2:pos1(2)-2));

        signed=0;
        bits=0;

        if contains(import.datatype,'T_S16')

            c_low=bitand(c_low,65535);
            c_low=c_low-65536;
            signed=1;
            bits=16;
        elseif contains(import.datatype,'T_S8')
            c_low=c_low-256;
            signed=1;
            bits=8;
        elseif contains(import.datatype,'T_S32')
            c_low=c_low-2^32;
            signed=1;
            bits=32;
        end


        res=interp1([c_low,c_high],[low,high],val);
        res=round(res,10,'significant');


        if contains(import.datatype,'T_U8')
            bits=8;
        elseif contains(import.datatype,'T_U16')
            bits=16;
        elseif contains(import.datatype,'T_U32')
            bits=32;
        end

        if low~=0&&c_low~=0
            aftercomma=log2(c_low/low);
        else
            aftercomma=log2(c_high/high);
        end
        if abs(aftercomma-round(aftercomma,1,'significant'))>0.1

            if sign(low)==-1&&c_low==0
                slope=(high-low)/c_high;
                offset=low-c_low;
                fdt=sprintf('fixdt(%d,%d,%g,%g)',signed,bits,slope,offset);
            else

                if c_low~=0
                    slope=low/c_low;
                else
                    slope=high/c_high;
                end
                fdt=sprintf('fixdt(%d,%d,%g,%d)',signed,bits,slope,0);
            end
        else
            fdt=sprintf('fixdt(%d,%d,%d)',signed,bits,aftercomma);
        end

    else
        res=val;
    end
end
