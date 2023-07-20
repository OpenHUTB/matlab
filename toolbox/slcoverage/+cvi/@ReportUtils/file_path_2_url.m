function url=file_path_2_url(filepath)



    url=['file:///',filepath];
    url=strrep(url,'\','/');
    url=strrep(url,' ','%20');
