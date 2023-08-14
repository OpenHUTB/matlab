function success=saveTextLog(h,fileName)




    rawLog=h.Log;
    success=true;

    dir=fileparts(fileName);
    if~exist(dir,'dir')
        success=mkdir(dir);
    end

    if success
        fid=fopen(fileName,'w');

        if fid<0
            success=false;
            return;
        end

        str=sldvshareprivate('util_remove_html',rawLog);
        fprintf(fid,'%s\n',str);
        fclose(fid);
    end

