function args=parseExtModeMexArgs(argstr)





    if~isempty(argstr)
        t=textscan(argstr,'%s %s %s');
        args=cell(1,3);
        for i=1:3
            if~isempty(t{i})
                args{i}=strtrim(t{i}{1});
            else
                args{i}='';
            end
        end
    else
        args={'','',''};
    end
end
