function str=enum2str(enum)




    str=sprintf('''%s''',enum{1});

    for ii=2:length(enum)
        str=sprintf('%s, ''%s''',str,enum{ii});
    end

    str=['{',str,'}'];

end

