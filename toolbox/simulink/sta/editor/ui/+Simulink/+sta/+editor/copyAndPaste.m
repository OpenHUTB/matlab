function[jsonStruct,arrayOfProps]=copyAndPaste(scenarioID,sigIDToCopy,signalIDToInsertInto,varargin)




    if~isempty(varargin)
        isreorder=varargin{1};
    else
        isreorder=true;
    end


    theScenarioRepoItem=sta.Scenario(scenarioID);
    topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);

    aFactory=starepository.repositorysignal.Factory;

    concreteExtractor=aFactory.getSupportedExtractor(sigIDToCopy);

    jsonStruct=copy(concreteExtractor,sigIDToCopy);
    repo=starepository.RepositoryUtility();

    if isfield(jsonStruct{1},'ComplexID')
        newSigID=jsonStruct{1}.ComplexID;
    else
        newSigID=jsonStruct{1}.ID;
    end

    for k=1:length(jsonStruct)
        if isfield(jsonStruct{k},'ComplexID')







            updateComplexConcreteExtractor=aFactory.getSupportedExtractor(jsonStruct{k}.ComplexID);

            plotableIDS=getPlottableSignalIDs(updateComplexConcreteExtractor,jsonStruct{k}.ComplexID);
            repoUtil=starepository.RepositoryUtility();

            for kPlot=1:length(plotableIDS)
                repoUtil.repo.setSignalDataValues(plotableIDS(kPlot),repoUtil.getSignalDataValues(plotableIDS(kPlot)));
            end
        end
    end






    if isempty(signalIDToInsertInto)
        signalIDToInsertInto=0;
    end

    originalInsertInto=signalIDToInsertInto;

    signalIDToInsertInto=findFirstPossibleParent(concreteExtractor,newSigID,signalIDToInsertInto);

    if signalIDToInsertInto==0


        if signalIDToInsertInto~=originalInsertInto
            pasteIntoTreeOrder=repo.getMetaDataByName(originalInsertInto,'TreeOrder');
            repo.setMetaDataByName(jsonStruct{1}.ID,'TreeOrder',pasteIntoTreeOrder);

            if isfield(jsonStruct{1},'ComplexID')
                repo.setMetaDataByName(jsonStruct{1}.ComplexID,'TreeOrder',pasteIntoTreeOrder);
            end

            jsonStruct{1}.TreeOrder=pasteIntoTreeOrder;
        end


        aSigName=getSignalLabel(repo,sigIDToCopy);

        theScenarioRepoItem=sta.Scenario(scenarioID);
        topLevelSignalIDs=getSignalIDs(theScenarioRepoItem);
        namesCantBeUsed=getSignalNames(repo,topLevelSignalIDs);

        editNamePayLoad=updateSignalName(concreteExtractor,newSigID,aSigName,aSigName,namesCantBeUsed);


        jsonStruct{1}.Name=aSigName;
        jsonStruct{1}.ParentID='input';
        jsonStruct{1}.ParentName=[];


        for kPayLoad=1:length(editNamePayLoad)


            for kJson=1:length(jsonStruct)



                if(editNamePayLoad(kPayLoad).id==jsonStruct{kJson}.ID)&&...
                    ~strcmpi(editNamePayLoad(kPayLoad).propertyname,'FullName')

                    propName=editNamePayLoad(kPayLoad).propertyname;

                    if strcmp(propName,'name')
                        propName='Name';
                    end


                    jsonStruct{kJson}.(propName)=...
                    editNamePayLoad(kPayLoad).newValue;
                    break;
                end

            end

        end



        eng=sdi.Repository(true);
        eng.safeTransaction(@initExternalSources,...
        jsonStruct,...
        scenarioID);

        topLevelSignalIDs=getTopLevelIDsInTreeOrder(repo,scenarioID);



        if originalInsertInto==0||...
            ~(repo.getParent(originalInsertInto)==0)

            idxPasted=topLevelSignalIDs==newSigID;
            topLevelSignalIDs(idxPasted)=[];
            topLevelSignalIDs=[topLevelSignalIDs,newSigID];
        end

        if isreorder
            arrayOfProps=rearrangeTreeOrder(repo,double(topLevelSignalIDs),[],0);

            repo.setMetaDataByName(jsonStruct{1}.ID,'IS_EDITED',1);
        else
            arrayOfProps=[];
        end

    else
        jsonStruct{1}.ParentID=signalIDToInsertInto;
        jsonStruct{1}.ParentName=repo.getSignalLabel(signalIDToInsertInto);
        insertDataType=repo.getMetaDataByName(signalIDToInsertInto,'dataformat');


        aSigName=getSignalLabel(repo,sigIDToCopy);

        if(originalInsertInto==signalIDToInsertInto)

            insertParentContainerID=repo.getParent(originalInsertInto);

            if insertParentContainerID==0


                parentFullName=repo.getSignalLabel(originalInsertInto);
            else
                parentFullName=Simulink.sta.editor.getSignalParentFullName(originalInsertInto);
                parentFullName=[parentFullName,'.',repo.getSignalLabel(originalInsertInto)];
            end
        else
            parentFullName=Simulink.sta.editor.getSignalParentFullName(originalInsertInto);
        end
        jsonStruct{1}.ParentName=parentFullName;
        fullName=[parentFullName,'.',aSigName];

        editNamePayLoad=[];
        if~strcmpi(insertDataType,'dataset')

            childSignalIDS=repo.getChildrenIDsInSiblingOrder(signalIDToInsertInto);
            namesCantBeUsed=getSignalNames(repo,childSignalIDS);

            editNamePayLoad=updateSignalName(concreteExtractor,newSigID,fullName,aSigName,namesCantBeUsed);
        end



        arrayOfProps=Simulink.sta.signaltree.moveAndInsertSignal(double(topLevelSignalIDs),...
        double(newSigID),double(signalIDToInsertInto),...
        parentFullName,'','',false);


        if repo.getParent(originalInsertInto)~=repo.getParent(newSigID)

            arrayOfProps=Simulink.sta.signaltree.moveAndInsertSignal(double(topLevelSignalIDs),...
            double(newSigID),double(signalIDToInsertInto),...
            parentFullName,'','',false);
        else
            [arrayOfProps,errMessage]=Simulink.sta.signaltree.moveIntoAndOrderSignal(double(topLevelSignalIDs),double(newSigID),double(signalIDToInsertInto),...
            parentFullName,originalInsertInto,0,0,'',theScenarioRepoItem.APPid,false);
        end

        if isreorder
            treeArrayOfProps=rearrangeTreeOrder(repo,double(topLevelSignalIDs),[],0);
            arrayOfProps=[arrayOfProps,treeArrayOfProps];
        else



            arrayOfProps=[];
        end

        for kPayLoad=1:length(editNamePayLoad)


            for kJson=1:length(jsonStruct)



                if(editNamePayLoad(kPayLoad).id==jsonStruct{kJson}.ID&&...
                    ~strcmpi(editNamePayLoad(kPayLoad).propertyname,'FullName'))

                    propName=editNamePayLoad(kPayLoad).propertyname;

                    if strcmp(propName,'name')
                        propName='Name';
                    end


                    jsonStruct{kJson}.(propName)=...
                    editNamePayLoad(kPayLoad).newValue;
                    break;
                end

            end

        end

    end
end
