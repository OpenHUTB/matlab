function dataType=getElementType(aBus,aElement)
    dataType=[];
    ElementHier=strsplit(aElement,'.');
    busInfo=evalVar(aBus);
    for hIdx=2:length(ElementHier)
        eIdx=find(strcmpi(ElementHier{hIdx},{busInfo.Elements.Name}));
        dataType=busInfo.Elements(eIdx).DataType;
        dataType=strrep(dataType,' ','');
        if strfind(dataType,'Bus:')==1
            dataType=dataType(5:end);
            busInfo=evalVar(dataType);
        end
    end
end

function busInfo=evalVar(aBus)
    busInfo=evalinGlobalScope(bdroot,aBus);
end