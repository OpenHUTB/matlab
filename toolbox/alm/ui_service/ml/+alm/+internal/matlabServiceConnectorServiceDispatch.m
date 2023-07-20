function result=matlabServiceConnectorServiceDispatch(...
    serviceName,serviceCall,serviceArgs,operationStatus)




    curProj=matlab.project.currentProject();
    if~isempty(curProj)
        projRootPath=curProj.RootFolder;
        service=eval(serviceName+".get("""+projRootPath+""");");
    else
        service=eval(serviceName+".get();");
    end

    decodedArgs=jsondecode(serviceArgs);

    if ismethod(service,serviceCall)
        rawResults=service.(serviceCall)(decodedArgs,operationStatus);
    elseif ismethod(service,'serviceCallImpl')
        rawResults=service.serviceCallImpl(...
        serviceCall,decodedArgs,operationStatus);
    else

        rawResults=[];
    end

    if ischar(rawResults)||isstring(rawResults)
        result=string(rawResults);
    else
        result=string(jsonencode(rawResults));
    end


    result=char(result);
end
