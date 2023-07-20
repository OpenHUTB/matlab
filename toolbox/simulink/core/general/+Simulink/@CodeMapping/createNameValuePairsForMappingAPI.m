function out=createNameValuePairsForMappingAPI(valuesJSON)




    mainStruct=mls.internal.fromJSON(valuesJSON).callbackinfo;
    if isempty(mainStruct)
        out=[];
        return
    end


    internalDataSwAddrMethod_old='InternalDataSwAddrMethod';
    internalDataSwAddrMethod_new='SwAddrMethodForInternalData';
    if isfield(mainStruct,internalDataSwAddrMethod_old)
        [mainStruct.(internalDataSwAddrMethod_new)]=mainStruct.(internalDataSwAddrMethod_old);
        mainStruct=rmfield(mainStruct,internalDataSwAddrMethod_old);
    end


    unsetValues={DAStudio.message('RTW:autosar:selectERstr'),DAStudio.message('RTW:autosar:uiUnselectOptions')};
    conditionalProps={'Port','DataElement','SwAddrMethod',internalDataSwAddrMethod_new};
    for prop=conditionalProps
        if isfield(mainStruct,prop)&&any(strcmp(mainStruct.(prop{:}),unsetValues))
            mainStruct.(prop{:})='';
        end
    end

    out=namedargs2cell(mainStruct);


    for i=1:length(out)
        if isa(out{i},'char')||isa(out{i},'string')
            if contains(out{i},':')
                out{i}=extractBefore(out{i},':');
            end
        end
    end
end
