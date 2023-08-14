function url=urlencode4NonAscii(url)







    nonascii=url(url>127|url<32);
    for i=1:numel(nonascii)
        str=urlencode(nonascii(i));
        url=strrep(url,nonascii(i),str);
    end
end
