function[out,ignore]=getCodeTimeStamp(h,file)%#ok<INUSL>









    out='';
    ignore=false;

    [~,filename,ext]=fileparts(file);




    if strcmp([filename,ext],'rtwtypes.h')||...
        strcmp([filename,ext],'rtwtypes_h.html')||...
        strcmp(ext,'.arxml')||...
        (strcmp(ext,'.html')&&length(filename)>=6&&...
        strcmp(filename(end-5:end),'_arxml'))
        ignore=true;
        return
    end

    fid=fopen(file,'r','n','utf-8');


    if strcmp(ext,'.html')
        if rtw.report.ReportInfo.DisplayInCodeTrace
            while~feof(fid)&&isempty(strfind(fgets(fid),'<pre id="code">')),end
        else
            while~feof(fid)&&isempty(strfind(fgets(fid),'<pre id="RTWcode">')),end
        end
    end

    pattern='source code generated on';
    for k=1:50
        if(feof(fid))
            break
        end
        line=fgets(fid);

        idx=strfind(line,pattern);
        if~isempty(idx)
            [~,s]=strtok(line(idx:end),':');
            if~isempty(s)

                [~,out]=strtok(s(2:end));

                out=strtrim(strtok(out,'<'));
            end
            break
        end
    end
    fclose(fid);
