
function[dt,dim]=getBusFieldDatatypeAndDimension(aBusName,...
    aFieldName,...
    aBlockHandle)

    try
        element=getBusElement(aBusName,aFieldName,aBlockHandle);
        dt=element.DataType;
        dim=element.Dimensions;
    catch ME %#ok
        dt='unknown';
        dim=[];
    end
end


function out=getBusElement(aBusName,aFieldName,aBlockHandle)

    elementParts=strsplit(aFieldName,'.');


    blockSID=Simulink.ID.getSID(aBlockHandle);
    busObj=slResolve(aBusName,blockSID);
    elements=busObj.Elements;


    idx=arrayfun(@(x)(strcmpi(x.Name,elementParts{1})),elements);
    element=elements(idx);

    if(numel(elementParts)==1)
        out=element;
    else
        tBusName=strsplit(element.DataType,':');
        tBusName=strtrim(tBusName{2});
        tFieldName=strjoin(elementParts(2:end),'.');
        out=getBusElement(tBusName,tFieldName,aBlockHandle);
    end
end
