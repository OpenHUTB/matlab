function url=file_url(filename)












    try
        url=which(filename);
        if isempty(url)
            url=filename;
        end
    catch
        url=filename;
    end

    temp=java.io.File(url);
    if~temp.isAbsolute()
        url=fullfile(pwd,url);
    end


    if strncmp(url,'\\',2)

        url=['file://',strrep(url,'\','/')];
    elseif strncmp(url,'/',1)

        url=['file://',url];
    else

        url=['file:///',strrep(url,'\','/')];
    end



    url=strrep(url,' ','%20');
    nonascii=url(url>127|url<32);
    for i=1:numel(nonascii)
        str=urlencode(nonascii(i));
        url=strrep(url,nonascii(i),str);
    end

end


