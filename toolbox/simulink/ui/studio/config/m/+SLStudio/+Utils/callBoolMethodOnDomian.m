function boolVal=callBoolMethodOnDomian(cbinfo,methodName)




    boolVal=false;
    if ismethod(cbinfo.domain,methodName)
        boolVal=cbinfo.domain.(methodName);
    end
end
