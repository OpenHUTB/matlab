function[arrayOfProps,errMessage]=undoDragAndDropTreeTable(inputArgs)
















    errMessage=cell(1,length(inputArgs));
    arrayOfProps=[];

    for k=1:length(inputArgs)





        if k+1<=length(inputArgs)
            [idsToRemove,~]=intersect([inputArgs(k+1:end).sourceIDs],inputArgs(k).destinationChildOrderById,'stable');



            if~isempty(idsToRemove)
                [~,indicesToRemove]=intersect(inputArgs(k).destinationChildOrderById,idsToRemove,'stable');
                inputArgs(k).destinationChildOrderById(indicesToRemove)=[];
            end
        end


        if(inputArgs(k).destID==0)


            repoUtil=starepository.RepositoryUtility();
            removeParent(repoUtil,inputArgs(k).sourceIDs);

            setParent(repoUtil,inputArgs(k).sourceIDs,inputArgs(k).destID);


            externalSourceIDsToRemove=inputArgs(k).scenarioIDs;
            externalSourceIDsToRemove(externalSourceIDsToRemove==inputArgs(k).sourceIDs)=[];



            repoManager=sta.RepositoryManager();
            scenarioid=getScenarioIDByAppID(repoManager,inputArgs(k).appInstanceID);


            for kSource=1:length(externalSourceIDsToRemove)
                removeExternalSourceFromScenario(repoManager,scenarioid,externalSourceIDsToRemove(kSource));
            end


            externalInputJson={};
            aFactory=starepository.repositorysignal.Factory;
            for kSource=1:length(inputArgs(k).scenarioIDs)

                concreteExtractor=aFactory.getSupportedExtractor(inputArgs(k).scenarioIDs(kSource));
                jsonStruct=jsonStructFromID(concreteExtractor,inputArgs(k).scenarioIDs(kSource));
                externalInputJson=[externalInputJson,jsonStruct];
            end


            eng=sdi.Repository(true);
            eng.safeTransaction(@initExternalSources,...
            externalInputJson,...
            scenarioid);


            arrayOfPropsNameAndParent=updateNameAndParentProperties(inputArgs(k),'input','',getSignalLabel(repoUtil,inputArgs(k).sourceIDs));


            if inputArgs(k).isReorder

                arrayOfPropsTree=rearrangeTreeOrder(repoUtil,inputArgs(k).scenarioIDs,[],0);
                arrayOfPropsSource=[arrayOfPropsNameAndParent,arrayOfPropsTree];
            else
                arrayOfPropsSource=arrayOfPropsNameAndParent;
            end

        else
            [tmpArrayOfProps,errMessage{k}]=Simulink.sta.actions.dragAndDropTreeTable(inputArgs(k));
            arrayOfPropsSource=tmpArrayOfProps;
        end

        arrayOfProps=[arrayOfProps,arrayOfPropsSource];

        arrayOfPropsSource=[];
    end

    function arrayOfPropsNameAndParent=updateNameAndParentProperties(undoProperties,parentID,parentName,fullName)

        nProps=0;

        repoUtil=starepository.RepositoryUtility();
        signalType=getMetaDataByName(repoUtil,undoProperties.sourceIDs,'SignalType');
        IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

        if~IS_COMPLEX


            arrayOfPropsNameAndParent(nProps+1).id=undoProperties.sourceIDs;
            arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
            arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
            arrayOfPropsNameAndParent(nProps+2).id=undoProperties.sourceIDs;
            arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
            arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
            arrayOfPropsNameAndParent(nProps+3).id=undoProperties.sourceIDs;
            arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
            arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

            childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.sourceIDs,arrayOfPropsNameAndParent(nProps+3).newValue);
            arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];
        else
            dataFormat=getMetaDataByName(repoUtil,undoProperties.sourceIDs,'dataformat');
            IS_MULTIDIM=contains(dataFormat,'multidimtimeseries');
            IS_NON_SCALAR_TT=contains(dataFormat,'non_scalar_sl_timetable');
            IS_NDIM=contains(dataFormat,'ndimtimeseries');

            if IS_MULTIDIM||IS_NON_SCALAR_TT||IS_NDIM

                multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,undoProperties.sourceIDs)];

                arrayOfPropsNameAndParent(nProps+1).id=undoProperties.sourceIDs;
                arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
                arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+2).id=undoProperties.sourceIDs;
                arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
                arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
                arrayOfPropsNameAndParent(nProps+3).id=undoProperties.sourceIDs;
                arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
                arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

                childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.sourceIDs,multiFullName);
                arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];

            else
                signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,undoProperties.sourceIDs);

                arrayOfPropsNameAndParent(nProps+1).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
                arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+2).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
                arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
                arrayOfPropsNameAndParent(nProps+3).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
                arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

                childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.sourceIDs,arrayOfPropsNameAndParent(nProps+3).newValue);
                arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];
            end

        end
