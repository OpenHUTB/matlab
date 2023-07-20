





function retValue=getSLFcnCanBeInvokedConcurrently(fcnH)

    retValue=false;
    try
        modelH=bdroot(fcnH);
        mapping=autosar.api.Utils.modelMapping(modelH);
        fcnFullPath=strrep(getfullname(fcnH),newline,' ');
        serverFcnMapping=mapping.ServerFunctions.findobj('Block',fcnFullPath);

        if(length(serverFcnMapping)==1)
            runnableName=serverFcnMapping.MappedTo.Runnable;
            if~isempty(runnableName)
                apiObj=autosar.api.getAUTOSARProperties(modelH,true);
                compQName=apiObj.get('XmlOptions','ComponentQualifiedName');
                runQName=apiObj.find(compQName,'Runnable','Name',runnableName,...
                'PathType','FullyQualified','canBeInvokedConcurrently',true);
                retValue=~isempty(runQName);
            end
        end
    catch
        return;
    end

end


