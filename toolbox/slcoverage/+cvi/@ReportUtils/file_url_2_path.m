function fileName=file_url_2_path(url)



    if ispc
        fileName=strrep(url,'file://localhost/','');
        fileName=strrep(fileName,'file:///','');
        fileName=strrep(fileName,'file:/','');
    else
        fileName=strrep(url,'file://localhost/','/');
        fileName=strrep(fileName,'file:','');
        fileName=regexprep(fileName,'/+','/');
    end
    fileName=strrep(fileName,'%20',' ');
    fileName=strtok(fileName,'#');

