function[arrayOfProps,jsonStruct]=undoMoveAndReplace(undoProperties,appInstanceID)




    if strcmpi(undoProperties.originalMovedParent,'input')||undoProperties.originalMovedParent==0

        repoUtil=starepository.RepositoryUtility();

        setParent(repoUtil,undoProperties.movID,0);

        appInstanceID=undoProperties.appid;



        externalSourceIDsToRemove=undoProperties.originalExternalSourceIDs;
        externalSourceIDsToRemove(externalSourceIDsToRemove==undoProperties.movedID)=[];



        repoManager=sta.RepositoryManager();
        scenarioid=getScenarioIDByAppID(repoManager,appInstanceID);


        for kSource=1:length(externalSourceIDsToRemove)
            removeExternalSourceFromScenario(repoManager,scenarioid,externalSourceIDsToRemove(kSource));
        end


        externalInputJson={};
        aFactory=starepository.repositorysignal.Factory;
        for kSource=1:length(undoProperties.originalExternalSourceIDs)

            concreteExtractor=aFactory.getSupportedExtractor(undoProperties.originalExternalSourceIDs(kSource));
            jsonStruct_ExtInputTmp=jsonStructFromID(concreteExtractor,undoProperties.originalExternalSourceIDs(kSource));
            externalInputJson=[externalInputJson,jsonStruct_ExtInputTmp];%#ok<AGROW>
        end


        eng=sdi.Repository(true);
        eng.safeTransaction(@initExternalSources,...
        externalInputJson,...
        scenarioid);

        arrayOfPropsNameAndParent=updateNameAndParentProperties(undoProperties,'input','',getSignalLabel(repoUtil,undoProperties.movedID));


        if~isfield(undoProperties,'reorder')
            undoProperties.reorder=true;
        end

        if undoProperties.reorder

            arrayOfProps=rearrangeTreeOrder(repoUtil,undoProperties.originalExternalSourceIDs,[],0);

            arrayOfProps=[arrayOfProps,arrayOfPropsNameAndParent];
        else
            arrayOfProps=arrayOfPropsNameAndParent;
        end

    else


        if~isfield(undoProperties,'reorder')
            undoProperties.reorder=true;
        end

        [arrayOfProps,~,~]=Simulink.sta.signaltree.moveAndInsertSignal(undoProperties.scenarioids,undoProperties.movID,undoProperties.originalMovedParent,...
        undoProperties.originalMovedParentFullName,undoProperties.baseMsg,undoProperties.appid,undoProperties.reorder);
    end




    jsonStruct=Simulink.sta.editor.restoreSignal(undoProperties.restoreSignalProperties,false);




    function arrayOfPropsNameAndParent=updateNameAndParentProperties(undoProperties,parentID,parentName,fullName)

        nProps=1;

        repoUtil=starepository.RepositoryUtility();
        signalType=getMetaDataByName(repoUtil,undoProperties.movedID,'SignalType');
        IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

        if~IS_COMPLEX

            arrayOfPropsNameAndParent(nProps).id=undoProperties.movedID;
            arrayOfPropsNameAndParent(nProps).propertyname='ParentID';
            arrayOfPropsNameAndParent(nProps).newValue=parentID;
            arrayOfPropsNameAndParent(nProps+1).id=undoProperties.movedID;
            arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
            arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
            arrayOfPropsNameAndParent(nProps+2).id=undoProperties.movedID;
            arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
            arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
            arrayOfPropsNameAndParent(nProps+3).id=undoProperties.movedID;
            arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
            arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

            childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.movedID,arrayOfPropsNameAndParent(nProps+3).newValue);
            arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];
        else
            dataFormat=getMetaDataByName(repoUtil,undoProperties.movedID,'dataformat');
            IS_MULTIDIM=contains(dataFormat,'multidimtimeseries');
            IS_NON_SCALAR_TT=contains(dataFormat,'non_scalar_sl_timetable');
            IS_NDIM=contains(dataFormat,'ndimtimeseries');

            if IS_MULTIDIM||IS_NON_SCALAR_TT||IS_NDIM

                multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,undoProperties.movedID)];

                arrayOfPropsNameAndParent(nProps).id=undoProperties.movedID;
                arrayOfPropsNameAndParent(nProps).propertyname='ParentID';
                arrayOfPropsNameAndParent(nProps).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+1).id=undoProperties.movedID;
                arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
                arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+2).id=undoProperties.movedID;
                arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
                arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
                arrayOfPropsNameAndParent(nProps+3).id=undoProperties.movedID;
                arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
                arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

                childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.movedID,multiFullName);
                arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];

            else
                signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,undoProperties.movedID);
                arrayOfPropsNameAndParent(nProps).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps).propertyname='ParentID';
                arrayOfPropsNameAndParent(nProps).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+1).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+1).propertyname='parent';
                arrayOfPropsNameAndParent(nProps+1).newValue=parentID;
                arrayOfPropsNameAndParent(nProps+2).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+2).propertyname='ParentName';
                arrayOfPropsNameAndParent(nProps+2).newValue=parentName;
                arrayOfPropsNameAndParent(nProps+3).id=signalChildrenIDs(1);
                arrayOfPropsNameAndParent(nProps+3).propertyname='FullName';
                arrayOfPropsNameAndParent(nProps+3).newValue=fullName;

                childarrayOfPropsNameAndParent=Simulink.sta.signaltree.updateChildFullName(undoProperties.movedID,arrayOfPropsNameAndParent(nProps+3).newValue);
                arrayOfPropsNameAndParent=[arrayOfPropsNameAndParent,childarrayOfPropsNameAndParent];
            end

        end
