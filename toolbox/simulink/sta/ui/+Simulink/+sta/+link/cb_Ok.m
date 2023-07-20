function was_successful_struct=cb_Ok(State,appInstanceID)





    was_successful_struct.was_successful=false;
    was_successful_struct.errMsg='';

    outdata=[];
    outdataStruct.outdata=outdata;


    if strcmp(State.importFrom,'imBaseWorkspace')

        aList=squeeze(State.selectedIndices);

        if isempty(State.matFile)
            was_successful_struct.errMsg=DAStudio.message('sl_sta:scenarioconnector:baseimportfileempty');
            return;
        end

        if~isempty(aList)

            singalsInBaseWS_ToSave={aList(:).name};

            [~,~,fileExt]=fileparts(State.matFile);

            if isempty(fileExt)||~strcmpi(fileExt,'.mat')
                State.matFile=[State.matFile,'.mat'];
            end


            evalStr=['save ''',State.matFile,''''];

            signalNamesIn=cell(1,length(singalsInBaseWS_ToSave));
            varsOfSignals=[];

            for k=1:length(singalsInBaseWS_ToSave)
                evalStr=[evalStr,' ',singalsInBaseWS_ToSave{k}];
                signalNamesIn{k}=singalsInBaseWS_ToSave{k};
                varsOfSignals=[varsOfSignals,' ',singalsInBaseWS_ToSave{k}];
            end

            if exist(State.matFile,'file')==2&&~State.convertToSLDS
                evalStr=[evalStr,' -append'];
            end

            try


                for kSLDV=1:length(State.filemetrics.SLDVVarNames)

                    sldvVAR_Name=State.filemetrics.SLDVVarNames{kSLDV};
                    sldvVAR=evalin('base',sldvVAR_Name);

                    for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                        sldvDS=sldvsimdata(sldvVAR,kIndex);

                        sldvTestVectorName=[sldvVAR_Name,num2str(kIndex)];

                        assignin('base',sldvTestVectorName,sldvDS);
                    end
                end

                if~State.convertToSLDS

                    evalin('base',evalStr);
                else
                    [~,dsNameOnFile,~]=fileparts(State.matFile);

                    signalsIn=evalin('base',['{',varsOfSignals,'}']);
                    [aStructToSave,newName,DID_NEED_CONVERSION]=...
                    convertSignalsToDataset(signalsIn,signalNamesIn,dsNameOnFile);

                    save(State.matFile,'-struct','aStructToSave');


                    if DID_NEED_CONVERSION

                        State.selectedIndices(end+1).name=newName;
                        State.selectedIndices(end).children='all';

                        allSigNalsAvailable=fieldnames(aStructToSave);
                        listBeforeConvert={State.selectedIndices(:).name};

                        [isAvailable,~]=ismember(listBeforeConvert,allSigNalsAvailable);



                        if(any(isAvailable(:)==1))
                            isAvailable=zeros(1,length(isAvailable));
                            isAvailable(end)=1;
                        end

                        State.selectedIndices(~isAvailable)=[];
                    end
                end

            catch ME


                for kSLDV=1:length(State.filemetrics.SLDVVarNames)
                    for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                        evalin('base',['clear ',State.filemetrics.SLDVTransformedNames{kSLDV}{kIndex}]);
                    end
                end

                was_successful_struct.errMsg=DAStudio.message('sl_sta:scenarioconnector:baseimportfilenowrite',State.matFile);
                return;
            end


            for kSLDV=1:length(State.filemetrics.SLDVVarNames)
                for kIndex=1:length(State.filemetrics.SLDVTransformedNames{kSLDV})
                    evalin('base',['clear ',State.filemetrics.SLDVTransformedNames{kSLDV}{kIndex}]);
                end
            end


            State.importFrom='imMatFile';
        end
    else

        if State.convertToSLDS

            try


                [success_write,newName]=convertToSLDataset(State.matFile,State.matFile);
            catch ME

                was_successful_struct.was_successful=false;
                was_successful_struct.errMsg=ME.message;
                return;

            end

            if success_write
                State.selectedIndices(end+1).name=newName;
                State.selectedIndices(end).children='all';

                whoIsOnFile=whos('-file',State.matFile);
                allSigNalsAvailable={whoIsOnFile(:).name};
                listBeforeConvert={State.selectedIndices(:).name};

                [isAvailable,~]=ismember(listBeforeConvert,allSigNalsAvailable);



                if(any(isAvailable(:)==1))
                    isAvailable=zeros(1,length(isAvailable));
                    isAvailable(end)=1;
                end

                State.selectedIndices(~isAvailable)=[];
            end
        end
    end



    [outdata,SDIrunID]=Simulink.sta.importdialog.cb_Ok(State,appInstanceID);

    was_successful_struct.was_successful=true;

end

