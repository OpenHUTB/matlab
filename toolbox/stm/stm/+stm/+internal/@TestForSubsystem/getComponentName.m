function res=getComponentName(fullName)




    res=char(strrep(regexprep(get_param(fullName,'Name'),'[\n\r\t\v]+',''),' ',''));
end
