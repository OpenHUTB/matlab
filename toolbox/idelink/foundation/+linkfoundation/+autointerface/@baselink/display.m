function display(h)










    if 0,
        name=inputname(1);
        if isempty(name)
            name='ans';
        end
    end

    isloose=strcmp(get(0,'FormatSpacing'),'loose');
    if isloose,
        newline=sprintf('\n');
    else
        newline=sprintf('');
    end

    fprintf(newline);
    disp(h);
    fprintf(newline)

