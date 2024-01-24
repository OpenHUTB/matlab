function name=getExtension()
    if isunix()
        splitc='/';
    else
        splitc='\';
    end
    name=split(matlabroot,splitc);
    name=name(end-1);
    name=strrep(name{:},'.','_');
end
