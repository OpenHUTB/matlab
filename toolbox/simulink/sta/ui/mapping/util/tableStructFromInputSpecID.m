function tableStruct=tableStructFromInputSpecID(inputSpecID)



    repoSpec=sta.InputSpecification(inputSpecID);
    inMapIDs=repoSpec.getInputMapIDs;
    aStruct=struct;

    if repoSpec.Verify
        passVal=true;
        failVal=false;
    else
        passVal=1;
        failVal=0;
    end

    if~isempty(inMapIDs)
        N=length(inMapIDs);
        tableStruct=cell(1,N);

        for k=1:N
            inputMap=sta.InputMap(inMapIDs(k));

            aStruct.id=k-1;



            if strcmp(inputMap.Status,'Unknown')
                aStruct.status=-1;
            else

                switch lower(inputMap.Status)
                case 'noerror'
                    aStruct.status=passVal;
                case 'warning'
                    aStruct.status=2;
                case 'error'
                    aStruct.status=failVal;
                end

            end

            if inputMap.SignalID~=-1
                repo=starepository.RepositoryUtility();
                aStruct.datasource=getMetaDataByName(repo,inputMap.SignalID,'FileName');
            else

                aStruct.datasource='';
            end



            inputDataName=inputMap.InputString;

            if isempty(inputDataName)
                inputDataName='[ ]';
            end

            scenariosignal=inputMap.InputName;
            if isempty(scenariosignal)
                scenariosignal='';
            end



            aStruct.inputdata=inputDataName;
            aStruct.scenariosignal=scenariosignal;

            repoDest=sta.MapDestination(inputMap.DestID);
            aStruct.blockname=repoDest.BlockName;

            if repoDest.PortIndex~=-1
                aStruct.portindex=repoDest.PortIndex;
            else


                aStruct.portindex=repoDest.Type;



                if strcmpi(repoDest.Type,'EnablePort')
                    aStruct.portindex=DAStudio.message('sl_sta:mapping:enablePortLabel');
                else
                    aStruct.portindex=DAStudio.message('sl_sta:mapping:triggerPortLabel');
                end

            end
            aStruct.blockpath=repoDest.BlockPath;

            tableStruct{k}=aStruct;
        end
    else
        tableStruct=[];
    end
