function mergeConfigFiles(this,files,isDefault)





    if ischar(files)
        files={files};
    end

    for ii=1:length(files)
        if isDefault

            curFile=files(ii);
            [~,filename]=fileparts(curFile.FileName);
        else
            curFile=files{ii};
            [~,filename]=fileparts(curFile);
        end

        if isempty(strtrim(filename))
            continue;
        end

        filename=[filename,'.m'];%#ok
        fid=fopen(filename,'r');
        if fid~=-1

            file=char(fread(fid)');
            fclose(fid);

            idx=min(strfind(file,'='));

            structname=deblank(file(9:idx-1));
            structname=strtrim(structname);


            idx=strfind(file,newline);
            if~isempty(idx)
                file(1:idx(1))=[];
            end
            try
                eval(file);
                cc=eval(structname);

                this.MergedConfigContainer.merge(cc);

            catch me %#ok<NASGU>
                if~isDefault
                    warning(message('hdlcoder:engine:invalidconfigfile',filename));
                end
            end
        else
            warning(message('hdlcoder:engine:unabletoopenconfigfile',filename));
        end
    end
end




