function res=compareHtmlOptions(~,opt1,opt2)




    idx1=strfind(opt1,'-sRT=');
    if~isempty(idx1)
        opt1=opt1(idx1+6:end);
    end
    idx2=strfind(opt2,'-sRT=');
    if~isempty(idx2)
        opt2=opt2(idx2+6:end);
    end
    res=strcmpi(opt1,opt2);
end