function disp(h)




    disp(class(h))

    names=char(h.prop_set_names);
    nameLen=size(names,2);
    col2=max(10,nameLen+1);
    col2_title_diff=col2-8;
    col2_title_align=blanks(col2_title_diff);
    col2_entry_diff=col2-nameLen+3;
    col2_entry_align=blanks(col2_entry_diff);

    s=['PropName',col2_title_align,'Enabled Total'];
    fprintf('%s\n',s);
    fprintf([repmat('-',1,numel(s)),'\n']);
    for i=1:numel(h.prop_sets)
        name=names(i,:);
        if h.prop_set_enables(i),ena='X';else ena=' ';end
        thisPropSet=h.getPropSet(h.prop_set_names{i});
        Ntot=numel(fieldnames(thisPropSet));
        fprintf('%s%s%s     %d\n',name,col2_entry_align,ena,Ntot);
    end
    fprintf('\n');


