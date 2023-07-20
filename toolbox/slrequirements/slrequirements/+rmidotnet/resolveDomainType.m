function domain=resolveDomainType(docObj)


    switch class(docObj)
    case 'rmidotnet.MSWord'
        domain='linktype_rmi_word';
    case 'rmidotnet.MSExcel'
        domain='linktype_rmi_excel';
    otherwise
        error([class(docObj),' not supported']);
    end

end
