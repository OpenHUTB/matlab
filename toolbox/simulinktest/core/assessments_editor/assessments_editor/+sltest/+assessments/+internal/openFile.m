function res=openFile()
    [filename,pathname]=uigetfile(...
    {'*.ainfo','Assessment File (*.ainfo)'},...
    'Open Assessment file');
    if~isequal(filename,0)
        res=fileread(fullfile(pathname,filename));
    else
        res=-1;
    end

end

