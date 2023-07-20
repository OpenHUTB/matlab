function[out,ignore]=getCodeTimeStamp(h,file)%#ok<INUSL>









    out='';
    ignore=false;

    [nu1,nu2,ext]=fileparts(file);
    fid=fopen(file,'r');


    if strcmp(ext,'.html')
        while isempty(strfind(fgets(fid),'<pre id="RTWcode">')),end
    end

    pattern1='Created';
    pattern2='Date of code generation';
    for k=1:25
        line=fgets(fid);

        idx=strfind(line,pattern1);

        if isempty(idx)

            idx=strfind(line,pattern2);
        end

        if~isempty(idx)
            [nu,s]=strtok(line(idx:end),':');
            if~isempty(s)

                out=strtrim(strtok(s(2:end),'<'));
            end
            break
        end
    end
    fclose(fid);
