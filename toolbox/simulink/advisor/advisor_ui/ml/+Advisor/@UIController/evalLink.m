function result=evalLink(~,link)
    result=[];
    eval(strtrim(strrep(urldecode(link),'matlab:','')));
end