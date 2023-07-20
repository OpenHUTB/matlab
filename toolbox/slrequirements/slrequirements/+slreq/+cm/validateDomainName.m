function typeName=validateDomainName(typeName)

    typeName=convertStringsToChars(typeName);

    if~ischar(typeName)
        throwAsCaller(MException(message('Slvnv:slreq_uri:NotValidTypeForDomainName',class(typeName))));
    end


    typeName=fixToCompleteBuiltinName(typeName);

    if~isRegisteredDomainName(typeName)
        rmiut.warnNoBacktrace('Slvnv:slreq_uri:NotRegisteredDomainType',typeName);
    end

end

function name=fixToCompleteBuiltinName(name)
    switch name
    case{'doors','oslc'}
        name=['linktype_rmi_',name];
    case 'dng'
        name='linktype_rmi_oslc';
    otherwise

    end
end

function tf=isRegisteredDomainName(name)
    registeredApi=rmi.linktype_mgr('resolveByRegName',name);
    tf=~isempty(registeredApi);
end
