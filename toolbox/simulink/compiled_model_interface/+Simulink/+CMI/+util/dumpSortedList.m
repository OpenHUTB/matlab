function dumpSortedList(bd,count)
    bl=bd.getSortedList;

    for i=1:length(bl)
        for j=1:count
            fprintf('\t');
        end
        fprintf('%d %s\n',i,strrep([get_param(bl(i).Handle,'Parent'),'/'...
        ,get_param(bl(i).Handle,'Name')],char(10),char([92,110])));
        if strcmp(get_param(bl(i).Handle,'BlockType'),'SubSystem')
            ss=Simulink.CMI.Subsystem(bd.sess,bl(i).Handle);
            dumpSortedList(ss,count+1);
        end
    end

end