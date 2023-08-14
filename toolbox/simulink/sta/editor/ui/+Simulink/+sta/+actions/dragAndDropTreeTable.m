function[arrayOfProps,errMessage]=dragAndDropTreeTable(inputArgs)


















    scenarioIDs=inputArgs.scenarioIDs;
    sourceIDs=inputArgs.sourceIDs;
    destID=inputArgs.destID;
    parentFullName=inputArgs.anchorparentfullname;
    appInstanceID=inputArgs.appInstanceID;
    isReorder=inputArgs.isReorder;
    destinationChildOrderById=inputArgs.destinationChildOrderById;


    errMessage='';



    repoUtil=starepository.RepositoryUtility();


    nSignalsMoved=length(sourceIDs);


    nProps=0;





    for kSource=1:nSignalsMoved

        sourceParentID=getParent(repoUtil,sourceIDs(kSource));


        if sourceParentID==0



            scenarioIDs(scenarioIDs==sourceIDs(kSource))=[];


            repoManager=sta.RepositoryManager();
            scenarioid=getScenarioIDByAppID(repoManager,appInstanceID);
            removeExternalSourceFromScenario(repoManager,scenarioid,sourceIDs(kSource));



            insertChildAtTop(repoUtil,sourceIDs(kSource),destID);
            setMetaDataByName(repoUtil,sourceIDs(kSource),'ParentID',destID);


        else


            parentIdBeforeMove=getParent(repoUtil,sourceIDs(kSource));

            if(destID~=parentIdBeforeMove)

                removeParent(repoUtil,sourceIDs(kSource));



                insertChildAtTop(repoUtil,sourceIDs(kSource),destID);
                setMetaDataByName(repoUtil,sourceIDs(kSource),'ParentID',destID);

            end
        end






        signalType=getMetaDataByName(repoUtil,sourceIDs(kSource),'SignalType');
        IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));


        if~IS_COMPLEX
            arrayOfProps(nProps+1).id=double(sourceIDs(kSource));
            arrayOfProps(nProps+1).propertyname='parent';
            arrayOfProps(nProps+1).newValue=double(destID);
            arrayOfProps(nProps+2).id=double(sourceIDs(kSource));
            arrayOfProps(nProps+2).propertyname='ParentName';
            arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
            arrayOfProps(nProps+3).id=double(sourceIDs(kSource));
            arrayOfProps(nProps+3).propertyname='FullName';
            arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

            childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceIDs(kSource),arrayOfProps(nProps+3).newValue);
            arrayOfProps=[arrayOfProps,childArrayOfProps];
        else

            dataFormat=getMetaDataByName(repoUtil,sourceIDs(kSource),'dataformat');
            IS_MULTIDIM=contains(dataFormat,'multidimtimeseries');
            IS_NON_SCALAR_TT=contains(dataFormat,'non_scalar_sl_timetable');
            IS_NDIM=contains(dataFormat,'ndimtimeseries');

            if IS_MULTIDIM

                multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

                arrayOfProps(nProps+1).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+1).propertyname='parent';
                arrayOfProps(nProps+1).newValue=double(destID);
                arrayOfProps(nProps+2).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+2).propertyname='ParentName';
                arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
                arrayOfProps(nProps+3).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+3).propertyname='FullName';
                arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

                childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceIDs(kSource),multiFullName);
                arrayOfProps=[arrayOfProps,childArrayOfProps];


            elseif IS_NON_SCALAR_TT||IS_NDIM

                multiFullName=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

                arrayOfProps(nProps+1).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+1).propertyname='parent';
                arrayOfProps(nProps+1).newValue=double(destID);
                arrayOfProps(nProps+2).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+2).propertyname='ParentName';
                arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
                arrayOfProps(nProps+3).id=double(sourceIDs(kSource));
                arrayOfProps(nProps+3).propertyname='FullName';
                arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

                childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceIDs(kSource),multiFullName);
                arrayOfProps=[arrayOfProps,childArrayOfProps];
            else
                signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,sourceIDs(kSource));

                arrayOfProps(nProps+1).id=double(signalChildrenIDs(1));
                arrayOfProps(nProps+1).propertyname='parent';
                arrayOfProps(nProps+1).newValue=double(destID);
                arrayOfProps(nProps+2).id=double(signalChildrenIDs(1));
                arrayOfProps(nProps+2).propertyname='ParentName';
                arrayOfProps(nProps+2).newValue=getSignalLabel(repoUtil,destID);
                arrayOfProps(nProps+3).id=double(signalChildrenIDs(1));
                arrayOfProps(nProps+3).propertyname='FullName';
                arrayOfProps(nProps+3).newValue=[parentFullName,'.',getSignalLabel(repoUtil,sourceIDs(kSource))];

                childArrayOfProps=Simulink.sta.signaltree.updateChildFullName(sourceIDs(kSource),arrayOfProps(nProps+3).newValue);
                arrayOfProps=[arrayOfProps,childArrayOfProps];
            end
        end


        oldestParent=repoUtil.getOldestRelative(sourceIDs(kSource));


        repoUtil.setMetaDataByName(sourceIDs(kSource),'IS_EDITED',1);


        if sourceParentID~=0
            repoUtil.setMetaDataByName(sourceParentID,'IS_EDITED',1);
        end


        if oldestParent~=0
            repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
        end



        nProps=length(arrayOfProps);
    end


    oldestParent=repoUtil.getOldestRelative(destID);


    repoUtil.setMetaDataByName(destID,'IS_EDITED',1);


    if oldestParent~=0
        repoUtil.setMetaDataByName(oldestParent,'IS_EDITED',1);
    end






    repoUtil.repo.safeTransaction(@setChildOrder,...
    destID,...
    destinationChildOrderById);




    if isReorder
        tmpArrayOfProps=rearrangeTreeOrder(repoUtil,scenarioIDs,[],0);
        arrayOfProps=[arrayOfProps,tmpArrayOfProps];
    end


end

function setChildOrder(destId,destinationChildOrderById)

    childMgr=sta.ChildManager;
    childOrderIDS=getChildOrderIDs(childMgr,destId);

    numChildren=length(destinationChildOrderById);
    for kChildren=1:numChildren

        childOrder=sta.ChildOrder(childOrderIDS(kChildren));
        childOrder.ChildID=destinationChildOrderById(kChildren);
        childOrder.SignalOrder=kChildren;


    end
end
