function fileList=readAdditionalSourceListFile(fileName)




    fileList={};
    if exist(fileName,'file')
        [fid,errmsg]=fopen(fileName,'rt','native','UTF-8');
        if~isempty(errmsg)
            pslinkMessage('error','pslink:badAdditionalSourceListFile',fileName);
        else
            num=0;
            tline=fgetl(fid);
            while(tline~=-1)
                num=num+1;
                fileList{num}=tline;%#ok<AGROW>
                tline=fgetl(fid);
            end
            fclose(fid);
        end
    end

