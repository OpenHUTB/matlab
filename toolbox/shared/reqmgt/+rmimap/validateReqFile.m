function result=validateReqFile(fname)

    result='';

    if exist(fname,'file')~=2
        error(message('Slvnv:rmigraph:MissingFile',fname));
    end

    [~,~,ext]=fileparts(fname);
    if~strcmp(ext,'.req')
        error(message('Slvnv:rmigraph:UnsupportedFilenameExtension',fname));
    end

    fid=fopen(fname);

    while 1
        line=fgetl(fid);
        if~ischar(line),break,end
        if~isempty(strfind(line,'<rmidd:Root '))
            result='mdlRoot';
            break;
        elseif~isempty(strfind(line,'<rmidd:Graph '))
            result='mdlGraph';
            break;
        end
    end

    fclose(fid);

end


