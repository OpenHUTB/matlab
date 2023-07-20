function str=cellstr2str(cellofstr)




    if length(cellofstr)==1
        str=sprintf('''%s''',cellofstr{1});
    else
        str=sprintf('''%s'', ',cellofstr{1});
        for i=2:length(cellofstr)
            if i<length(cellofstr)
                str=sprintf('%s''%s'', ',str,cellofstr{i});
            else
                str=sprintf('%s''%s''',str,cellofstr{i});
            end
        end
    end