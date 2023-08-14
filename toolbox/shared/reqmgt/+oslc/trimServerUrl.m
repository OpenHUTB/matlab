
function out=trimServerUrl(in)








    noProtocol=regexprep(in,'^https://','');
    out=regexprep(noProtocol,':443$','');

end



