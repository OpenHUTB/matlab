function add_persistent_data_to_html(this,htmlData)




    linkTableStr=sf('Private','mx2str',htmlData);
    linkTableStr=strrep(linkTableStr,'\','\\');
    linkTableStr=strrep(linkTableStr,'"','\q');
    linkTableStr=strrep(linkTableStr,'>','\g');
    linkTableStr=strrep(linkTableStr,'<','\l');
    linkTableStr=strrep(linkTableStr,newline,'\n');
    printIt(this,'<MX2STR STRING="%s"/>\n',linkTableStr);
