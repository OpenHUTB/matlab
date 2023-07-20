



function name=convertSLObjectNameToGraphicalName(fullname)

    pos=strfind(fullname,'/');
    name=fullname(pos+1:end);
    name=regexprep(name,'//','/');
end
