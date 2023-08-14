function result=addServerFunctionsToSCM(scmFile,serverInterface)



    result.code='OK';
    result.message='';
    result.writeHeaderFileFcnIdx=[];
    try
        sfInterface=SharedCodeManager.SharedServerInterface(scmFile);


        for i=1:serverInterface.NumberOfServers
            if serverInterface.NumberOfServers==1
                serverInfo=serverInterface.FunctionRecord;
            else
                serverInfo=serverInterface.FunctionRecord{i};
            end
            newIdent=SharedCodeManager.SharedServerIdentity(...
            serverInfo.serverName);
            newData=SharedCodeManager.SharedServerData(...
            serverInfo.serverName,...
            serverInfo.model,...
            serverInfo.serverPrototype,...
            '',...
            serverInfo.fcnIdx,...
            serverInfo.definedInThisModel,...
            false);
            sfInterface.registerDataUsingCaching(newIdent,newData);
        end


        sfInterface.finalize();

        data=sfInterface.retrieveAllData('SCM_SHARED_SERVERS');
        for i=1:numel(data)

            if data{i}.WriteHeaderFile
                result.writeHeaderFileFcnIdx(end+1)=data{i}.FcnIdx;
            end
            diagnosticCode=data{i}.RegistrationDiagnostic;

            if~isempty(diagnosticCode)
                diagnosticStrings=strsplit(diagnosticCode,',');
                if strcmp(diagnosticStrings{1},'RTW:buildProcess:RedefinedServerPrototype')==1
                    if~strcmpi(result.code,'ERROR')
                        result.code='WARNING';
                    end
                    result.message=strcat(...
                    result.message,DAStudio.message(diagnosticStrings{1},data{i}.ServerName,...
                    diagnosticStrings{2}));
                else
                    result.code='ERROR';
                    result.message=strcat(...
                    result.message,DAStudio.message(diagnosticStrings{1},data{i}.ServerName,...
                    diagnosticStrings{2},diagnosticStrings{3}));
                end
            end


            newIdent=SharedCodeManager.SharedServerIdentity(...
            data{i}.ServerName);
            data{i}.RegistrationDiagnostic='reset';
            sfInterface.registerDataUsingCaching(newIdent,data{i});
        end


        sfInterface.finalize();

    catch
        result.code='ERROR';
        result.message='internal exception in addServerFunctionsToSCM';
    end

end
