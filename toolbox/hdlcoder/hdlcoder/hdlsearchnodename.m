function nodename=hdlsearchnodename(nodename)



    replacewithspace_list={char(9),char(10),char(12),char(13)};
    for i=1:numel(replacewithspace_list)
        nodename=strrep(nodename,replacewithspace_list{i},' ');
    end



    nodename=regexprep(nodename,'(\W)','\\$1');


    nodename=strrep(nodename,'\<','<');
    nodename=strrep(nodename,'\>','>');



    nodename=strrep(nodename,'\ ','\s');



