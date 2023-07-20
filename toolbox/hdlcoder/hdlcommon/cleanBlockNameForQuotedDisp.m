function name=cleanBlockNameForQuotedDisp(name)


    name=strrep(name,'''','''''');


    if(~isempty(regexp(name,'\n','ONCE')))
        name=regexprep(name,'\n',''',char(10),''');
        name=sprintf('[''%s'']',name);
    else
        name=sprintf('''%s''',name);
    end

end