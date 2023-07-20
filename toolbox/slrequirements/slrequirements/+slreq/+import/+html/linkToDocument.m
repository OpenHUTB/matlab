function htLink=linkToDocument(docPath,anchorType,label)
    switch anchorType
    case 'bookmark'
        navCmd=['rmi.navigate(''other'',''',docPath,''',''@',label,''','''');'];
    case 'match'
        navCmd=['rmi.navigate(''other'',''',docPath,''',''?',label,''','''');'];
    case 'doors'
        navCmd=['rmi.navigate(''linktype_rmi_doors'',''',docPath,''',''',label,''','''',''_suppress_browser'');'];
    otherwise
        htLink='';
        return;
    end
    navUrl=rmiut.cmdToUrl(navCmd);
    htLink=sprintf('<a href="%s">%s</a>',navUrl,label);
end
