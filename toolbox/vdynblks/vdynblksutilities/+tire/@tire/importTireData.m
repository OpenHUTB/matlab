function[tire,propNaN]=importTireData(tire,tir_filename)





    tirFileID=fopen(fullfile(tire.DIR,tir_filename),'r');
    if tirFileID==-1
        error(message('vdynblks:vehdyntire:noFile',tir_filename));
    end
    line=fgetl(tirFileID);
    propNaN=strings(1,279);
    ii=1;
    startNaNcount=0;
    while ischar(line)



        if startNaNcount==0&&contains(line,"[DIMENSION]")
            startNaNcount=1;
        end
        if regexp(line,'^[A-Z]')
            prop=strsplit(line,{'=','$'});
            propName=char(strtrim(prop{1}));
            if isprop(tire,propName)
                propValue=char(strtrim(prop{2}));
                if~strncmpi(propValue,'''',1)
                    tire.(propName)=str2double(propValue);
                else
                    tire.(propName)=strrep(propValue,'''','');
                end
                if(checkNaN(tire.(propName))&&ischar(line)&&startNaNcount==1)
                    propNaN(ii)=string(propName);
                    ii=ii+1;
                end
            else
                warning(message('vdynblks:vehdyntire:unknownParam',propName));
            end
        end
        line=fgetl(tirFileID);
    end
    propNaN=propNaN(~(propNaN==""));

    fclose(tirFileID);
    function b=checkNaN(value)
        if numel(value)==1
            b=isnan(value);
        else
            vcol=value(:);
            b=any(isnan(vcol));
        end
    end
end
