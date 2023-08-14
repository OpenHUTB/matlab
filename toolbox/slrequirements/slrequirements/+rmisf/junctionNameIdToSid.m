function name=junctionNameIdToSid(name)




    match=regexp(name,'/junction\(#(\d+)\)$','tokens');
    if~isempty(match)
        sid=sf('get',str2double(match{1}{1}),'.ssIdNumber');
        replacement=sprintf('/junction\\(#%d\\)',sid);
        name=regexprep(name,'/junction\((#\d+)\)$',replacement);
    end
end
